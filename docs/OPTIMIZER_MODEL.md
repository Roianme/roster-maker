# Optimizer Model (CP-SAT)

Objective: **coverage-first, stability-second**.

## Variables
- `x[staff, slot] ∈ {0,1}` assignment (includes pseudo-staff `UNFILLED`).
- `changed[staff, slot] ∈ {0,1}` optional soft-change tracker against last approved roster.

## Constraints
1. Exactly one assignment per slot (including `UNFILLED`).
2. Role eligibility: only staff with matching role can cover.
3. Availability eligibility: staff must be available for the slot window (timezone Australia/Melbourne).
4. Locked assignments: pre-locked slots are fixed.
5. Daily supervisor requirement: model via template blocks (e.g., supervisor 12:00–close).

## Objective
```
Minimize(
  1000 * sum(x[UNFILLED, slot]) +
   10 * sum(changed[staff, slot])
)
```

- **Coverage-first**: unfilled penalty dominates.
- **Stability**: prefer sticking to `lastApprovedAssignments` when provided.

## Inputs (OptimizeRequest)
- Staff: id, name, roles, availability (weekly + exceptions).
- ShiftSlots: slotId, venueId, weekday (1=Mon), date, start/end, role.
- Locked assignments: map slotId → staffId (optional).
- Last approved roster: map slotId → staffId (optional soft preference).

## Outputs (OptimizeResponse)
- Assignments: map slotId → staffId (or `UNFILLED`).
- Reasons: simple reason per slot.
- Unfilled list.
