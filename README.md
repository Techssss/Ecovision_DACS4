# 🌱 EcoVision - Air Quality Monitoring & Pollution Reporting Platform

> A comprehensive platform for monitoring air quality, reporting pollution, and promoting environmental awareness.

---

## 📋 Project Overview

**EcoVision** is a full-stack application consisting of:
- 🤖 **AI-Powered Backend** (FastAPI + Groq AI + YOLOv8)
- 📱 **Mobile App** (Flutter)
- 💻 **Admin Dashboard** (React + TypeScript)

---

## 🏗️ Project Structure

```
EcoVision/
├── ecovision_backend/      # FastAPI Backend
│   ├── app/                # Source code
│   ├── models/             # AI models (YOLOv8)
│   ├── scripts/            # Utility scripts
│   └── docs/               # Documentation
│
├── ecovision_frontend/     # Flutter Mobile App
│   ├── lib/                # Source code
│   │   ├── features/       # Feature modules
│   │   ├── core/           # Core utilities
│   │   └── common/         # Shared widgets
│   └── docs/               # Documentation
│
├── admin_ecovision_web/    # React Admin Dashboard
│   ├── src/                # Source code
│   │   ├── pages/          # Page components
│   │   ├── components/     # Reusable components
│   │   └── lib/            # Utilities
│   └── public/             # Static assets
│
├── SETUP_GUIDE.md          # Initial setup guide
├── COMMANDS.md             # Common commands
└── YOLO_MODEL_GUIDE.md     # YOLOv8 model guide
```

---

## ✨ Key Features

### 🤖 **AI-Powered Backend**
- **Groq AI Chatbot** - Context-aware Vietnamese chatbot (Llama 3.3 70B)
- **YOLOv8 Detection** - Pollution detection (Graffiti, Garbage, Sand on road)
- **Real-time AQI** - Air quality monitoring
- **Smart Reports** - Fast report creation with on-demand AI analysis

### 📱 **Mobile App**
- **AQI Monitoring** - Real-time air quality data
- **Pollution Reporting** - Photo-based reporting with AI analysis
- **AI Chat Assistant** - Get environmental advice
- **Route Planning** - Find cleanest routes
- **User Gamification** - Points, ranks, rewards

### 💻 **Admin Dashboard**
- **Report Management** - Review and manage pollution reports
- **AI Analysis** - View YOLOv8 detection results
- **Statistics** - Dashboard with charts and metrics
- **User Management** - Manage users and permissions

---

## 🚀 Quick Start

### **Prerequisites**
- Python 3.11+
- Flutter SDK 3.35+
- Node.js 18+
- PostgreSQL/SQLite

### **1. Backend Setup**
```bash
cd ecovision_backend

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your keys

# Initialize database
python scripts/init_sqlite_db.py

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Backend will run at:** http://localhost:8000

### **2. Mobile App Setup**
```bash
cd ecovision_frontend

# Install dependencies
flutter pub get

# Run app
flutter run
```

### **3. Admin Dashboard Setup**
```bash
cd admin_ecovision_web

# Install dependencies
npm install

# Start dev server
npm run dev
```

**Admin dashboard will run at:** http://localhost:3000

---

## 📚 Documentation

### **Main Guides**
- **Setup Guide:** `SETUP_GUIDE.md` - Initial project setup
- **Commands:** `COMMANDS.md` - Common commands reference
- **YOLO Model:** `YOLO_MODEL_GUIDE.md` - YOLOv8 model documentation

### **Backend Documentation**
- **Production Guide:** `ecovision_backend/PRODUCTION_READY.md`
- **Chatbot Guide:** `ecovision_backend/CHATBOT_GUIDE.md`
- **Quick Start:** `ecovision_backend/QUICK_START_CHATBOT.md`
- **API Docs:** http://localhost:8000/docs (when running)

### **Frontend Documentation**
- **Chat Integration:** `ecovision_frontend/CHAT_INTEGRATION_GUIDE.md`
- **Backend API Guide:** `ecovision_frontend/BACKEND_API_GUIDE.md`
- **Cleanup Plan:** `ecovision_frontend/CLEANUP_PLAN.md`

---

## 🎯 Key Technologies

### **Backend**
- **Framework:** FastAPI
- **Database:** SQLite (dev) / PostgreSQL (prod)
- **AI/ML:** 
  - Groq API (Llama 3.3 70B) for chatbot
  - YOLOv8 for object detection
- **Authentication:** JWT
- **Image Storage:** Cloudinary (optional)

### **Mobile App**
- **Framework:** Flutter
- **State Management:** Riverpod
- **Architecture:** Clean Architecture
- **Maps:** Google Maps / Mapbox
- **HTTP Client:** http package

### **Admin Dashboard**
- **Framework:** React + TypeScript
- **Build Tool:** Vite
- **UI Library:** Tailwind CSS + shadcn/ui
- **Charts:** Recharts
- **Maps:** Leaflet

---

## 🔧 Configuration

### **Backend (.env)**
```env
# Database
DATABASE_URL=sqlite:///./ecovision.db

# Security
SECRET_KEY=your-secret-key

# AI
GROQ_API_KEY=your-groq-api-key
YOLO_MODEL_PATH=models/yolov8_pollution.pt

# Optional
CLOUDINARY_CLOUD_NAME=your-cloud-name
USE_CLOUDINARY=false
```

### **Mobile App**
Update base URL in:
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

---

## 📊 Performance

| Component | Performance |
|-----------|-------------|
| Backend API | <200ms response |
| Report Creation | 2-4s (fast mode) |
| YOLOv8 Detection | 5-6s (on-demand) |
| Chat Response | 0.5-1s (Groq) |
| Mobile App | 60 FPS |

---

## 🧪 Testing

### **Backend**
```bash
cd ecovision_backend

# Health check
curl http://localhost:8000/health

# Run tests
pytest
```

### **Mobile App**
```bash
cd ecovision_frontend

# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### **Admin Dashboard**
```bash
cd admin_ecovision_web

# Run tests
npm test
```

---

## 🚢 Deployment

### **Backend (Docker)**
```bash
cd ecovision_backend
docker-compose up -d
```

### **Mobile App**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### **Admin Dashboard**
```bash
cd admin_ecovision_web
npm run build
# Deploy dist/ folder to hosting
```

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📞 Support

- **Documentation:** Check `/docs` in each project
- **Issues:** GitHub Issues
- **Email:** support@ecovision.com

---

## 🎉 Status

### **Backend:** ✅ Production Ready
- ✅ All features implemented
- ✅ AI chatbot working (Groq)
- ✅ YOLOv8 detection optimized
- ✅ Database schema stable

### **Mobile App:** ⚠️ 50% API Integrated
- ✅ Chat integrated
- ✅ Auth integrated
- ✅ AQI integrated
- ⚠️ Report (partial)
- ⚠️ Map (mock)
- ⚠️ Profile (mock)

### **Admin Dashboard:** ✅ Production Ready
- ✅ Report management
- ✅ AI analysis view
- ✅ Statistics dashboard
- ✅ Delete functionality

---

## 🗺️ Roadmap

### **Q1 2025**
- [ ] Complete mobile app API integration
- [ ] Add offline mode
- [ ] Implement push notifications
- [ ] Add more pollution types

### **Q2 2025**
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Rewards system
- [ ] Community features

---

**Built with ❤️ for a cleaner environment 🌱**

**Version:** 2.0.0  
**Last Updated:** 2024-11-24
