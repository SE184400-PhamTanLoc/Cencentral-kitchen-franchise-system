# Task

### **DANH SÁCH TASK CÔNG VIỆC CHI TIẾT**

#### **1\. PHẠM TẤN LỘC (Module: Hệ thống, Xác thực & Quản trị Admin)**

**Phần Backend (.NET API):**

* [x] **Task LOC_API_01:** Khởi tạo dự án ASP.NET Core Web API, cấu hình DbContext kết nối với Database (SQL Server/PostgreSQL).  
* [x] **Task LOC_API_02:** Cài đặt thư viện JWT Bearer Authentication và cấu hình mã hóa mật khẩu (BCrypt hoặc Identity PasswordHasher).  
* [x] **Task LOC_API_03:** Viết API Endpoint POST /api/auth/login kiểm tra tài khoản và trả về JWT Token chứa thông tin Role.  
* [x] **Task LOC_API_04:** Viết nhóm API CRUD Quản lý tài khoản người dùng (/api/admin/users) (Thêm, xóa, phân quyền hệ thống).  
* [x] **Task LOC_API_05:** Viết nhóm API CRUD Quản lý danh mục Cửa hàng Franchise và thông tin các Bếp trung tâm (/api/admin/stores).

**Phần Frontend (Flutter Mobile):**

* [x] **Task LOC_FLUT_01:** Khởi tạo Base Project Flutter, cấu hình thư viện gọi API (dio), Router (go_router hoặc auto_route) và Quản lý trạng thái (provider hoặc flutter_bloc).  
* [x] **Task LOC_FLUT_02:** Xây dựng giao diện màn hình Đăng nhập (**Login Screen**) gồm các trường kiểm tra dữ liệu đầu vào (Validation).  
* [x] **Task LOC_FLUT_03:** Hiện thực auth_provider.dart để xử lý logic gọi API Login, lưu Token bảo mật bằng flutter_secure_storage và điều hướng màn hình theo đúng Role sau khi đăng nhập.  
* [ ] **Task LOC_FLUT_04:** Viết **1 Unit Test** trong Flutter để kiểm tra logic xử lý lưu/xóa Token khi người dùng Đăng nhập/Đăng xuất.

#### **2\. Trần Đức Linh (Module: Quản lý Kho, Nguyên liệu & Lô sản xuất)**

**Phần Backend (.NET API):**

* [x] **Task Linh_API_01:** Tạo các API Endpoints lấy danh mục nguyên vật liệu/bán thành phẩm cho cửa hàng xem (GET /api/ingredients).  
* [x] **Task Linh_API_02:** Viết API xem chi tiết một nguyên vật liệu, bao gồm thông tin hạn sử dụng và quy cách đóng gói (GET /api/ingredients/{id}).  
* [x] **Task Linh_API_03:** Viết API cập nhật số lượng kho thô đầu vào tại Bếp trung tâm và quản lý số lô sản xuất (Batch Management).  
* [x] **Task Linh_API_04:** Xây dựng logic tự động tính toán định mức (BOM): Khi nhận số lượng bán thành phẩm yêu cầu, hệ thống tự động quy đổi ra số lượng nguyên liệu thô cần xuất để sản xuất.

**Phần Frontend (Flutter Mobile):**

* [x] **Task Linh _FLUT_01:** Hiện thực inventory_provider.dart để quản lý trạng thái danh sách sản phẩm, bộ lọc và tìm kiếm từ API.  
* [x] **Task Linh_FLUT_02:** Thiết kế giao diện màn hình Danh sách Nguyên vật liệu (**Product List Screen**) có thanh tìm kiếm và phân loại.  
* [x] **Task Linh_FLUT_03:** Thiết kế giao diện màn hình Chi tiết Nguyên vật liệu (**Product Detail Screen**) hiển thị thông số và nút "Thêm vào giỏ".  
* [ ] **Task Linh_FLUT_04:** Viết **1 Widget Test** trong Flutter để kiểm tra giao diện danh sách nguyên liệu hiển thị đúng các thông tin (Tên, Giá, Hình ảnh) khi có dữ liệu đổ về.

#### **3\. NGUYỄN HƯNG THỊNH (Module: Giỏ hàng, Đặt hàng & Tiêu thụ Cửa hàng)**

**Phần Backend (.NET API):**

