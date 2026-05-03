# EcoVision

A platform for monitoring air quality, reporting pollution, and promoting environmental awareness.

## Overview

EcoVision is a full-stack application with three components:

- **Backend** — FastAPI + Groq AI + YOLOv8
- **Mobile App** — Flutter
- **Admin Dashboard** — React + TypeScript

## Project Structure

```
EcoVision/
├── ecovision_backend/      # FastAPI Backend
│   ├── app/                # Source code
│   ├── models/             # AI models (YOLOv8)
│   ├── scripts/            # Utility scripts
│   └── docs/               # Documentation
│
├── ecovision_frontend/     # Flutter Mobile App
│   ├── lib/
│   │   ├── features/
│   │   ├── core/
│   │   └── common/
│   └── docs/
│
├── admin_ecovision_web/    # React Admin Dashboard
│   ├── src/
│   │   ├── pages/
│   │   ├── components/
│   │   └── lib/
│   └── public/
│
├── SETUP_GUIDE.md
├── COMMANDS.md
└── YOLO_MODEL_GUIDE.md
```

## Features

### Backend

- Vietnamese chatbot powered by Groq (Llama 3.3 70B)
- YOLOv8 pollution detection: graffiti, garbage, sand on road
- Real-time AQI data
- Fast report creation with optional on-demand AI analysis

### Mobile App

- Real-time AQI monitoring
- Photo-based pollution reporting with AI analysis
- Chat assistant for environmental advice
- Route planning (cleanest routes)
- Gamification system: points, ranks, rewards

### Admin Dashboard

- Report review and management
- YOLOv8 detection result viewer
- Statistics dashboard with charts
- User management and permissions

## Prerequisites

- Python 3.11+
- Flutter SDK 3.35+
- Node.js 18+
- PostgreSQL or SQLite

## Setup

### 1. Backend

```bash
cd ecovision_backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your keys
python scripts/init_sqlite_db.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Runs at `http://localhost:8000`

### 2. Mobile App

```bash
cd ecovision_frontend
flutter pub get
flutter run
```

### 3. Admin Dashboard

```bash
cd admin_ecovision_web
npm install
npm run dev
```

Runs at `http://localhost:3000`

## Configuration

### Backend `.env`

```env
DATABASE_URL=sqlite:///./ecovision.db
SECRET_KEY=your-secret-key
GROQ_API_KEY=your-groq-api-key
YOLO_MODEL_PATH=models/yolov8_pollution.pt

# Optional
CLOUDINARY_CLOUD_NAME=your-cloud-name
USE_CLOUDINARY=false
```

### Mobile App

Update the base URL in:

- `lib/features/auth/data/services/auth_service.dart`
- `lib/features/chat/data/services/chat_service.dart`

```dart
// Android Emulator
baseUrl: 'http://10.0.2.2:8000/api/v1'

// iOS Simulator
baseUrl: 'http://localhost:8000/api/v1'

// Physical Device
baseUrl: 'http://YOUR_IP:8000/api/v1'
```

## Performance

| Component | Target |
|---|---|
| Backend API | < 200ms |
| Report creation | 2–4s (fast mode) |
| YOLOv8 detection | 5–6s (on-demand) |
| Chat response | 0.5–1s |
| Mobile app | 60 FPS |

## Testing

### Backend

```bash
cd ecovision_backend
curl http://localhost:8000/health
pytest
```

### Mobile App

```bash
cd ecovision_frontend
flutter test
flutter drive --target=test_driver/app.dart
```

### Admin Dashboard

```bash
cd admin_ecovision_web
npm test
```

## Deployment

### Backend (Docker)

```bash
cd ecovision_backend
docker-compose up -d
```

### Mobile App

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Admin Dashboard

```bash
cd admin_ecovision_web
npm run build
# Deploy the dist/ folder
```

## Documentation

| File | Description |
|---|---|
| `SETUP_GUIDE.md` | Initial project setup |
| `COMMANDS.md` | Common commands reference |
| `YOLO_MODEL_GUIDE.md` | YOLOv8 model documentation |
| `ecovision_backend/PRODUCTION_READY.md` | Backend production guide |
| `ecovision_backend/CHATBOT_GUIDE.md` | Chatbot configuration |
| `ecovision_frontend/BACKEND_API_GUIDE.md` | API integration guide |
| API Docs | `http://localhost:8000/docs` (when server is running) |

## Tech Stack

### Backend
- FastAPI, SQLite (dev) / PostgreSQL (prod)
- Groq API (Llama 3.3 70B), YOLOv8
- JWT authentication, Cloudinary (optional)

### Mobile App
- Flutter, Riverpod, Clean Architecture
- Google Maps / Mapbox, Leaflet

### Admin Dashboard
- React + TypeScript, Vite
- Tailwind CSS + shadcn/ui, Recharts

## Status

| Component | Status |
|---|---|
| Backend | Production ready |
| Admin Dashboard | Production ready |
| Mobile App | ~50% API integrated |

### Mobile App Integration Progress

- Auth — done
- Chat — done
- AQI — done
- Report — partial
- Map — mock data
- Profile — mock data

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a pull request

***

Version 2.0.0 — Last updated: 2024-11-24
