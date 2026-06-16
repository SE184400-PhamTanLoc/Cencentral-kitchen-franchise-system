# 📂 Cấu trúc Dự án Central Kitchen - PRM393 (Team 04)

Tài liệu này mô tả chi tiết cấu trúc thư mục của dự án **Central Kitchen**, phân chia trách nhiệm và các lớp kiến trúc của cả hai phần **Backend (.NET Web API)** và **Frontend (Flutter Mobile App)**.

---

## 🏗️ Sơ đồ cấu trúc thư mục tổng quát

```text
central_kitchen/ (Thư mục gốc của dự án)
├── central_kitchen_backend/             # Dự án Backend (.NET 8 Web API)
│   ├── Controllers/                     # Tầng Presentation (Hứng nhận HTTP Request)
│   │   ├── AuthController.cs            # [Lộc] API đăng nhập, quản lý user
│   │   ├── IngredientsController.cs     # [Duy] API danh mục kho, lô hàng
│   │   ├── OrdersController.cs          # [Thái Thịnh] API đặt hàng, tiêu thụ
│   │   └── DeliveryController.cs        # [Hưng Thịnh] API điều phối, GPS Maps, Chat
│   ├── Services/                        # Tầng Business Logic (Xử lý nghiệp vụ)
│   │   ├── AuthService.cs               # [Lộc] Logic sinh JWT Token, mã hóa mật khẩu
│   │   ├── InventoryService.cs          # [Duy] Logic quy đổi định mức sản xuất (BOM)
│   │   ├── OrderService.cs              # [Thái Thịnh] Logic kiểm tra hạn mức công nợ, tính tiền đơn
│   │   └── DeliveryService.cs           # [Hưng Thịnh] Logic lưu tọa độ xe, Real-time notification
│   ├── Repositories/                    # Tầng Data Access (Kết nối cơ sở dữ liệu)
│   │   ├── Data/
│   │   │   └── ApplicationDbContext.cs  # Khai báo DbContext (Entity Framework Core)
│   │   └── Models/                      # Các thực thể (Entities) ánh xạ PostgreSQL
│   │       ├── User.cs
│   │       ├── Role.cs
│   │       ├── Ingredient.cs
│   │       ├── Order.cs
│   │       └── OrderDetail.cs
│   ├── Program.cs                       # Cấu hình khởi chạy (DI, JWT, Swagger)
│   ├── appsettings.json                 # Cấu hình chuỗi kết nối Database & biến môi trường
│   └── central_kitchen_backend.sln      # File Solution mở bằng Visual Studio
│
├── central_kitchen_frontend/            # Dự án Frontend (Flutter Mobile App)
│   ├── android/                         # Cấu hình native cho Android
│   ├── ios/                             # Cấu hình native cho iOS
│   ├── pubspec.yaml                     # Quản lý thư viện phụ thuộc (Dio, Provider, Maps,...)
│   ├── README.md                        # Hướng dẫn setup và chạy Flutter
│   └── lib/                             # Thư mục mã nguồn chính (Dart)
│       ├── main.dart                    # Khởi chạy App & khai báo Provider toàn cục
│       ├── core/                        # Cấu hình dùng chung (Constants, Network, Utils)
│       │   ├── constants/               # API URLs, App Theme, Styles
│       │   ├── network/                 # Setup HTTP Client (Dio) & JWT Interceptors
│       │   └── utils/                   # Helpers (Format tiền tệ, date-time,...)
│       ├── data/                        # Tầng Dữ liệu (Raw Data & API)
│       │   ├── models/                  # Lớp Dữ liệu (DTO) ánh xạ từ JSON của API
│       │   ├── datasources/             # Gọi trực tiếp REST API endpoints
│       │   └── repositories/            # Mapper trung gian chuẩn hóa dữ liệu
│       ├── business/                    # Tầng State Management (Quản lý trạng thái)
│       │   └── providers/               # Các Provider quản lý trạng thái giao diện
│       │       ├── auth_provider.dart      # [Lộc] Trạng thái phiên đăng nhập, JWT
│       │       ├── inventory_provider.dart # [Duy] Bộ lọc, danh mục kho hàng
│       │       ├── cart_provider.dart      # [Thái Thịnh] Logic giỏ hàng, đặt hàng
│       │       └── delivery_provider.dart  # [Hưng Thịnh] Trạng thái GPS Maps, Chat
│       └── presentation/                # Tầng Giao diện người dùng
│           ├── widgets/                 # Các widgets tái sử dụng (Buttons, Inputs, Cards)
│           └── screens/                 # Các màn hình phân chia theo vai trò (Role)
│               ├── shared/              # Splash, Login, Profile
│               ├── admin/               # Quản lý Users, Stores
│               ├── kitchen/             # Nhân viên Bếp Trung Tâm (Sản xuất, Lô hàng)
│               └── franchise/           # Nhân viên Cửa Hàng Nhượng Quyền (Đặt hàng, Maps, Chat)
│
├── database/                            # Tài liệu & kịch bản Database
│   └── init_db.sql                      # Script khởi tạo Schema & Data mẫu trên PostgreSQL
│
└── .gitignore                           # Git ignore chung cho cả dự án (.NET & Flutter)

---

## 👥 Phân chia trách nhiệm thành viên (Task Assignment)

Dưới đây là bảng phân chia chi tiết các mảng tính năng cho từng thành viên từ Backend đến Frontend:

| Thành viên | Tính năng phụ trách | Thành phần Backend | Thành phần Frontend |
| :--- | :--- | :--- | :--- |
| **Lộc** | Xác thực & Quản trị tài khoản | `AuthController.cs`<br>`AuthService.cs`<br>`User.cs`, `Role.cs` | `auth_provider.dart`<br>`shared/` (Login Screen)<br>`admin/` (User/Store lists) |
| **Duy** | Quản lý kho hàng & Lô hàng (BOM) | `IngredientsController.cs`<br>`InventoryService.cs`<br>`Ingredient.cs` | `inventory_provider.dart`<br>`kitchen/` (Sản xuất, Lô hàng) |
| **Thái Thịnh** | Quản lý Đơn hàng & Tiêu thụ | `OrdersController.cs`<br>`OrderService.cs`<br>`Order.cs`, `OrderDetail.cs` | `cart_provider.dart`<br>`franchise/` (Giỏ hàng, đặt hàng) |
| **Hưng Thịnh** | Điều phối vận chuyển, GPS & Chat | `DeliveryController.cs`<br>`DeliveryService.cs` | `delivery_provider.dart`<br>`franchise/` (Bản đồ xe, Chat real-time) |

---

## 🛠️ Hướng dẫn cài đặt & Khởi chạy nhanh

### 1. Cơ sở dữ liệu (PostgreSQL)
- Sử dụng công cụ quản trị (pgAdmin / DBeaver) kết nối vào Postgres của bạn.
- Chạy toàn bộ file kịch bản tại [init_db.sql](file:///d:/Project_PRM393/database/init_db.sql) để tạo bảng và nạp dữ liệu mẫu.

### 2. Backend (.NET 8 API)
- Mở thư mục [central_kitchen_backend](file:///d:/Project_PRM393/central_kitchen_backend) (hoặc file solution `.sln`).
- Cấu hình lại thông tin kết nối Database trong file `appsettings.json`.
- Chạy lệnh sau để khởi động API:
  ```bash
  dotnet run --project Central_kitchen_API/Central_kitchen_API.csproj
  ```

### 3. Frontend (Flutter)
- Di chuyển vào thư mục [central_kitchen_frontend](file:///d:/Project_PRM393/central_kitchen_frontend).
- Tải các thư viện cần thiết:
  ```bash
  flutter pub get
  ```
- Khởi chạy ứng dụng:
  ```bash
  flutter run
  ```