* [x] **Task THAI_API_01:** Viết API Endpoint tiếp nhận đơn đặt hàng nguyên liệu từ cửa hàng nhượng quyền gửi về (POST /api/franchise/orders).  
* [x] **Task THAI_API_02:** Viết API lấy danh sách đơn hàng và chi tiết đơn hàng theo từng cửa hàng (GET /api/franchise/orders/{storeId}).  
* [x] **Task THAI_API_03:** Viết API cập nhật số lượng tồn kho tại chỗ của từng cửa hàng Franchise sau khi nhận hàng thành công.  
* [x] **Task THAI_API_04:** Viết API ghi nhận lượng tiêu thụ món ăn hoặc báo cáo hao hụt/hủy hàng hàng ngày tại cửa hàng để tự động trừ kho tại chỗ.

**Phần Frontend (Flutter Mobile):**

* [x] **Task THAI_FLUT_01:** Hiện thực cart_order_provider.dart để xử lý logic thêm/bớt/sửa số lượng hàng trong giỏ, tính toán tổng tiền, thuế ngay tại local.  
* [x] **Task THAI_FLUT_02:** Thiết kế giao diện màn hình Giỏ hàng (**Shopping Cart Screen**) hiển thị danh sách món đã chọn và tổng tiền tạm tính.  
* [x] **Task THAI_FLUT_03:** Thiết kế giao diện màn hình Xác nhận đơn hàng & Thanh toán (**Checkout/Billing Screen**) để điền thông tin ghi chú và bấm gửi đơn.  
* [x] **Task THAI_FLUT_04:** Viết **1 Unit Test** trong Flutter để kiểm nghiệm tính chính xác của hàm tính tổng tiền giỏ hàng (bao gồm cộng dồn số lượng và tính tiền ship/thuế nếu có).

#### **4\. TRẦN THÁI THỊNH (Module: Điều phối, Bản đồ & Tương tác Real-time)**

**Phần Backend (.NET API):**

* [x] **Task ThaiThinh_API_01:** Viết API Endpoint cập nhật trạng thái đơn hàng dành cho nhân viên Bếp và Điều phối (PUT /api/kitchen/orders/{id}/status) (Duyệt, Đang sản xuất, Xuất kho).  
* [x] **Task ThaiThinh_API_02:** Tích hợp dịch vụ Firebase Cloud Messaging (FCM) ở phía Backend để tự động gửi thông báo xuống ứng dụng di động khi trạng thái đơn hàng thay đổi.  
* [x] **Task ThaiThinh_API_03:** Viết API lưu trữ tọa độ GPS do xe giao hàng gửi lên và API trả về tọa độ hiện tại của xe cho cửa hàng theo dõi (/api/delivery/location).  
* [x] **Task ThaiThinh_API_04:** Xây dựng API Endpoint phục vụ cho tính năng nhắn tin/chat nội bộ giữa Cửa hàng và Bếp trung tâm.

**Phần Frontend (Flutter Mobile):**

* [x] **Task ThaiThinh_FLUT_01:** Hiện thực delivery_chat_provider.dart để quản lý trạng thái danh sách tin nhắn, danh sách thông báo và tọa độ GPS.  
* [x] **Task ThaiThinh_FLUT_02:** Thiết kế màn hình Thông báo (**Notifications Screen**) nhận các tin tức cập nhật đơn hàng theo thời gian thực.  
* [x] **Task ThaiThinh_FLUT_03:** Tích hợp thư viện Maps_flutter, thiết kế màn hình Bản đồ (**Map Screen**) hiển thị vị trí của Bếp, vị trí Cửa hàng và vị trí xe tải đang giao hàng.  
* [x] **Task ThaiThinh_FLUT_04:** Thiết kế màn hình Nhắn tin (**Messaging/Chat Screen**) hỗ trợ trao đổi thông tin trực tiếp.

**Phần DevOps & Đóng gói (Bắt buộc cho môn học):**

* [ ] **Task ThaiThinh_DEV_01:** Triển khai (Deploy) Backend .NET API lên môi trường Internet (Sử dụng Render, SmarterASP hoặc cấu hình Ngrok sinh link HTTPS công khai) để điện thoại/máy ảo kết nối được khi chấm bài.  
* [ ] **Task ThaiThinh_DEV_02:** Cấu hình và chạy lệnh build ứng dụng thành file **Release APK** hoặc AppBundle hoàn chỉnh.  
* [ ] **Task ThaiThinh_DEV_03:** Chụp hình/quay video minh chứng ứng dụng hoạt động ổn định và mượt mà trong chế độ Release Mode để đưa vào báo cáo.

