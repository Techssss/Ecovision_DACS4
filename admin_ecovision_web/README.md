# 🌐 ECOVISION ADMIN DASHBOARD

Web dashboard cho admin quản lý EcoVision system.

## Features

- 📊 **AQI Statistics**: Hiển thị AQI trung bình, max, min
- 📝 **Reports Management**: Quản lý tất cả reports từ users
- 🤖 **YOLOv8 Analysis**: Xem kết quả phân tích từ YOLOv8
- 🗺️ **Location Mapping**: Xem vị trí reports trên bản đồ
- 📈 **Dashboard Stats**: Thống kê tổng quan

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **UI Library**: Tailwind CSS + shadcn/ui
- **Charts**: Recharts
- **Maps**: Leaflet
- **State Management**: React Query

## Setup

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build
```

## API Endpoints

- `GET /api/v1/admin/dashboard/stats` - Dashboard statistics
- `GET /api/v1/admin/reports` - List all reports
- `GET /api/v1/admin/reports/{id}` - Report details with YOLOv8 analysis
- `GET /api/v1/admin/aqi/stats` - AQI statistics
- `PUT /api/v1/admin/reports/{id}/status` - Update report status

