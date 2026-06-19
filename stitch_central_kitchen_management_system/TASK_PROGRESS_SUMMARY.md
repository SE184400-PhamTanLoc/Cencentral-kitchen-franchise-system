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

### ❌ CHƯA BẮT ĐẦU - Backend (.NET API)

| Task | Mô tả | File cần tạo |
|------|-------|:-----------:|
| **THAI_API_01** | `POST /api/franchise/orders` - Tiếp nhận đơn đặt hàng từ cửa hàng | `Controllers/FranchiseOrdersController.cs`, `Services/OrderService.cs`, `Repositories/FranchiseOrderRepository.cs` |
| **THAI_API_02** | `GET /api/franchise/orders/{storeId}` - DS đơn hàng theo cửa hàng | Thêm method vào controller/service trên |
| **THAI_API_03** | API cập nhật tồn kho Franchise sau khi nhận hàng | `PUT /api/franchise/inventory` |
| **THAI_API_04** | API ghi nhận tiêu thụ / hao hụt hàng ngày | `POST /api/franchise/inventory/consume` |

### ❌ CHƯA BẮT ĐẦU - Frontend (Flutter)

| Task | Mô tả | File cần tạo |
|------|-------|:-----------:|
| **THAI_FLUT_01** | `cart_order_provider.dart` - State giỏ hàng, tính tổng tiền | `business/providers/` |
| **THAI_FLUT_02** | Màn hình Giỏ hàng (Shopping Cart) | `presentation/screens/franchise/` |
| **THAI_FLUT_03** | Màn hình Xác nhận đơn hàng & Thanh toán (Checkout) | `presentation/screens/franchise/` |
| **THAI_FLUT_04** | 1 Unit Test kiểm tra tính tổng tiền giỏ hàng | `test/` |

---

## 4. TRẦN THÁI THỊNH (Module 4: Điều phối, Bản đồ & Real-time)

### ❌ CHƯA BẮT ĐẦU - Backend (.NET API)

| Task | Mô tả | File cần tạo |
|------|-------|:-----------:|
| **ThaiThinh_API_01** | `PUT /api/kitchen/orders/{id}/status` - Duyệt/Sản xuất/Xuất kho | `Controllers/KitchenOrdersController.cs` |
| **ThaiThinh_API_02** | Tích hợp Firebase Cloud Messaging (FCM) gửi thông báo | `Services/NotificationService.cs` |
| **ThaiThinh_API_03** | GPS Delivery - Lưu & lấy tọa độ xe giao hàng | `Controllers/DeliveryController.cs`, `api/delivery/location` |
| **ThaiThinh_API_04** | Chat nội bộ giữa Cửa hàng và Bếp | `Controllers/ChatController.cs` |

### ❌ CHƯA BẮT ĐẦU - Frontend (Flutter)

| Task | Mô tả | File cần tạo |
|------|-------|:-----------:|
| **ThaiThinh_FLUT_01** | `delivery_chat_provider.dart` - Quản lý tin nhắn, thông báo, GPS | `business/providers/` |
| **ThaiThinh_FLUT_02** | Màn hình Thông báo (Notifications) | `presentation/screens/` |
| **ThaiThinh_FLUT_03** | Tích hợp Maps - Hiển thị bếp, cửa hàng, xe tải | `presentation/screens/delivery/` |
| **ThaiThinh_FLUT_04** | Màn hình Nhắn tin (Chat) | `presentation/screens/chat/` |

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
| **Nguyễn Hưng Thịnh** (Module 3) | ❌ 0/4 | ❌ 0/4 | ❌ 0/1 | 0% |
| **Trần Thái Thịnh** (Module 4) | ❌ 0/4 | ❌ 0/4 | ❌ 0/3 | 0% |

### Lộ trình ưu tiên cho các tuần tới:
1. **Nguyễn Hưng Thịnh** - Triển khai ngay Module 3 (Franchise Order) vì Module 2 (Kho & BOM) đã hoàn thành và cần dữ liệu đầu vào từ đơn hàng.
2. **Trần Thái Thịnh** - Bắt đầu với Module 4.1 (Duyệt đơn & Thông báo) + DEV (Deploy Backend).
3. **Phạm Tấn Lộc** - Bổ sung Unit Test còn thiếu.
4. **Trần Đức Linh** - Hỗ trợ các Module khác khi cần tích hợp (ví dụ: tích hợp BOM với đơn hàng, batch với delivery).