# Flow

# **TÀI LIỆU ĐẶC TẢ LUỒNG HOẠT ĐỘNG API THEO VAI TRÒ (ROLE-BASED API FLOW)**

*Tài liệu hướng dẫn luồng xử lý dữ liệu giữa các màn hình chức năng của từng Role (Flutter) và Backend API (.NET)*

## **1\. MODULE 1: HỆ THỐNG & XÁC THỰC (Phụ trách: Phạm Tấn Lộc)**

### **Luồng 1.1: Đăng nhập & Điều hướng theo Vai trò (Login & Routing Flow)**

* **API Endpoint:** POST /api/auth/login  
* **Quyền truy cập (Authorization):** Tất cả các nhân viên (Public).  
* **Luồng xử lý chi tiết:**  
  1. **Mọi Nhân viên (Admin, Manager, Kitchen Staff, Franchise Staff, Supply Coordinator)** nhập tài khoản trên màn hình Flutter.  
  2. Flutter gửi request lên Backend (.NET).  
  3. Backend kiểm tra tài khoản trong Database, nếu đúng sẽ tạo chuỗi **JWT Token** có chứa thông tin Role của nhân viên đó.  
  4. Flutter nhận Token, lưu vào bộ nhớ bảo mật (Flutter Secure Storage).  
  5. auth\_provider.dart đọc thông tin Role trong Token để điều hướng giao diện:  
     * Nếu là **Admin** : Chuyển đến màn hình Quản trị hệ thống.  
     * Nếu là **Franchise Store Staff** :Chuyển đến màn hình Đặt hàng & Xem kho cửa hàng.  
     * Nếu là **Central Kitchen Staff** : Chuyển đến màn hình Quản lý bếp & Sản xuất.  
     * Nếu là **Supply Coordinator** : Chuyển đến màn hình Điều phối & Lập lịch giao hàng.

### **Luồng 1.2: Quản trị tài khoản & Cấu hình (System Administration Flow)**

* **API Endpoint:** POST /api/admin/users, POST /api/admin/stores  
* **Quyền truy cập (Authorization):** Chỉ cho phép quyền **Admin**.  
* **Luồng xử lý chi tiết:**  
  1. **Admin** thực hiện Thêm/Sửa/Xóa tài khoản nhân viên hoặc thông tin cửa hàng Franchise trên app Flutter.  
  2. Flutter gửi request kèm JWT Token của **Admin** ở Header lên Backend.  
  3. Backend (.NET) kiểm tra nếu không phải token của **Admin** sẽ trả về lỗi 403 Forbidden. Nếu đúng, tiến hành cập nhật vào Database và trả về kết quả thành công cho Flutter.

## **2\. MODULE 2: QUẢN LÝ KHO & ĐỊNH MỨC SẢN XUẤT (Phụ trách: Trần Đức Linh)**

### **Luồng 2.1: Xem danh mục và Tồn kho nguyên liệu**

* **API Endpoint:** GET /api/ingredients  
* **Quyền truy cập (Authorization):** **Manager**, **Central Kitchen Staff**, và **Franchise Store Staff**.  
* **Luồng xử lý chi tiết:**  
  1. **Franchise Store Staff** mở màn hình đặt hàng để xem danh sách món có thể nhập; hoặc **Central Kitchen Staff** mở màn hình kiểm kho Bếp trung tâm.  
  2. Flutter gọi API để lấy danh sách nguyên liệu.  
  3. Backend (.NET) truy vấn bảng kho dữ liệu và trả về danh sách JSON.  
  4. inventory\_provider.dart xử lý hiển thị lên màn hình tương ứng của từng Role.

### **Luồng 2.2: Lập kế hoạch và Tính toán định mức sản xuất**

* **API Endpoint:** POST /api/kitchen/production-plan  
* **Quyền truy cập (Authorization):** Chỉ cho phép **Central Kitchen Staff** hoặc **Manager**.  
* **Luồng xử lý chi tiết:**  
  1. **Central Kitchen Staff** mở giao diện xem tổng hợp các đơn đặt hàng đang chờ từ các chi nhánh gửi về.  
  2. **Central Kitchen Staff** bấm nút "Lập kế hoạch sản xuất".  
  3. Backend (.NET) tự động quét các đơn hàng, đối chiếu với công thức định mức (Recipes) do **Manager** cấu hình để tự động quy đổi ra số lượng nguyên liệu thô cần dùng (Ví dụ: Đơn đặt 100 kg Bánh bao $\\rightarrow$ Hệ thống tự tính cần xuất 50 kg Bột và 30 kg Thịt).  
  4. Trả kết quả danh sách nguyên liệu thô về màn hình Flutter của **Central Kitchen Staff** để chuẩn bị sản xuất.

