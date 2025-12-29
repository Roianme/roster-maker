from ortools.sat.python import cp_model
from typing import List, Dict, Tuple, Optional
from datetime import datetime, timedelta
from ..models.schemas import (
    WeekdayTemplate,
    Staff,
    Availability,
    RosterShift,
    GenerateRosterResponse,
)


class RosterSolver:
    """
    Generates weekly rosters using OR-Tools CP-SAT solver.
    Strategy: Coverage-first, minimize changes, support locks.
    """

    def __init__(self):
        self.model = cp_model.CpModel()
        self.solver = cp_model.CpSolver()

    def generate_roster(
        self,
        venue_id: str,
        venue_name: str,
        week_start: datetime,
        templates: List[WeekdayTemplate],
        staff: List[Staff],
        availability: List[Availability],
        locked_shifts: List[RosterShift] = None,
    ) -> GenerateRosterResponse:
        """
        Generate roster using CP-SAT solver.
        
        Args:
            venue_id: Venue identifier
            venue_name: Venue name
            week_start: Start of the week (Monday)
            templates: List of weekday templates defining shift requirements
            staff: List of available staff
            availability: Staff availability data
            locked_shifts: Previously assigned shifts that should not change
        
        Returns:
            GenerateRosterResponse with shifts, warnings, and assignment reasons
        """
        shifts = []
        warnings = []
        reasons = {}

        # Create slot IDs and shift requirements for the week
        shift_requirements = []
        for template in templates:
            weekday = template.weekday
            date = week_start + timedelta(days=weekday)
            
            for block in template.shift_blocks:
                for i in range(block.count):
                    slot_id = f"{venue_id}_{date.strftime('%Y%m%d')}_{block.start_time}_{block.role_id}_{i}"
                    shift_requirements.append({
                        'slot_id': slot_id,
                        'date': date,
                        'start_time': block.start_time,
                        'end_time': block.end_time,
                        'role_id': block.role_id,
                        'weekday': weekday,
                    })

        # Build availability map
        availability_map = {}
        for avail in availability:
            key = (avail.staff_id, avail.weekday)
            availability_map[key] = avail.available

        # Create decision variables: assignment[slot][staff] = 1 if staff assigned to slot
        assignments = {}
        for slot in shift_requirements:
            for person in staff:
                # Check if staff can work this role
                if slot['role_id'] not in person.role_ids:
                    continue
                
                # Check availability
                if not availability_map.get((person.id, slot['weekday']), True):
                    continue
                
                var_name = f"assign_{slot['slot_id']}_{person.id}"
                assignments[(slot['slot_id'], person.id)] = self.model.NewBoolVar(var_name)

        # Constraint 1: Each shift must have exactly one person assigned (coverage-first)
        for slot in shift_requirements:
            slot_assignments = [
                assignments[(slot['slot_id'], person.id)]
                for person in staff
                if (slot['slot_id'], person.id) in assignments
            ]
            if slot_assignments:
                self.model.Add(sum(slot_assignments) == 1)
            else:
                warnings.append(f"No available staff for slot {slot['slot_id']}")

        # Constraint 2: Locked shifts remain assigned
        if locked_shifts:
            for locked in locked_shifts:
                if locked.employee_id and (locked.slot_id, locked.employee_id) in assignments:
                    self.model.Add(assignments[(locked.slot_id, locked.employee_id)] == 1)

        # Objective: Minimize changes (prefer keeping existing assignments)
        # For POC, we just solve for coverage
        
        # Solve
        status = self.solver.Solve(self.model)

        if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
            # Build result shifts
            for slot in shift_requirements:
                assigned_staff = None
                for person in staff:
                    if (slot['slot_id'], person.id) in assignments:
                        if self.solver.Value(assignments[(slot['slot_id'], person.id)]) == 1:
                            assigned_staff = person
                            break
                
                shift = RosterShift(
                    slot_id=slot['slot_id'],
                    venue_id=venue_id,
                    venue_name=venue_name,
                    date=slot['date'].strftime('%Y-%m-%d'),
                    start_time=slot['start_time'],
                    end_time=slot['end_time'],
                    role_id=slot['role_id'],
                    role_name=slot['role_id'],  # In production, look up role name
                    employee_id=assigned_staff.id if assigned_staff else None,
                    employee_name=f"{assigned_staff.first_name} {assigned_staff.last_name}" if assigned_staff else None,
                    locked=False,
                )
                shifts.append(shift)
                
                if assigned_staff:
                    reasons[slot['slot_id']] = f"Assigned to {assigned_staff.first_name} {assigned_staff.last_name} (available, qualified)"
                else:
                    reasons[slot['slot_id']] = "No staff available"
        else:
            warnings.append("Could not find a feasible solution")

        return GenerateRosterResponse(
            shifts=shifts,
            warnings=warnings,
            reasons=reasons,
        )
