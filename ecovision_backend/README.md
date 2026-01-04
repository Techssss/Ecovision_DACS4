# EcoVision Backend

Backend API for EcoVision mobile application - Air quality monitoring and route planning.

## Features

- 🔐 Authentication & Authorization (JWT)
- 🌬️ Air Quality Index (AQI) monitoring
- 📊 Pollution reporting with YOLOv8 detection
- 🗺️ Route calculation with AQI integration
- 💬 AI Chatbot (LangChain + OpenAI)
- 🤖 AI Recommendations
- 👤 User management
- 🔔 Push notifications

## Tech Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL
- **Cache**: Redis
- **ML**: YOLOv8 (Ultralytics)
- **AI**: LangChain, OpenAI
- **Routing**: OSRM

## Setup

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+

### Installation

1. Clone the repository
2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

5. Run database migrations:
```bash
alembic upgrade head
```

6. Seed database (optional):
```bash
python scripts/seed_data.py
```

7. Run the server:
```bash
uvicorn app.main:app --reload
```

## Docker

```bash
docker-compose up -d
```

## API Documentation

Once the server is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Project Structure

```
ecovision_backend/
├── app/
│   ├── main.py              # FastAPI app
│   ├── config.py            # Configuration
│   ├── database.py          # Database setup
│   ├── core/                # Core modules
│   ├── auth/                # Authentication
│   ├── aqi/                 # AQI system
│   ├── reports/             # Reports + YOLOv8
│   ├── routes/              # Route calculation
│   ├── chat/                # AI Chatbot
│   ├── recommendations/     # AI Recommendations
│   ├── users/               # User management
│   ├── notifications/        # Notifications
│   └── utils/               # Utilities
├── migrations/              # Database migrations
├── tests/                   # Tests
├── scripts/                 # Utility scripts
└── models/                  # AI models
```

## Development

### Run tests
```bash
pytest
```

### Code formatting
```bash
black app/
```

### Create migration
```bash
alembic revision --autogenerate -m "Description"
```

## License

MIT