## **3\. MODULE 3: GIỎ HÀNG, ĐẶT HÀNG & TIÊU THỤ (Phụ trách:Nguyễn Hưng Thịnh)**

### **Luồng 3.1: Đặt hàng và Kiểm tra hạn mức công nợ**

* **API Endpoint:** POST /api/franchise/orders  
* **Quyền truy cập (Authorization):** Chỉ cho phép **Franchise Store Staff**.  
* **Luồng xử lý chi tiết:**  
  1. **Franchise Store Staff** chọn nguyên liệu vào giỏ hàng trên app Flutter.  
  2. **Franchise Store Staff** bấm "Gửi đơn đặt hàng".  
  3. Backend (.NET) tiếp nhận đơn, tự động kiểm tra hạn mức công nợ của cửa hàng đó (dữ liệu do **Manager** quản lý).  
  4. Nếu công nợ hợp lệ, Backend lưu đơn vào DB với trạng thái Pending (Chờ duyệt) và kích hoạt hệ thống thông báo thời gian thực.

### **Luồng 3.2: Ghi nhận tiêu thụ kho tại cửa hàng nhượng quyền**

* **API Endpoint:** POST /api/franchise/inventory/consume  
* **Quyền truy cập (Authorization):** **Franchise Store Staff** (thao tác nhập) và **Manager** (xem báo cáo).  
* **Luồng xử lý chi tiết:**  
  1. Cuối ngày, **Franchise Store Staff** nhập số lượng món ăn đã bán hoặc số lượng nguyên liệu bị hỏng/hủy tại cửa hàng lên app Flutter.  
  2. Flutter gửi dữ liệu tiêu thụ về Backend.  
  3. Backend (.NET) tự động trừ số lượng tồn kho tương ứng của chi nhánh đó trong bảng StoreInventory.  
  4. Dữ liệu sau khi trừ sẽ được đồng bộ trực tiếp lên màn hình dashboard của **Manager** để theo dõi hiệu suất bán hàng và hao hụt từ xa.

## **4\. MODULE 4: ĐIỀU PHỐI, BẢN ĐỒ & TƯƠNG TÁC REAL-TIME (Phụ trách: Trần Thái Thịnh)**

### **Luồng 4.1: Duyệt đơn & Bắn thông báo trạng thái**

* **API Endpoint:** PUT /api/kitchen/orders/{id}/status  
* **Quyền truy cập (Authorization):** **Central Kitchen Staff** hoặc **Supply Coordinator**.  
* **Luồng xử lý chi tiết:**  
  1. **Supply Coordinator** hoặc **Central Kitchen Staff** xử lý đơn hàng và bấm cập nhật trạng thái trên App (Ví dụ: Từ *Chờ duyệt* $\\rightarrow$ *Đang sản xuất* $\\rightarrow$ *Xuất kho giao hàng*).  
  2. Backend (.NET) cập nhật trạng thái mới vào Database.  
  3. Ngay lập tức, Backend gọi dịch vụ Firebase Cloud Messaging (FCM) để bắn một thông báo đẩy xuống điện thoại của **Franchise Store Staff** (nhân viên cửa hàng đặt đơn đó) để họ theo dõi tiến độ theo thời gian thực.

### **Luồng 4.2: Cập nhật và Theo dõi lộ trình giao hàng trên Bản đồ (Map Flow)**

* **API Endpoint:** POST /api/delivery/location (Gửi) và GET /api/delivery/location/{orderId} (Nhận)  
* **Quyền truy cập (Authorization):** **Supply Coordinator / Driver** (Gửi tọa độ) và **Franchise Store Staff** (Xem bản đồ).  
* **Luồng xử lý chi tiết:**  
  1. Khi chuyến hàng bắt đầu đi, **Driver** (Tài xế) hoặc **Supply Coordinator** bấm "Bắt đầu giao" trên app. Flutter trên máy tài xế sẽ bật GPS và tự động gửi tọa độ (Latitude, Longitude) lên Backend mỗi 30 giây một lần.  
  2. Backend (.NET) tiếp nhận và lưu tạm thời tọa độ của xe vào bảng DeliveryLogs.  
  3. Ở đầu nhận, **Franchise Store Staff** mở màn hình Bản đồ (Map Screen) trên App của mình. Flutter sẽ liên tục gọi API lấy tọa độ mới nhất của xe từ Backend về và cập nhật vị trí chiếc xe di chuyển thời gian thực trên Google Maps của cửa hàng.

