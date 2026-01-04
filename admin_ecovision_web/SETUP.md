# 🚀 HƯỚNG DẪN SETUP ADMIN DASHBOARD

## Cài Đặt

### 1. Cài đặt Dependencies

```bash
cd admin_ecovision_web
npm install
```

### 2. Chạy Development Server

```bash
npm run dev
```

Dashboard sẽ chạy tại: **http://localhost:3000**

### 3. Build Production

```bash
npm run build
npm run preview
```

## Cấu Hình

### Backend API URL

Mặc định: `http://localhost:8000/api/v1`

Có thể thay đổi trong `src/lib/api.ts`:

```typescript
const API_BASE_URL = '/api/v1'  // Proxy qua vite.config.ts
```

### Authentication

Hiện tại chưa có authentication. Cần thêm:

1. Login page
2. Token storage
3. Auth interceptor (đã có sẵn trong `api.ts`)

## Features

### ✅ Đã Hoàn Thành

1. **Dashboard Overview**
   - AQI trung bình
   - Tổng số reports
   - Reports đang chờ
   - Reports đã xử lý
   - Reports theo loại ô nhiễm
   - Reports theo độ nghiêm trọng

2. **Reports Management**
   - Danh sách tất cả reports
   - Filter theo status, type, severity
   - Pagination
   - Xem chi tiết report

3. **Report Detail**
   - Thông tin report đầy đủ
   - Hình ảnh với YOLOv8 detections
   - Vị trí trên bản đồ (Leaflet)
   - Phân tích YOLOv8 (tổng hợp detections)
   - Cập nhật status

4. **AQI Statistics**
   - AQI trung bình, max, min
   - Biểu đồ theo ngày (Line & Bar chart)
   - Filter theo số ngày (7/14/30)

## API Endpoints

### Dashboard Stats
```
GET /api/v1/admin/dashboard/stats
```

### Reports
```
GET /api/v1/admin/reports?status=pending&type=air_pollution&severity=high
GET /api/v1/admin/reports/{id}
PUT /api/v1/admin/reports/{id}/status?new_status=resolved&message=...
```

### AQI Stats
```
GET /api/v1/admin/aqi/stats?days=7
```

## Tech Stack

- **React 18** + **TypeScript**
- **Vite** - Build tool
- **React Router** - Routing
- **React Query** - Data fetching
- **Tailwind CSS** - Styling
- **Recharts** - Charts
- **React Leaflet** - Maps
- **Lucide React** - Icons

## Cấu Trúc

```
admin_ecovision_web/
├── src/
│   ├── components/
│   │   └── Layout.tsx          # Sidebar layout
│   ├── pages/
│   │   ├── Dashboard.tsx       # Dashboard overview
│   │   ├── Reports.tsx         # Reports list
│   │   ├── ReportDetail.tsx    # Report detail với YOLOv8
│   │   └── AQIStats.tsx        # AQI statistics
│   ├── lib/
│   │   └── api.ts              # API client
│   ├── App.tsx                 # Main app
│   └── main.tsx                # Entry point
├── package.json
├── vite.config.ts
└── tailwind.config.js
```

## Next Steps

1. ✅ Thêm authentication
2. ✅ Thêm role-based access control
3. ✅ Thêm real-time updates (WebSocket)
4. ✅ Export reports to PDF/Excel
5. ✅ Advanced filtering và search

