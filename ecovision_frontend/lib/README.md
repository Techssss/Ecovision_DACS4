# Da Nang AI for Life - Cấu trúc Project

## 📁 Cấu trúc thư mục

```
lib/
├── core/                    # Code dùng chung toàn app
│   └── theme/              # Theme, colors, text styles
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── common/                  # Components dùng chung
│   └── widgets/
│       └── custom_bottom_nav.dart
│
├── features/                # Các tính năng chính
│   ├── home/               # Trang chủ
│   │   ├── domain/
│   │   │   └── models/
│   │   │       ├── air_quality_model.dart
│   │   │       └── recommendation_model.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           ├── custom_app_bar.dart
│   │           ├── air_quality_card.dart
│   │           ├── ai_recommendation_card.dart
│   │           └── flood_warning_card.dart
│   │
│   ├── map/                # Trang bản đồ (placeholder)
│   ├── report/             # Trang báo cáo (placeholder)
│   ├── chat/               # Trang trò chuyện (placeholder)
│   └── profile/            # Trang hồ sơ (placeholder)
│
├── routing/                # Navigation
│   └── app_router.dart
│
└── main.dart               # Entry point
```

## 🎨 Tính năng đã hoàn thành

### Trang chủ (Home)
- ✅ Custom App Bar với location và nút bản đồ
- ✅ Air Quality Card hiển thị AQI, nhiệt độ, độ ẩm
- ✅ AI Recommendations với 3 loại khuyến nghị
- ✅ Flood Warning Card
- ✅ Gradient background (xanh lá → xanh dương)

### Trang Map (Bản đồ)
- ✅ Google Maps với 3 routes màu sắc theo AQI
- ✅ Search bar điểm đến
- ✅ 3 chiến lược: Sạch nhất / Nhanh nhất / Cân bằng
- ✅ AQI Chart overlay với biểu đồ
- ✅ Draggable bottom sheet với danh sách routes
- ✅ Route cards chi tiết (AQI, thời gian, khoảng cách)
- ✅ Mock data đầy đủ (không cần API)
- ✅ Highlight route khi click

### Navigation
- ✅ Bottom Navigation Bar với 5 tabs
- ✅ Placeholder pages cho các trang khác

## 🚀 Chạy ứng dụng

```bash
# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

## 📝 Mở rộng tiếp theo

### Thêm API Integration
1. Tạo `features/home/data/repositories/`
2. Tạo `features/home/data/datasources/`
3. Implement API calls với Dio/http

### Thêm State Management
1. Tạo `features/home/presentation/providers/`
2. Sử dụng Riverpod providers cho data

### Hoàn thiện các trang khác
- Map Page: Tích hợp Google Maps
- Report Page: Form báo cáo sự cố
- Chat Page: AI Chatbot
- Profile Page: Thông tin người dùng

## 🎯 Dependencies

- `flutter_riverpod`: State management
- `google_fonts`: Custom fonts (Inter)
- `google_maps_flutter`: Google Maps integration
- `fl_chart`: Charts cho AQI visualization

## 💡 Lưu ý

- Hiện tại sử dụng mock data
- UI responsive với MediaQuery
- Code có comments tiếng Việt
- Tuân thủ feature-first architecture