# Database

\-- \=========================================================================  
\-- ĐỀ TÀI: HỆ THỐNG QUẢN LÝ BẾP TRUNG TÂM VÀ CỬA HÀNG FRANCHISE  
\-- DBMS: PostgreSQL  
\-- \=========================================================================

\-- 0\. CÂU LỆNH TẠO MỚI DATABASE (Chạy câu lệnh này trước nếu chưa có DB)  
\-- Lưu ý: Khi chạy trên pgAdmin, bạn cần tạo DB này trước rồi mới chạy các bảng bên dưới.  
CREATE DATABASE central\_kitchen\_franchise\_db;

\-- Di chuyển hoặc kết nối vào Database vừa tạo trước khi chạy phần dưới đây.

\-- \=========================================================================  
\-- KHỞI TẠO & XÓA CÁC BẢNG CŨ (Tránh xung đột dữ liệu khi chạy lại file)  
\-- \=========================================================================  
DROP TABLE IF EXISTS "DeliveryLogs" CASCADE;  
DROP TABLE IF EXISTS "ChatMessages" CASCADE;  
DROP TABLE IF EXISTS "Notifications" CASCADE;  
DROP TABLE IF EXISTS "StoreInventory" CASCADE;  
DROP TABLE IF EXISTS "OrderDetails" CASCADE;  
DROP TABLE IF EXISTS "Orders" CASCADE;  
DROP TABLE IF EXISTS "RecipeDetails" CASCADE;  
DROP TABLE IF EXISTS "Recipes" CASCADE;  
DROP TABLE IF EXISTS "Batches" CASCADE;  
DROP TABLE IF EXISTS "Ingredients" CASCADE;  
DROP TABLE IF EXISTS "Users" CASCADE;  
DROP TABLE IF EXISTS "Stores" CASCADE;  
DROP TABLE IF EXISTS "CentralKitchens" CASCADE;  
DROP TABLE IF EXISTS "Roles" CASCADE;

\-- \=========================================================================  
\-- MODULE 1: HỆ THỐNG & XÁC THỰC (Phụ trách: Phạm Tấn Lộc)  
\-- \=========================================================================

CREATE TABLE "Roles" (  
    "RoleId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "RoleCode" VARCHAR(50) UNIQUE NOT NULL, \-- 'ADMIN', 'MANAGER', 'KITCHEN\_STAFF', 'FRANCHISE\_STAFF', 'SUPPLY\_COORDINATOR'  
    "RoleName" VARCHAR(100) NOT NULL  
);

CREATE TABLE "CentralKitchens" (  
    "KitchenId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "KitchenName" VARCHAR(150) NOT NULL,  
    "Address" TEXT NOT NULL,  
    "PhoneNumber" VARCHAR(20),  
    "IsActive" BOOLEAN DEFAULT TRUE  
);

CREATE TABLE "Stores" (  
    "StoreId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "StoreName" VARCHAR(150) NOT NULL,  
    "Address" TEXT NOT NULL,  
    "PhoneNumber" VARCHAR(20),  
    "CreditLimit" NUMERIC(15, 2\) DEFAULT 0.00,  
    "CurrentDebt" NUMERIC(15, 2\) DEFAULT 0.00,  
    "IsActive" BOOLEAN DEFAULT TRUE  
);

