# Roster Maker

An Admin-only restaurant roster generator for Australia/Melbourne that outputs a roster (grid) and exports a Deputy-friendly CSV. This tool is NOT an all-in-one HR app; it replaces the manual roster-building step by generating a weekly roster that an Admin can re-enter/import.

## Architecture

This is a monorepo containing:

- **Frontend**: Flutter Web Admin app
- **Backend**: Python FastAPI with OR-Tools CP-SAT solver
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Hosting**: Firebase Hosting

## Features

### CRUD Operations
- **Venues**: Manage restaurant locations
- **Roles**: Define job roles (chef, waiter, supervisor, etc.)
- **Staff**: Manage employee records with role assignments
- **Availability**: Track staff availability by weekday (Mon-Sun)
- **Templates**: Define weekday shift templates with shift blocks and counts

### Roster Generation
- Uses OR-Tools CP-SAT constraint solver
- Coverage-first strategy (ensures all shifts are covered)
- Minimizes roster changes week-to-week
- Supports locked shifts (fixed assignments)
- Provides assignment reasons for transparency

### CSV Export
- One row per shift slot
- Format: SlotId, Venue, Date, StartTime, EndTime, Role, Employee
- Deputy-friendly format for import

## Project Structure

```
roster-maker/
├── frontend/                 # Flutter Web App
│   ├── lib/
│   │   ├── models/          # Data models
│   │   ├── screens/         # UI screens
│   │   ├── services/        # Firebase & API services
│   │   ├── widgets/         # Reusable components
│   │   └── main.dart        # App entry point
│   ├── web/                 # Web-specific files
│   └── pubspec.yaml         # Flutter dependencies
│
├── backend/                 # Python FastAPI
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── models/         # Pydantic schemas
│   │   ├── services/       # Business logic (solver)
│   │   └── main.py         # FastAPI entry point
│   └── requirements.txt    # Python dependencies
│
├── firebase/               # Firebase configuration
│   ├── firestore.rules     # Security rules
│   └── firestore.indexes.json  # Database indexes
│
├── firebase.json           # Firebase hosting config
├── .firebaserc             # Firebase project config
└── package.json            # Root workspace config
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Python 3.8+
- Node.js & npm
- Firebase CLI
- Firebase project (created via Firebase Console)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Roianme/roster-maker.git
   cd roster-maker
   ```

2. **Install dependencies**
   ```bash
   # Install npm dependencies (Firebase tools)
   npm install
   
   # Install Python dependencies
   cd backend
   pip install -r requirements.txt
   cd ..
   
   # Install Flutter dependencies
   cd frontend
   flutter pub get
   cd ..
   ```

3. **Configure Firebase**
   
   a. Create a Firebase project at https://console.firebase.google.com
   
   b. Enable Firebase Authentication (Email/Password)
   
   c. Enable Firestore Database
   
   d. Update `frontend/lib/main.dart` with your Firebase config:
   ```dart
   await Firebase.initializeApp(
     options: const FirebaseOptions(
       apiKey: 'YOUR_API_KEY',
       authDomain: 'YOUR_AUTH_DOMAIN',
       projectId: 'YOUR_PROJECT_ID',
       storageBucket: 'YOUR_STORAGE_BUCKET',
       messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
       appId: 'YOUR_APP_ID',
     ),
   );
   ```
   
   e. Update `.firebaserc` with your project ID:
   ```json
   {
     "projects": {
       "default": "your-project-id"
     }
   }
   ```
   
   f. Deploy Firestore rules and indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

4. **Create an admin user**
   
   In Firebase Console > Authentication, create a user with email/password.

### Development

1. **Start the backend API**
   ```bash
   npm run dev:backend
   # or
   cd backend
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Start the Flutter web app**
   ```bash
   npm run dev:frontend
   # or
   cd frontend
   flutter run -d chrome
   ```

3. **Access the app**
   - Frontend: http://localhost:XXXXX (Flutter will assign a port)
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

### Deployment

1. **Build the Flutter web app**
   ```bash
   npm run build:frontend
   # or
   cd frontend
   flutter build web
   ```

2. **Deploy to Firebase Hosting**
   ```bash
   npm run deploy
   # or
   firebase deploy
   ```

3. **Deploy the backend**
   
   The backend can be deployed to:
   - Cloud Run (recommended for Firebase integration)
   - AWS Lambda with API Gateway
   - Any Python hosting service
   
   For Cloud Run:
   ```bash
   cd backend
   gcloud run deploy roster-api \
     --source . \
     --platform managed \
     --region australia-southeast1
   ```
   
   Update `frontend/lib/services/roster_service.dart` with the deployed backend URL.

## Usage

### 1. Manage Master Data

- **Venues**: Add your restaurant locations
- **Roles**: Define all job roles (chef, waiter, bartender, etc.)
- **Staff**: Add employees and assign their roles
- **Availability**: Set which days each staff member is available

### 2. Create Shift Templates

For each venue and weekday:
- Define shift blocks (start time, end time, role, count)
- Optionally specify a supervisor role

Example Monday template:
- 09:00-17:00, Chef, Count: 2
- 17:00-23:00, Waiter, Count: 3
- 17:00-23:00, Bartender, Count: 1

### 3. Generate Roster

1. Go to the Roster screen
2. Select venue and week start date
3. Click "Generate Roster"
4. Review the generated assignments
5. Lock any shifts that should not change
6. Regenerate if needed
7. Export to CSV for import into Deputy or other systems

## Data Model

### Fixed Week: Monday - Sunday (Melbourne timezone)

All operations use a fixed Mon-Sun week structure for Melbourne, Australia (Australia/Melbourne timezone).

### Collections

- `venues`: Restaurant locations
- `roles`: Job roles
- `staff`: Employee records
- `availability`: Staff availability by weekday
- `templates`: Shift templates by venue and weekday
- `rosters`: Generated rosters (optional persistence)

## Roster Generation Algorithm

The backend uses Google OR-Tools CP-SAT solver with the following strategy:

1. **Coverage First**: All shifts must be assigned (hard constraint)
2. **Qualification**: Staff can only be assigned to roles they're qualified for
3. **Availability**: Staff can only work on days they're available
4. **Locks**: Locked shifts maintain their assignments
5. **Minimize Changes**: Prefer keeping existing assignments (soft constraint)

Assignment reasons are provided for each shift explaining why staff were assigned.

## Security

- Admin-only access enforced via Firebase Security Rules
- All Firestore operations require authentication
- CORS configured for web app access
- In production, implement role-based access control

## Limitations (POC)

This is a proof-of-concept with simplified features:

- Single venue support in roster generation
- Basic availability (full day available/unavailable)
- No shift preference modeling
- No fairness constraints (equal hours distribution)
- No skill level differentiation
- No break time management
- No labor cost optimization

## License

This project is proprietary and confidential.

## Support

For issues or questions, contact the development team.
