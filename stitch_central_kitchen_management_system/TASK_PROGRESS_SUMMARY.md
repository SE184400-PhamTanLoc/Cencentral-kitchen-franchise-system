# TỔNG QUAN TIẾN ĐỘ DỰ ÁN - CENTRAL KITCHEN FRANCHISE SYSTEM

> **Ngày cập nhật:** 20/06/2026  
> **Mục đích:** Ghi lại những gì đã hoàn thành và những gì còn lại cần làm cho từng thành viên.

---

## 1. TRẦN ĐỨC LINH (Module 2: Quản lý Kho & Định mức Sản xuất)

### ✅ ĐÃ HOÀN THÀNH - Backend (.NET API)

| Task | Mô tả | Trạng thái |
|------|-------|:----------:|
| **Linh_API_01** | `GET /api/ingredients` - Lấy danh mục nguyên vật liệu / bán thành phẩm | ✅ |
| **Linh_API_02** | `GET /api/ingredients/{id}` - Chi tiết nguyên liệu kèm hạn sử dụng, quy cách | ✅ |
| **Linh_API_03** | Batch Management - CRUD lô sản xuất (`/api/kitchen/batches`) | ✅ |
| **Linh_API_04** | Tính toán BOM tự động - `POST /api/kitchen/production-plan` (thủ công) + `POST /api/kitchen/production-plan/auto` (tự động từ đơn hàng chờ) + `GET /api/kitchen/orders/pending` | ✅ |

**Chi tiết Backend đã làm:**
- **Controllers:** `IngredientsController.cs`, `KitchenInventoryController.cs`
- **Services:** `InventoryService.cs` (429 dòng - đầy đủ logic quét BOM đệ quy `ExpandToRawMaterialsAsync`, tính shortage)
- **Repositories:** `IngredientRepository`, `BatchRepository`, `OrderRepository`, `RecipeRepository`
- **DTOs:** `IngredientSummaryDto`, `IngredientDetailDto`, `ProductionPlanRequestDto`, `ProductionPlanResponseDto`, `ProductionPlanItemDto`, `PendingOrderDto`, `PendingOrderDetailDto`, `BatchResponseDto`, `CreateBatchDto`, `UpdateBatchDto`, `RecipeInputDto`

### ✅ ĐÃ HOÀN THÀNH - Frontend (Flutter)

| Task | Mô tả | Trạng thái |
|------|-------|:----------:|
| **Linh_FLUT_01** | `inventory_provider.dart` - Quản lý state ingredients, batches, BOM, pending orders, tìm kiếm, lọc | ✅ |
| **Linh_FLUT_02** | Giao diện Danh sách Nguyên liệu (có thanh tìm kiếm + phân loại Raw/BFP) | ✅ |
| **Linh_FLUT_03** | Giao diện Chi tiết Nguyên liệu (thông số, batch, recipe inputs) | ✅ |
| **Linh_FLUT_04** | Giao diện BOM - Chia làm 2 phần: (1) Tự động từ đơn hàng chờ + (2) Thủ công | ✅ |

**Chi tiết Frontend đã làm:**
- **Datasource:** `inventory_datasource.dart` (đầy đủ CRUD + gọi pending orders + auto plan)
- **Models:** `IngredientModel`, `BatchModel`, `ProductionPlanModel`, `PendingOrderModel`, `PendingOrderDetailModel`
- **Screens:**
  - `kitchen_inventory_management_screen.dart` (1.442 dòng - Tổng quan, Nguyên liệu, Batches, BOM tabs)
  - `inventory_product_detail_screen.dart`
  - `inventory_product_list_screen.dart`
  - `kitchen_dashboard_screen.dart`

---

## 2. PHẠM TẤN LỘC (Module 1: Hệ thống & Xác thực)

### ✅ ĐÃ HOÀN THÀNH

| Task | Mô tả | Trạng thái |
|------|-------|:----------:|
| **LOC_API_01** | Khởi tạo ASP.NET Core Web API, cấu hình DbContext + Database | ✅ |
| **LOC_API_02** | JWT Bearer Authentication + BCrypt mã hóa mật khẩu | ✅ |
| **LOC_API_03** | `POST /api/auth/login` - Trả JWT Token chứa Role | ✅ |
| **LOC_API_04** | CRUD `/api/admin/users` - Quản lý tài khoản (Thêm, Xóa, Phân quyền) | ✅ |
| **LOC_API_05** | CRUD `/api/admin/stores` + `/api/admin/stores/kitchens` - Quản lý cửa hàng & bếp | ✅ |
| **LOC_FLUT_01** | Khởi tạo Flutter project, cấu hình dio, provider, router | ✅ |
| **LOC_FLUT_02** | Màn hình Đăng nhập (Login Screen) - Validation, UI hoàn chỉnh | ✅ |
| **LOC_FLUT_03** | `auth_provider.dart` - Login, lưu token, auto-login, điều hướng theo Role | ✅ |

### ❌ CÒN CẦN LÀM

