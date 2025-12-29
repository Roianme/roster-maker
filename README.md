# roster-maker (POC)

An Admin-only restaurant roster generator for Australia/Melbourne that outputs a roster grid and a Deputy-friendly CSV. Coverage-first, stability-second.

## Repository Layout
- `admin_app/` — Flutter Web admin dashboard (Firebase Auth + Firestore).
- `optimizer_service/` — FastAPI + OR-Tools optimizer.
- `docs/` — Architecture, schema, optimizer model, CSV spec, seed data.
- `scripts/` — PowerShell helpers for Windows workflows.

## Prerequisites (Windows-friendly)
- Flutter SDK (enable web: `flutter config --enable-web`)
- Firebase CLI (`npm install -g firebase-tools`)
- Python 3.10+ with `venv`
- Node.js 18+ (for Firebase CLI)
- Git + PowerShell

## Quick Start
1) Clone and install Flutter deps:
```powershell
cd admin_app
flutter pub get
```

2) Configure Firebase:
```powershell
firebase login
flutterfire configure --project <your-project-id> --platforms web
```
Replace TODOs in `admin_app/lib/firebase_options.dart`.

3) Run optimizer locally (port 8000):
```powershell
.\scripts\run_optimizer_local.ps1
```

4) Run Flutter web (Chrome):
```powershell
.\scripts\dev.ps1
```

5) Deploy web to Firebase Hosting:
```powershell
.\scripts\deploy_web.ps1 -FirebaseProject <your-project-id>
```

6) Optional: Deploy optimizer to Cloud Run:
```powershell
.\scripts\deploy_optimizer_cloudrun.ps1 -ProjectId <your-gcp-project>
```

## CSV Export
See `docs/CSV_EXPORT_SPEC.md` for column definitions and examples. Exports one row per ShiftSlot with stable SlotIds for Deputy-friendly mapping.

## Firestore Schema
See `docs/FIRESTORE_SCHEMA.md` for collections/fields (org/venue scoped, templates, rosters, etc.).

## Optimizer Model
See `docs/OPTIMIZER_MODEL.md` for constraints and objective weights (coverage-first, stability-second).

## Next Steps Checklist
- [ ] Configure Firebase project + auth users (admins only)
- [ ] Replace Firebase options with real values
- [ ] Enter venues/roles/staff/templates (seed examples in `docs/seed_data.json`)
- [ ] Run optimizer locally and generate a roster
- [ ] Approve a roster, then regenerate with locks to test stability
- [ ] Deploy web + optional optimizer Cloud Run