CREATE TABLE "Users" (  
    "UserId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "Username" VARCHAR(50) UNIQUE NOT NULL,  
    "PasswordHash" TEXT NOT NULL,  
    "FullName" VARCHAR(100) NOT NULL,  
    "Email" VARCHAR(100) UNIQUE,  
    "PhoneNumber" VARCHAR(20),  
    "RoleId" INT NOT NULL REFERENCES "Roles"("RoleId"),  
    "KitchenId" INT REFERENCES "CentralKitchens"("KitchenId"),  
    "StoreId" INT REFERENCES "Stores"("StoreId"),  
    "IsActive" BOOLEAN DEFAULT TRUE,  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

\-- \=========================================================================  
\-- MODULE 2: KHO, NGUYÊN LIỆU & LÔ SẢN XUẤT (Phụ trách: Trần Anh Duy)  
\-- \=========================================================================

CREATE TABLE "Ingredients" (  
    "IngredientId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "Name" VARCHAR(150) NOT NULL,  
    "SKU" VARCHAR(50) UNIQUE NOT NULL,  
    "Unit" VARCHAR(20) NOT NULL,  
    "UnitPrice" NUMERIC(12, 2\) NOT NULL,  
    "IsRawMaterial" BOOLEAN DEFAULT TRUE, \-- TRUE: Thô | FALSE: Bán thành phẩm  
    "MinStockLevel" NUMERIC(10, 2\) DEFAULT 0.00,  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE "Batches" (  
    "BatchId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "BatchCode" VARCHAR(50) UNIQUE NOT NULL,  
    "IngredientId" INT NOT NULL REFERENCES "Ingredients"("IngredientId"),  
    "Quantity" NUMERIC(10, 2\) NOT NULL,  
    "RemainingQuantity" NUMERIC(10, 2\) NOT NULL,  
    "ManufactureDate" DATE,  
    "ExpiryDate" DATE NOT NULL,  
    "KitchenId" INT NOT NULL REFERENCES "CentralKitchens"("KitchenId"),  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE "Recipes" (  
    "RecipeId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "OutputIngredientId" INT UNIQUE NOT NULL REFERENCES "Ingredients"("IngredientId"),  
    "Description" TEXT,  
    "CreatedBy" INT REFERENCES "Users"("UserId")  
);

CREATE TABLE "RecipeDetails" (  
    "RecipeDetailId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "RecipeId" INT NOT NULL REFERENCES "Recipes"("RecipeId") ON DELETE CASCADE,  
    "InputIngredientId" INT NOT NULL REFERENCES "Ingredients"("IngredientId"),  
    "QuantityRequired" NUMERIC(10, 4\) NOT NULL  
);

\-- \=========================================================================  
\-- MODULE 3: GIỎ HÀNG, ĐẶT HÀNG & TIÊU THỤ CỬA HÀNG (Phụ trách: Trần Thái Thịnh)  
\-- \=========================================================================

CREATE TABLE "StoreInventory" (  
    "StoreInventoryId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "StoreId" INT NOT NULL REFERENCES "Stores"("StoreId"),  
    "IngredientId" INT NOT NULL REFERENCES "Ingredients"("IngredientId"),  
    "StockQuantity" NUMERIC(10, 2\) DEFAULT 0.00,  
    "LastUpdated" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,  
    CONSTRAINT "UQ\_Store\_Ingredient" UNIQUE ("StoreId", "IngredientId")  
);

CREATE TABLE "Orders" (  
    "OrderId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "OrderCode" VARCHAR(50) UNIQUE NOT NULL,  
    "StoreId" INT NOT NULL REFERENCES "Stores"("StoreId"),  
    "KitchenId" INT NOT NULL REFERENCES "CentralKitchens"("KitchenId"),  
    "TotalAmount" NUMERIC(15, 2\) NOT NULL DEFAULT 0.00,  
    "OrderStatus" VARCHAR(50) NOT NULL DEFAULT 'PENDING', \-- 'PENDING', 'APPROVED', 'SHIPPING', 'COMPLETED', 'CANCELLED'  
    "Notes" TEXT,  
    "CreatedBy" INT NOT NULL REFERENCES "Users"("UserId"),  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,  
    "UpdatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE "OrderDetails" (  
    "OrderDetailId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "OrderId" INT NOT NULL REFERENCES "Orders"("OrderId") ON DELETE CASCADE,  
    "IngredientId" INT NOT NULL REFERENCES "Ingredients"("IngredientId"),  
    "QuantityOrdered" NUMERIC(10, 2\) NOT NULL,  
    "QuantityDelivered" NUMERIC(10, 2\) DEFAULT 0.00,  
    "UnitPrice" NUMERIC(12, 2\) NOT NULL  
);

\-- \=========================================================================  
\-- MODULE 4: ĐIỀU PHỐI, BẢN ĐỒ & TƯƠNG TÁC REAL-TIME (Phụ trách: Nguyễn Hưng Thịnh)  
\-- \=========================================================================

CREATE TABLE "Notifications" (  
    "NotificationId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "UserId" INT NOT NULL REFERENCES "Users"("UserId"),  
    "Title" VARCHAR(200) NOT NULL,  
    "Message" TEXT NOT NULL,  
    "IsRead" BOOLEAN DEFAULT FALSE,  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE "ChatMessages" (  
    "MessageId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "SenderId" INT NOT NULL REFERENCES "Users"("UserId"),  
    "StoreId" INT REFERENCES "Stores"("StoreId"),  
    "KitchenId" INT REFERENCES "CentralKitchens"("KitchenId"),  
    "MessageText" TEXT NOT NULL,  
    "CreatedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE "DeliveryLogs" (  
    "LogId" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
    "OrderId" INT NOT NULL REFERENCES "Orders"("OrderId") ON DELETE CASCADE,  
    "DriverId" INT NOT NULL REFERENCES "Users"("UserId"),  
    "Latitude" NUMERIC(10, 7\) NOT NULL,  
    "Longitude" NUMERIC(10, 7\) NOT NULL,  
    "RecordedAt" TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

\-- \=========================================================================  
\-- DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)  
\-- \=========================================================================  
INSERT INTO "Roles" ("RoleCode", "RoleName") VALUES  
('ADMIN', 'Quản trị viên hệ thống'),  
('MANAGER', 'Quản lý chuỗi'),  
('KITCHEN\_STAFF', 'Nhân viên bếp trung tâm'),  
('FRANCHISE\_STAFF', 'Nhân viên cửa hàng franchise'),  
('SUPPLY\_COORDINATOR', 'Điều phối viên giao hàng');

INSERT INTO "CentralKitchens" ("KitchenName", "Address", "PhoneNumber") VALUES  
('Bếp Trung Tâm Sài Gòn \- Quận 9', 'Lô E2a-7, Đường D1, Khu Công Nghệ Cao, P. Long Thạnh Mỹ, TP. Thủ Đức', '02873005588');

INSERT INTO "Stores" ("StoreName", "Address", "PhoneNumber", "CreditLimit", "CurrentDebt") VALUES  
('Franchise Store \- Nguyễn Huệ', '120 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM', '0901234567', 50000000.00, 15000000.00),  
('Franchise Store \- Thủ Đức', '45 Lê Văn Việt, Phường Tăng Nhơn Phú A, TP. Thủ Đức', '0907654321', 30000000.00, 0.00);

INSERT INTO "Users" ("Username", "PasswordHash", "FullName", "Email", "PhoneNumber", "RoleId", "KitchenId", "StoreId") VALUES  
('locadmin', 'hashed\_password\_here', 'Phạm Tấn Lộc', 'locpt@fpt.edu.vn', '0911111111', 1, NULL, NULL),  
('duykitchen', 'hashed\_password\_here', 'Trần Anh Duy', 'duyta@fpt.edu.vn', '0922222222', 3, 1, NULL),  
('thinhstore', 'hashed\_password\_here', 'Trần Thái Thịnh', 'thinhtt@fpt.edu.vn', '0933333333', 4, NULL, 1),  
('thinhcoordinator', 'hashed\_password\_here', 'Nguyễn Hưng Thịnh', 'thinhnh@fpt.edu.vn', '0944444444', 5, 1, NULL);

INSERT INTO "Ingredients" ("Name", "SKU", "Unit", "UnitPrice", "IsRawMaterial", "MinStockLevel") VALUES  
('Bột mì thượng hạng', 'RAW-FLOUR-01', 'Kg', 15000.00, TRUE, 100.00),  
('Thịt heo băm định lượng', 'RAW-PORK-01', 'Kg', 95000.00, TRUE, 50.00),  
('Bánh bao thịt trứng cút (Bán thành phẩm)', 'BFP-BAO-01', 'Cái', 8000.00, FALSE, 200.00);

INSERT INTO "Recipes" ("OutputIngredientId") VALUES (3);  
INSERT INTO "RecipeDetails" ("RecipeId", "InputIngredientId", "QuantityRequired") VALUES  
(1, 1, 0.0500),  
(1, 2, 0.0300);

# Project Structure

Github : [https://github.com/SE184400-PhamTanLoc/Cencentral-kitchen-franchise-system.git](https://github.com/SE184400-PhamTanLoc/Cencentral-kitchen-franchise-system.git)  
gg stitch : [https://stitch.withgoogle.com/projects/2165296826506463880](https://stitch.withgoogle.com/projects/2165296826506463880)

