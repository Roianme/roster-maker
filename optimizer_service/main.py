import os
from datetime import date, time
from typing import Dict, List, Optional

from fastapi import FastAPI
from ortools.sat.python import cp_model
from pydantic import BaseModel, Field


class AvailabilityWindow(BaseModel):
    weekday: int = Field(..., description="1=Mon, 7=Sun")
    start: time
    end: time


class AvailabilityException(BaseModel):
    date: date
    available: bool
    start: Optional[time] = None
    end: Optional[time] = None


class Staff(BaseModel):
    id: str
    name: str
    roles: List[str]
    weekly: List[AvailabilityWindow] = Field(default_factory=list)
    exceptions: List[AvailabilityException] = Field(default_factory=list)


class ShiftSlot(BaseModel):
    slotId: str
    venueId: str
    weekday: int = Field(..., description="1=Mon, 7=Sun")
    date: date
    start: time
    end: time
    role: str


class OptimizeRequest(BaseModel):
    staff: List[Staff]
    shiftSlots: List[ShiftSlot]
    lockedAssignments: Dict[str, str] = Field(default_factory=dict)
    lastApprovedAssignments: Dict[str, str] = Field(default_factory=dict)


class SlotReason(BaseModel):
    slotId: str
    reason: str


class OptimizeResponse(BaseModel):
    assignments: Dict[str, str]
    unfilled: List[str]
    reasons: List[SlotReason]


app = FastAPI(title="Roster Optimizer POC")

UNFILLED_ID = "UNFILLED"


def _is_available(staff: Staff, slot: ShiftSlot) -> bool:
    # Date exception takes precedence
    for exc in staff.exceptions:
        if exc.date == slot.date:
            if not exc.available:
                return False
            if exc.start and exc.end:
                return exc.start <= slot.start and exc.end >= slot.end
            return True

    # Weekly windows
    if not staff.weekly:
        return True
    windows = [w for w in staff.weekly if w.weekday == slot.weekday]
    if not windows:
        return False
    return any(w.start <= slot.start and w.end >= slot.end for w in windows)


@app.post("/optimize", response_model=OptimizeResponse)
def optimize(req: OptimizeRequest) -> OptimizeResponse:
    staff_list = list(req.staff)
    staff_list.append(
        Staff(id=UNFILLED_ID, name="Unfilled", roles=["*"], weekly=[], exceptions=[])
    )

    model = cp_model.CpModel()
    slot_ids = [s.slotId for s in req.shiftSlots]
    slot_index: Dict[str, int] = {slot_id: idx for idx, slot_id in enumerate(slot_ids)}
    staff_index: Dict[str, int] = {s.id: idx for idx, s in enumerate(staff_list)}
    unfilled_idx = staff_index[UNFILLED_ID]

    x: Dict[tuple, cp_model.IntVar] = {}
    for s_idx, staff in enumerate(staff_list):
        for slot_idx, slot in enumerate(req.shiftSlots):
            x[(s_idx, slot_idx)] = model.NewBoolVar(f"x_{s_idx}_{slot_idx}")
            if staff.id != UNFILLED_ID:
                role_ok = slot.role in staff.roles
                avail_ok = _is_available(staff, slot)
                if not (role_ok and avail_ok):
                    model.Add(x[(s_idx, slot_idx)] == 0)

    # Exactly one assignment per slot (including unfilled)
    for slot_idx, slot in enumerate(req.shiftSlots):
        model.Add(
            sum(x[(s_idx, slot_idx)] for s_idx in range(len(staff_list))) == 1
        )

    # Locked assignments
    for slot_id, staff_id in req.lockedAssignments.items():
        slot_idx = slot_index.get(slot_id)
        if slot_idx is not None and staff_id in staff_index:
            for s_idx in range(len(staff_list)):
                model.Add(
                    x[(s_idx, slot_idx)] == int(staff_index[staff_id] == s_idx)
                )

    # Stability variables
    changed_vars: List[cp_model.IntVar] = []
    for slot_idx, slot in enumerate(req.shiftSlots):
        preferred_id = req.lastApprovedAssignments.get(slot.slotId)
        change_var = model.NewBoolVar(f"changed_{slot_idx}")
        changed_vars.append(change_var)
        if preferred_id and preferred_id in staff_index:
            preferred_idx = staff_index[preferred_id]
            model.Add(change_var == 1 - x[(preferred_idx, slot_idx)])
        else:
            model.Add(change_var == 0)

    # Objective: coverage first, stability second
    unfilled_sum = sum(x[(unfilled_idx, slot_idx)] for slot_idx in range(len(slot_ids)))
    stability_sum = sum(changed_vars)
    model.Minimize(1000 * unfilled_sum + 10 * stability_sum)

    solver = cp_model.CpSolver()
    try:
        max_seconds = float(os.getenv("MAX_SOLVER_SECONDS", "10"))
    except ValueError:
        max_seconds = 10.0
    solver.parameters.max_time_in_seconds = max_seconds
    result = solver.Solve(model)

    if result not in (cp_model.OPTIMAL, cp_model.FEASIBLE):
        fallback_assignments = {slot.slotId: UNFILLED_ID for slot in req.shiftSlots}
        fallback_reasons = [
            SlotReason(slotId=slot.slotId, reason="No feasible solution found")
            for slot in req.shiftSlots
        ]
        return OptimizeResponse(
            assignments=fallback_assignments,
            unfilled=list(fallback_assignments.keys()),
            reasons=fallback_reasons,
        )

    assignments: Dict[str, str] = {}
    reasons: List[SlotReason] = []
    unfilled: List[str] = []

    for slot_idx, slot in enumerate(req.shiftSlots):
        chosen_staff = UNFILLED_ID
        for s_idx, staff in enumerate(staff_list):
            if solver.BooleanValue(x[(s_idx, slot_idx)]):
                chosen_staff = staff.id
                break
        assignments[slot.slotId] = chosen_staff
        if chosen_staff == UNFILLED_ID:
            unfilled.append(slot.slotId)
            reasons.append(
                SlotReason(
                    slotId=slot.slotId, reason="Unfilled: no eligible staff available"
                )
            )
        else:
            reasons.append(
                SlotReason(
                    slotId=slot.slotId,
                    reason=f"Assigned to {chosen_staff} (role match, available)",
                )
            )

    return OptimizeResponse(assignments=assignments, unfilled=unfilled, reasons=reasons)


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok"}