| Task | Mô tả | Mức ưu tiên |
|------|-------|:-----------:|
| **LOC_FLUT_04** | Viết 1 Unit Test kiểm tra lưu/xóa Token khi Login/Logout | ⚠️ Trung bình |

**Ghi chú:** Phần Backend và Frontend core của Module 1 đã hoàn thiện. Chỉ còn thiếu 1 Unit Test.

---

## 3. NGUYỄN HƯNG THỊNH (Module 3: Giỏ hàng, Đặt hàng & Tiêu thụ)

### ✅ ĐÃ HOÀN THÀNH - Backend (.NET API)

| Task | Mô tả | Trạng thái |
|------|-------|:-----------:|
| **THAI_API_01** | `POST /api/franchise/orders` - Tiếp nhận đơn đặt hàng từ cửa hàng | ✅ |
| **THAI_API_02** | `GET /api/franchise/orders/{storeId}` - DS đơn hàng theo cửa hàng | ✅ |
| **THAI_API_03** | API cập nhật tồn kho Franchise sau khi nhận hàng (`PUT /api/franchise/inventory`) | ✅ |
| **THAI_API_04** | API ghi nhận tiêu thụ / hao hụt hàng ngày (`POST /api/franchise/inventory/consume`) | ✅ |

### ✅ ĐÃ HOÀN THÀNH - Frontend (Flutter)

| Task | Mô tả | Trạng thái |
|------|-------|:-----------:|
| **THAI_FLUT_01** | `cart_order_provider.dart` - State giỏ hàng, tính tổng tiền | ✅ |
| **THAI_FLUT_02** | Màn hình Giỏ hàng (Shopping Cart) - Giao diện Glassmorphism cực đẹp | ✅ |
| **THAI_FLUT_03** | Màn hình Xác nhận đơn hàng & Thanh toán (Checkout) | ✅ |
| **THAI_FLUT_04** | Giao diện Dashboard Franchise Staff hoàn chỉnh | ✅ |

---

## 4. TRẦN THÁI THỊNH (Module 4: Điều phối, Bản đồ & Real-time)

### ✅ ĐÃ HOÀN THÀNH - Backend (.NET API)

| Task | Mô tả | Trạng thái |
|------|-------|:-----------:|
| **ThaiThinh_API_01** | `PUT /api/kitchen/orders/{id}/status` - Duyệt/Sản xuất/Xuất kho | ✅ |
| **ThaiThinh_API_02** | Tích hợp xử lý tọa độ GPS cho xe giao hàng | ✅ |
| **ThaiThinh_API_03** | GPS Delivery - Lưu & lấy tọa độ xe giao hàng (`Controllers/DeliveryController.cs`) | ✅ |
| **ThaiThinh_API_04** | Chat nội bộ giữa Cửa hàng và Bếp (`Controllers/ChatController.cs`) | ✅ |

### ✅ ĐÃ HOÀN THÀNH - Frontend (Flutter)

| Task | Mô tả | Trạng thái |
|------|-------|:-----------:|
| **ThaiThinh_FLUT_01** | `delivery_chat_provider.dart` - Quản lý tin nhắn, GPS | ✅ |
| **ThaiThinh_FLUT_02** | Màn hình Thông báo (Notifications) - Glassmorphism cao cấp | ✅ |
| **ThaiThinh_FLUT_03** | Tích hợp Maps - Trình giả lập tọa độ giao hàng (Google Maps) | ✅ |
| **ThaiThinh_FLUT_04** | Màn hình Nhắn tin (Chat) theo thời gian thực | ✅ |

### ❌ CHƯA BẮT ĐẦU - DevOps & Đóng gói

| Task | Mô tả | Mức ưu tiên |
|------|-------|:-----------:|
| **ThaiThinh_DEV_01** | Deploy Backend .NET lên Internet (Render, SmarterASP, Ngrok) | 🔴 Cao - Cần cho chấm bài |
| **ThaiThinh_DEV_02** | Build Release APK / AppBundle | 🔴 Cao |
| **ThaiThinh_DEV_03** | Quay video / chụp ảnh minh chứng | 🟡 Trung bình |

---

## TỔNG KẾT TIẾN ĐỘ

| Thành viên | Backend | Frontend | Unit Test | % Hoàn thành |
|-----------|:-------:|:--------:|:---------:|:------------:|
| **Phạm Tấn Lộc** (Module 1) | ✅ 5/5 | ✅ 3/3 | ❌ 0/1 | ~92% |
| **Trần Đức Linh** (Module 2) | ✅ 4/4 | ✅ 4/4 | ✅ 0/0 | **100%** |
| **Nguyễn Hưng Thịnh** (Module 3) | ✅ 4/4 | ✅ 4/4 | ❌ 0/1 | ~95% |
| **Trần Thái Thịnh** (Module 4) | ✅ 4/4 | ✅ 4/4 | ❌ 0/3 | ~90% |

### Lộ trình ưu tiên cho các ngày tới:
1. **Phạm Tấn Lộc & Nhóm** - Viết Unit Tests.
2. **Trần Thái Thịnh** - Tiến hành Deploy server lên Internet và build bản APK.
3. **Cả nhóm** - Quay video Demo toàn diện dự án.