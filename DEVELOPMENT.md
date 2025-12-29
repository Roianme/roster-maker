# Development Guide

## Development Workflow

### Backend Development

1. **Setup Python virtual environment**
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   pip install -r requirements-dev.txt  # For testing
   ```

2. **Run the backend server**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

3. **Test the API**
   ```bash
   pytest
   ```

4. **Access API documentation**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

### Frontend Development

1. **Setup Flutter**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run in Chrome**
   ```bash
   flutter run -d chrome
   ```

3. **Build for production**
   ```bash
   flutter build web
   ```

4. **Analyze code**
   ```bash
   flutter analyze
   ```

### Database Development

1. **View Firestore data**
   - Firebase Console: https://console.firebase.google.com
   - Navigate to Firestore Database

2. **Update security rules**
   - Edit `firebase/firestore.rules`
   - Deploy: `firebase deploy --only firestore:rules`

3. **Update indexes**
   - Edit `firebase/firestore.indexes.json`
   - Deploy: `firebase deploy --only firestore:indexes`

## Adding New Features

### Adding a New CRUD Screen

1. Create model in `frontend/lib/models/`
2. Add Firestore methods in `frontend/lib/services/firestore_service.dart`
3. Create screen in `frontend/lib/screens/`
4. Add navigation in `frontend/lib/screens/home_screen.dart`

### Adding New Backend Endpoints

1. Define schemas in `backend/app/models/schemas.py`
2. Create route in `backend/app/api/`
3. Add business logic in `backend/app/services/`
4. Include router in `backend/app/main.py`

### Modifying the Roster Algorithm

1. Edit `backend/app/services/roster_solver.py`
2. Update constraints in the `generate_roster` method
3. Test with various scenarios
4. Document changes in code comments

## Testing

### Backend Tests

```bash
cd backend
pytest tests/ -v
```

### Frontend Tests

```bash
cd frontend
flutter test
```

## Common Tasks

### Reset Firestore Data

Use Firebase Console to delete collections, or use the Firebase Admin SDK.

### Update Dependencies

Backend:
```bash
cd backend
pip install --upgrade -r requirements.txt
pip freeze > requirements.txt
```

Frontend:
```bash
cd frontend
flutter pub upgrade
```

### Debug Issues

Backend:
- Check logs in terminal
- Use `/docs` endpoint to test API manually
- Add print statements or use Python debugger

Frontend:
- Use Chrome DevTools
- Check browser console for errors
- Use Flutter DevTools: `flutter run -d chrome --devtools`

## Code Style

### Python
- Follow PEP 8
- Use type hints
- Write docstrings for functions

### Dart/Flutter
- Follow Effective Dart guidelines
- Use `flutter analyze` to check code
- Prefer const constructors where possible

## Environment Variables

Create `.env` file in backend directory (based on `.env.example`):

```bash
cd backend
cp .env.example .env
# Edit .env with your values
```

## Troubleshooting

### Flutter build fails
```bash
flutter clean
flutter pub get
flutter build web
```

### Backend dependencies conflict
```bash
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

### Firebase deployment fails
```bash
firebase login
firebase use your-project-id
firebase deploy
```

### CORS errors in browser
- Check backend CORS configuration in `app/main.py`
- Ensure frontend URL is in allowed origins
- Clear browser cache

## Performance Tips

1. **Firestore queries**: Use indexes for complex queries
2. **Flutter web**: Use `flutter build web --release` for production
3. **Backend**: Use async/await for I/O operations
4. **Solver**: Limit problem size for faster solutions
