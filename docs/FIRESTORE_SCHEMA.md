# Firestore Schema (POC)

All collections live under a single organization namespace to keep the POC simple.

```
orgs/{orgId}
  venues/{venueId}
    roles/{roleId}
      - name: string
    staff/{staffId}
      - name: string
      - roles: string[]
      - externalId: string? (optional)
    availability/{staffId}
      - weekly: [{ weekday: int (1=Mon), start: "HH:MM", end: "HH:MM" }]
      - exceptions: [{ date: "YYYY-MM-DD", available: boolean, start?: "HH:MM", end?: "HH:MM" }]
    templates/{templateId}
      - weekday: int (1=Mon)
      - blocks: [{ start: "HH:MM", end: "HH:MM", role: string, requiredCount: int }]
    rosters/{rosterId}
      - weekStart: "YYYY-MM-DD" (Monday)
      - status: "draft" | "approved"
      - createdAt: timestamp
      - updatedAt: timestamp
      - sourceRosterId: string? (optional reference to last approved roster)
      - assignments: { slotId: staffId }
```

### Notes
- Templates expand into canonical ShiftSlots when generating a week (one entry per required headcount).
- Use a **stable SlotId** (e.g., `{venueId}-{weekday}-{start}-{end}-{role}-{index}`) so CSV exports remain predictable.
- Availability stores both weekly patterns and date-specific overrides.
- Roster documents hold the last approved roster to support stability preferences during regeneration.
