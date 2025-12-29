# CSV Export Specification

One row per ShiftSlot to keep mapping to Deputy straightforward.

| Column | Type | Description |
| --- | --- | --- |
| VenueName | string | Human-friendly venue label |
| Date | string (YYYY-MM-DD) | Calendar date in Australia/Melbourne |
| Start | string (HH:MM) | Slot start time (24h) |
| End | string (HH:MM) | Slot end time (24h) |
| Role | string | Role name required for the slot |
| EmployeeName | string | Assigned staff display name (empty if unfilled) |
| SlotId | string | Stable identifier for the slot |
| Notes | string (optional) | Free-form notes / manager instructions |

## Example
```
VenueName,Date,Start,End,Role,EmployeeName,SlotId,Notes
Venue A,2025-02-03,09:00,17:00,Grill,Alex Lee,venueA-1-09:00-17:00-grill-0,
Venue A,2025-02-03,09:00,17:00,Fryer,Jamie Kim,venueA-1-09:00-17:00-fryer-0,"Keep fryer running until close"
Venue B,2025-02-04,11:00,18:30,Manager,,venueB-2-11:00-18:30-manager-0,"Unfilled; please backfill"
```

## Export Tips
- Use ISO dates and 24h times to remain Deputy-friendly.
- Keep SlotId stable between regenerations to reduce churn during re-import.
- Include a simple reason for unfilled slots in **Notes**.
