# Architecture

This proof-of-concept is split into two deployable surfaces:

- **Admin Web App (Flutter Web + Firebase Hosting):** Authenticates admins, provides CRUD over venues, roles, staff, availability, templates, and a roster generation/export surface. Talks to Firestore for data and calls the optimizer HTTP API.
- **Optimizer Service (Python FastAPI + OR-Tools):** Receives a canonical week description, runs a CP-SAT model, and returns slot assignments with reasons. Can be run locally or containerized for Cloud Run.

## Data Flow
1. Admin signs in (Firebase Auth, email/password).
2. Admin manages reference data (venues, roles, staff, availability, templates) in Firestore.
3. Admin selects a week and clicks **Generate roster**.
4. Admin app expands templates into canonical shift slots and posts to `/optimize`.
5. Optimizer returns assignments, unfilled slots, and reasons; admin can lock slots and re-run.
6. Admin saves roster as Draft, then marks Approved; the last approved roster is fed back as a soft preference in future generations.
7. Admin exports a Deputy-friendly CSV (one row per slot) for later import/mapping.

## Deployment Notes
- Firebase Hosting serves the Flutter web build.
- Optimizer defaults to local `uvicorn` for development; optional container scaffold can target Cloud Run.
- Keep free-tier friendly: Firestore + Auth only, no paid add-ons required for the POC.
