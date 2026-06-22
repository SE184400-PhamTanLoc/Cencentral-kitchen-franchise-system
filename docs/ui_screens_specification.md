# 📱 ĐẶC TẢ CHI TIẾT GIAO DIỆN & CHỨC NĂNG HỆ THỐNG CENTRAL KITCHEN PRO

Tài liệu này mô tả chi tiết cấu trúc, chức năng và các thành phần giao diện của từng màn hình tương ứng với từng **Vai trò (Role)** trong hệ thống. Tài liệu này được thiết kế để làm nguồn dữ liệu (prompt) chất lượng cao cho các AI sinh UI thiết kế hoặc lập trình các màn hình mới (ví dụ: Flutter, React Native, Figma, v.v.).

---

## 🎨 HƯỚNG DẪN THIẾT KẾ CHUNG (UI/UX DESIGN SYSTEM)

Để đảm bảo tính nhất quán và sang trọng (Premium Aesthetics), toàn bộ hệ thống áp dụng bộ quy chuẩn thiết kế sau:

### 1. Bảng màu (Color Palette)
- **Primary (Chủ đạo):** `#00236F` (Xanh Navy đậm - Thể hiện sự tin cậy, chuyên nghiệp).
- **Secondary (Tương tác):** `#0058BE` (Xanh dương sáng - Cho các liên kết, nút bấm thứ cấp, trạng thái active).
- **Surface (Bề mặt):** `#F8F9FB` (Nền sáng), kết hợp Acrylic/Glassmorphism với độ nhòe `BackdropFilter` và màu nền bán trong suốt (`rgba(255, 255, 255, 0.65)`).
- **Success (Thành công):** `#10B981` (Xanh lá - Cho trạng thái "Đã nhận", "Đã duyệt", "Đủ hàng").
- **Warning (Cảnh báo):** `#F59E0B` (Vàng cam - Cho "Tồn thấp", "Chờ duyệt", "Sắp hết hạn").
- **Error (Nguy hiểm):** `#EF4444` (Đỏ - Cho "Hủy đơn", "Hết hạn", "Vượt hạn mức").

### 2. Phong cách Thiết kế (Styling)
- **Glassmorphism (Hiệu ứng kính cường lực):** Áp dụng cho các Panel, Banner nổi, và Bottom Sheets. Sử dụng độ nhòe Blur 15-20px và viền mỏng `#FFFFFF` ở độ mờ 20%.
- **Bo góc (Rounded corners):**
  - Thẻ thông tin (Cards), Container lớn: `16px` (`lg`).
  - Inputs, Nút bấm (Buttons), Dropdown: `8px` (`md`).
  - Chips/Badges trạng thái: `999px` (`full`).
- **Typography:** Sử dụng font **Inter** hoặc **Outfit**. 
  - Tiêu đề màn hình: 20px - 24px (Bold).
  - Tên nhãn / Thông số chính: 14px (SemiBold).
  - Nội dung / Mô tả phụ: 12px (Regular, Mờ).

---

## 👥 CHI TIẾT MÀN HÌNH THEO TỪNG VAI TRÒ (ROLE SCREENS SPECIFICATION)

---

### 1. 🔑 MÀN HÌNH CHUNG & XÁC THỰC (SHARED SCREENS)

#### 1.1. Màn hình Đăng nhập (Login Screen)
*   **Mục đích:** Xác thực người dùng doanh nghiệp truy cập hệ thống.
*   **Bố cục (Layout):**
    *   Nền gradient mượt mà từ xanh Navy đậm sang đen huyền ảo, có các bong bóng ánh sáng mờ phía sau.
    *   Hộp thoại đăng nhập nằm giữa màn hình thiết kế dạng kính (Glassmorphic Card).
*   **Các thành phần giao diện (UI Components):**
    *   **Logo & Slogan:** Logo "Central Kitchen Pro" dạng vector nổi bật, dòng chữ *"Logistics & Supply Chain Management"*.
    *   **Form nhập liệu:**
        *   Ô nhập Username/Email (Có icon User ở đầu, viền mỏng sắc nét).
        *   Ô nhập Password (Có icon ổ khóa ở đầu và nút ẩn/hiện mật khẩu).
    *   **Nút bấm (Buttons):**
        *   Nút *"Login"* (Xanh dương sáng nổi bật, hiệu ứng đổ bóng nhẹ).
        *   Nút *"Forgot Enterprise Password?"* (Dạng text-button tối giản).
    *   **Footer hỗ trợ:** Dòng chữ nhỏ *"ADMIN SUPPORT - Contact Corporate IT Support"*.
*   **Tính năng tương tác:**
    *   Kiểm tra tính hợp lệ dữ liệu nhập (Validation) theo thời gian thực (Username và Password không được trống, mật khẩu dài tối thiểu 6 ký tự).
    *   Sau khi đăng nhập thành công, hệ thống tự lưu JWT Token vào bộ nhớ và tự động điều hướng sang Dashboard tương ứng của Role được trả về từ API.

#### 1.2. Màn hình Nhắn tin Nội bộ (Chat Screen)
*   **Mục đích:** Trao đổi thông tin trực tiếp giữa Bếp Trung Tâm và các Cửa hàng nhượng quyền.
*   **Bố cục (Layout):**
    *   Thanh AppBar hiển thị tên đối phương kèm theo tag trạng thái (Ví dụ: `KITCHEN_STAFF` hoặc tên Cửa hàng).
    *   Khu vực hiển thị tin nhắn chiếm 80% màn hình, tự động cuộn xuống dưới cùng.
    *   Khu vực nhập tin nhắn cố định ở đáy màn hình.
*   **Các thành phần giao diện (UI Components):**
    *   **Thanh lọc nhanh (Dành cho Bếp):** Dropdown hoặc các slide chip chọn cửa hàng cần nhắn tin (`StoreName`).
    *   **Khung tin nhắn (Message Bubbles):**
        *   Tin nhắn gửi đi: Nằm bên phải, màu nền Primary, chữ trắng.
        *   Tin nhắn nhận về: Nằm bên trái, màu nền xám nhạt/kính mờ, chữ đen.
        *   Dưới mỗi tin nhắn có giờ gửi dạng `hh:mm` rất nhỏ.
    *   **Input Bar:** Ô nhập chữ bo góc tròn, nút Send màu xanh dương dạng icon máy bay giấy.

#### 1.3. Màn hình Bản đồ & GPS (Map Screen)
*   **Mục đích:** Giám sát vị trí giao hàng theo thời gian thực (Real-time Delivery Tracking).
*   **Bố cục (Layout):**
    *   Bản đồ tương tác chiếm toàn bộ diện tích màn hình.
    *   Hộp thông tin lộ trình nổi phía trên bản đồ dạng Glassmorphism.
*   **Các thành phần giao diện (UI Components):**
    *   **Bản đồ nền (Google Maps):**
        *   Marker A (Màu đỏ): Vị trí Bếp trung tâm.
        *   Marker B (Màu xanh lá): Vị trí Cửa hàng nhượng quyền nhận hàng.
        *   Marker Xe giao hàng (Màu xanh dương có icon xe tải): Di chuyển liên tục theo tọa độ GPS.
        *   Đường Polyline nối giữa hai điểm thể hiện tuyến đường di chuyển đề xuất.
    *   **Bảng điều khiển giả lập (Chế độ test):**
        *   Nút *"PHÁT GPS THỰC TẾ"* (Bắt đầu cập nhật tọa độ xe lên API).
        *   Nút *"DỪNG PHÁT GPS"* (Dừng cập nhật).
        *   Danh sách cột mốc lộ trình (B1, B2...) để người dùng/tester click vào và giả lập dịch chuyển xe lập tức trên bản đồ.

---

## 🏪 NHÂN VIÊN CỬA HÀNG (FRANCHISE STORE STAFF)

#### 2.1. Dashboard Cửa hàng (Franchise Dashboard Screen)
*   **Mục đích:** Trung tâm điều hành của nhân viên cửa hàng gồm đặt hàng, xem lịch sử và báo cáo tiêu thụ.
*   **Bố cục (Layout):** Bottom Navigation Bar gồm 3 Tabs chính:
    1.  **Đặt hàng (Order Tab)**
    2.  **Lịch sử đơn (History Tab)**
    3.  **Kho & Tiêu thụ (Inventory Tab)**
*   **Các thành phần giao diện theo Tab:**
    *   **Tab Đặt hàng:**
        *   *AppBar:* Hiển thị tên cửa hàng nhượng quyền, số dư hạn mức khả dụng (`Credit Limit`), nút vào Giỏ hàng có huy hiệu (badge) số lượng món.
        *   *Thanh tìm kiếm & Slide lọc danh mục:* Tìm nguyên liệu theo tên/SKU; bộ lọc danh mục (Rau củ, Thịt cá, Gia vị, Đóng gói).
        *   *Danh sách sản phẩm:* Card nguyên liệu gồm hình ảnh, tên, đơn giá, trạng thái tồn kho bếp (Còn hàng / Hết hàng). 
        *   *Tương tác:* Nút *"Thêm giỏ hàng"*. Nếu sản phẩm đã có trong giỏ, hiển thị bộ tăng giảm số lượng (+ / -) ngay trên card.
    *   **Tab Lịch sử:**
        *   *Bộ lọc trạng thái:* Chips lọc đơn theo: *Chờ duyệt (Pending), Đã duyệt (Approved), Đang giao (Delivering), Đã nhận (Delivered), Đã hủy (Cancelled)*.
        *   *Danh sách đơn hàng:* Mỗi thẻ đơn hàng gồm: Mã đơn, ngày đặt, tổng tiền, tag màu hiển thị trạng thái và nút *"Định vị đơn"* (mở bản đồ tracking nếu đơn đang giao).
    *   **Tab Kho & Tiêu thụ:**
        *   *Biểu đồ/Thanh báo tồn kho cửa hàng:* Hiển thị trực quan danh sách hàng đang có tại kho cửa hàng. Nổi bật các mặt hàng *Cần nhập gấp* (dưới ngưỡng tối thiểu).
        *   *Nút hành động chính:* Nút *"Báo cáo tiêu hao"* nổi bật dưới đáy.

#### 2.2. Màn hình Giỏ hàng (Cart Screen)
*   **Mục đích:** Xem lại các nguyên liệu đã chọn, điều chỉnh số lượng trước khi xác nhận.
*   **Bố cục (Layout):** Danh sách cuộn chiếm thân trang, bảng tóm tắt chi phí cố định ở đáy.
*   **Các thành phần giao diện (UI Components):**
    *   **Nút Xóa sạch:** Ở góc phải AppBar để xóa toàn bộ giỏ hàng nhanh.
    *   **Danh sách hàng đã chọn:** Thẻ item có ảnh nhỏ, tên, giá bán, số lượng yêu cầu kèm bộ nút bấm tăng giảm số lượng, và nút xóa item.
    *   **Gợi ý mua sắm (Suggestions):** Slide ngang các sản phẩm gợi ý kèm nút *"Thêm nhanh"* (ví dụ: các loại gia vị thường mua kèm).
    *   **Bảng tính tiền:**
        *   Tạm tính nguyên liệu.
        *   Thuế VAT (10%).
        *   Phí vận chuyển (Có thanh Progress Bar hiển thị xem còn thiếu bao nhiêu tiền để được miễn phí vận chuyển).
        *   **Tổng cộng** (In đậm, cỡ chữ lớn).
    *   **Nút *"Xác nhận đặt hàng"*:** Nút dài, màu Primary, bo góc rộng.

#### 2.3. Màn hình Thanh toán / Xác nhận (Checkout Screen)
*   **Mục đích:** Điền thông tin giao nhận, ghi chú và gửi đơn đặt hàng.
*   **Bố cục (Layout):** Dạng form nhập liệu cuộn dọc.
*   **Các thành phần giao diện (UI Components):**
    *   **Thông tin nhận hàng:** Tự động điền tên cửa hàng và địa chỉ chi nhánh.
    *   **Khu vực nhập Khuyến mãi (Voucher):** Ô text field nhập mã voucher kèm nút *"Áp dụng"*.
    *   **Ghi chú vận chuyển:** Ô nhập văn bản nhiều dòng để lưu ý cho tài xế/bếp.
    *   **Tiến trình đặt hàng (Tracking Timeline):** Dãy step hiển thị các bước: *Đặt hàng -> Duyệt đơn -> Giao hàng -> Nhận hàng*.
    *   **Nút *"Gửi Đơn Đặt Hàng"*.**

#### 2.4. Bottom Sheet Báo cáo Tiêu thụ (Consume Bottom Sheet)
*   **Mục đích:** Khai báo số lượng nguyên liệu đã sử dụng hoặc bị hư hỏng tại cửa hàng hàng ngày.
*   **Bố cục (Layout):** Trượt lên từ cạnh đáy màn hình.
*   **Các thành phần giao diện (UI Components):**
    *   Tiêu đề: *"Báo cáo hao hụt & tiêu thụ"*.
    *   Dropdown chọn nguyên liệu cần báo cáo.
    *   Ô nhập số lượng tiêu thụ và ô chọn Lý do tiêu hao (Bán hàng tiêu chuẩn / Hư hỏng / Hết hạn).
    *   Nút *"Xác nhận trừ kho"*.

---

## 🍳 NHÂN VIÊN BẾP TRUNG TÂM (CENTRAL KITCHEN STAFF)

#### 3.1. Dashboard Bếp Trung Tâm (Kitchen Inventory Management Screen)
*   **Mục đích:** Quản lý xuất nhập tồn kho bếp và lập kế hoạch định mức sản xuất (BOM).
*   **Bố cục (Layout):** Giao diện phân chia thành 4 Tabs chính kiểm soát bằng thanh TabBar:
    1.  **Tổng quan (Overview Tab)**
    2.  **Nguyên liệu (Ingredients Tab)**
    3.  **Lô hàng (Batches Tab)**
    4.  **Kế hoạch BOM (BOM Tab)**
*   **Các thành phần giao diện theo Tab:**
    *   **Tab Tổng quan:**
        *   *Thẻ số liệu (Metrics):* 4 card lớn hiển thị nhanh số lượng: *Tồn kho thấp, Lô hàng sắp hết hạn, Đơn hàng chờ xử lý, Tổng giá trị kho*.
        *   *Nút thao tác nhanh:* *"Nhập kho nhanh"* (Mở pop-up điền nhanh thông số nguyên liệu đầu vào).
    *   **Tab Nguyên liệu:**
        *   Danh sách toàn bộ nguyên liệu thô và bán thành phẩm của bếp.
        *   Mỗi item hiển thị tên, đơn vị tính, tổng tồn khả dụng kèm thanh đo mức độ tồn kho (xanh lá: đầy, đỏ: sắp cạn).
    *   **Tab Lô hàng (Batches):**
        *   Danh sách các lô hàng sản xuất thực tế tại bếp.
        *   Mỗi lô hiển thị: Mã lô (`batchCode`), tên nguyên liệu, số lượng còn lại, ngày sản xuất, hạn sử dụng kèm nhãn chỉ báo thời gian còn lại (Còn hạn / Hết hạn).
    *   **Tab Kế hoạch BOM (Bill of Materials):**
        *   Hiển thị danh sách các đơn hàng từ các chi nhánh đang ở trạng thái **PENDING**.
        *   Nút bấm *"Tính BOM tự động"*: Khi click vào, hệ thống tự động quét công thức định mức sản xuất, nhân số lượng bán thành phẩm của các đơn hàng và đưa ra bảng đề xuất số lượng nguyên liệu thô cần chuẩn bị.

#### 3.2. Màn hình Chi tiết Nguyên liệu (Inventory Product Detail Screen)
*   **Mục đích:** Xem thông số kỹ thuật chi tiết của nguyên liệu và lịch sử các lô hàng liên quan.
*   **Bố cục (Layout):** Chia làm 2 phần: Header thông tin sản phẩm và Body danh sách lô hàng con.
*   **Các thành phần giao diện (UI Components):**
    *   **Card thông số chính:** Tên sản phẩm, mã SKU, ngưỡng tồn tối thiểu, đơn giá, phân loại (Nguyên liệu thô / Bán thành phẩm).
    *   **Công cụ Tính toán BOM thủ công:** Ô nhập số lượng cần sản xuất, nút *"Tính toán"* để hiển thị nhanh danh sách các nguyên liệu thô cần dùng và cảnh báo nếu kho bếp không đủ nguyên liệu.
    *   **Nút *"Thêm lô mới"*.**

#### 3.3. Dialog Tạo/Sửa Lô sản xuất (Batch Edit Dialog)
*   **Mục đích:** Khai báo thông tin nhập kho hoặc sản xuất mới cho một lô nguyên liệu cụ thể.
*   **Các thành phần giao diện (UI Components):**
    *   Ô nhập Mã lô (Tự sinh hoặc nhập tay).
    *   Ô nhập Số lượng và Số lượng còn lại.
    *   Trình chọn ngày (DatePicker) cho Ngày sản xuất và Hạn sử dụng.
    *   Nút *"Xóa lô sản xuất"* (nếu ở chế độ chỉnh sửa).

---

## 📈 QUẢN LÝ VẬN HÀNH (MANAGER)

#### 4.1. Dashboard Quản lý (Manager Dashboard Screen)
*   **Mục đích:** Giám sát toàn bộ hoạt động kinh doanh, phê duyệt đơn hàng nhượng quyền và quản lý danh mục cấu hình.
*   **Bố cục (Layout):** Grid menu chứa các tính năng quản trị kết hợp với danh sách đơn hàng chờ duyệt trực tiếp.
*   **Các thành phần giao diện (UI Components):**
    *   **Header chào mừng:** Tên quản lý kèm ngày tháng năm hiện tại.
    *   **Khung chỉ số nhanh (KPIs):**
        *   Tổng chi nhánh (Kèm chỉ số gia tăng).
        *   Doanh thu hôm nay (Kèm % tăng trưởng).
        *   Rủi ro công nợ (Số chi nhánh vượt hạn mức).
        *   Đơn hàng chờ duyệt.
    *   **Grid Menu Tính năng:** Các nút bo tròn mở nhanh các màn hình chuyên sâu:
        *   `Danh mục & BOM`
        *   `Giám sát Tồn kho`
        *   `Báo cáo & Phân tích`
        *   `Quản lý Công nợ`
    *   **Danh sách Đơn chờ duyệt (Pending Orders Area):**
        *   Danh sách thẻ các đơn hàng đang chờ duyệt.
        *   Mỗi thẻ có nút bấm nhanh: *"Phê duyệt"* (Màu xanh lá) và *"Từ chối"* (Màu đỏ).

#### 4.2. Màn hình Quản lý Danh mục & BOM (Manager Category Screen)
*   **Mục đích:** CRUD danh mục hàng hóa hệ thống và điều hướng cấu hình công thức định mức (BOM).
*   **Các thành phần giao diện (UI Components):**
    *   Nút *"Thêm mới"* ở AppBar để tạo nguyên liệu/bán thành phẩm mới.
    *   **Danh sách mặt hàng:**
        *   Mỗi dòng hiển thị: SKU, Tên, Đơn vị, Giá bán, Phân loại (Nguyên liệu thô / Bán thành phẩm).
        *   Đối với các sản phẩm là Bán thành phẩm, hiển thị nhãn chỉ báo trạng thái: `Đã có BOM` (Màu xanh lá) hoặc `Chưa có BOM` (Màu vàng).
        *   Nút *"Cấu hình BOM"* đi kèm trên từng dòng bán thành phẩm.

#### 4.3. Màn hình Cấu hình Định mức (Manager BOM Screen)
*   **Mục đích:** Định nghĩa công thức chế biến bán thành phẩm từ các nguyên liệu thô cấu thành.
*   **Các thành phần giao diện (UI Components):**
    *   Tiêu đề: *"Cấu hình BOM: [Tên Bán Thành Phẩm]"*.
    *   **Danh sách thành phần con:**
        *   Danh sách các nguyên liệu thô cần dùng, mỗi dòng gồm: Tên nguyên liệu thô, số lượng định mức (ví dụ: 0.05 Kg bột mì để làm 1 cái bánh bao).
        *   Nút xóa thành phần.
    *   **Nút *"Thêm nguyên liệu con"*** (Mở hộp thoại chọn nguyên liệu thô từ danh mục và điền số lượng định mức).
    *   **Nút *"Lưu BOM"* ở đáy.**

#### 4.4. Màn hình Quản lý Công nợ (Manager Debt Screen)
*   **Mục đích:** Xem nợ hiện tại và thiết lập hạn mức tín dụng cho các cửa hàng nhượng quyền.
*   **Các thành phần giao diện (UI Components):**
    *   Danh sách cửa hàng nhượng quyền, hiển thị thông số: Tên cửa hàng, Địa chỉ, Hạn mức tín dụng (`Credit Limit`), Số nợ hiện tại (`Current Debt`).
    *   Nút chỉnh sửa hạn mức trên từng cửa hàng (Mở hộp thoại nhập số tiền hạn mức mới bằng VNĐ).

#### 4.5. Màn hình Giám sát Tồn kho Chuỗi (Manager Inventory Screen)
*   **Mục đích:** Đối chiếu tồn kho thực tế giữa Bếp trung tâm và tất cả các chi nhánh cửa hàng.
*   **Các thành phần giao diện (UI Components):**
    *   Bộ chọn lọc (Bếp trung tâm / Từng chi nhánh cửa hàng).
    *   Danh sách nguyên liệu kèm chỉ số tồn kho thực tế chi tiết của từng nơi, giúp đưa ra quyết định điều phối hàng hóa hợp lý.

#### 4.6. Màn hình Báo cáo & Phân tích (Manager Analytics Screen)
*   **Mục đích:** Xem biểu đồ doanh thu và phân tích hiệu suất chuỗi.
*   **Các thành phần giao diện (UI Components):**
    *   Bộ lọc thời gian (7 ngày qua / 30 ngày qua).
    *   Biểu đồ cột (Bar Chart) hoặc Biểu đồ đường (Line Chart) thể hiện sự biến động doanh thu.
    *   Báo cáo tổng kết: Tổng doanh thu, Số lượng đơn đặt thành công.

---

## 🚛 ĐIỀU PHỐI VIÊN CUNG ỨNG (SUPPLY COORDINATOR)

#### 5.1. Dashboard Điều phối (Coordinator Dashboard Screen)
*   **Mục đích:** Quản lý giao nhận hàng hóa, theo dõi tài xế vận chuyển và ghi nhận sự cố.
*   **Bố cục (Layout):** Thể hiện trực quan dạng các thẻ tính năng lớn và các chỉ số hoạt động.
*   **Các thành phần giao diện (UI Components):**
    *   **Metrics giao nhận:** Số lượng đơn hàng *Đang giao*, Số lượng đơn gặp *Sự cố*.
    *   **Tính năng chính:**
        *   Thẻ *"Bản đồ Định vị GPS"*: Mở bản đồ theo dõi tài xế giao hàng thời gian thực.
        *   Thẻ *"Kênh Liên Lạc Nội Bộ"*: Mở danh sách các phòng chat với các cửa hàng và bếp trung tâm.

---

## 🛠️ QUẢN TRỊ VIÊN HỆ THỐNG (ADMIN)

#### 6.1. Dashboard Admin (Admin Dashboard Screen)
*   **Mục đích:** Quản trị toàn bộ dữ liệu tài khoản và các cơ sở dữ liệu nền của hệ thống.
*   **Các thành phần giao diện (UI Components):**
    *   **Nút *"Quản lý Tài khoản Nhân viên"*:** Đi tới màn hình quản trị Users.
    *   **Nút *"Quản lý Cửa hàng & Bếp trung tâm"*:** Đi tới màn hình quản trị danh sách cửa hàng và bếp.

#### 6.2. Màn hình Quản lý Tài khoản (Manage Users Screen)
*   **Mục đích:** Thêm mới, chỉnh sửa thông tin, khóa tài khoản nhân viên.
*   **Các thành phần giao diện (UI Components):**
    *   **Danh sách Users:** Hiển thị họ tên, email, vai trò (Role), nơi phân công công việc (Bếp cụ thể hoặc Cửa hàng cụ thể) và trạng thái (Đang hoạt động / Bị khóa).
    *   **Dialog Thêm/Sửa Tài khoản (User Edit Dialog):**
        *   Các trường dữ liệu: Username, Password (nếu thêm mới), Họ tên, Email, Số điện thoại, Vai trò (Dropdown), Đơn vị phân công (Dropdown hiển thị danh sách Store/Kitchen tương ứng với vai trò), Trạng thái hoạt động (Switch On/Off).

#### 6.3. Màn hình Quản lý Cửa hàng & Bếp (Manage Stores Screen)
*   **Mục đích:** Tạo lập thông tin chi nhánh cửa hàng nhượng quyền và cơ sở bếp trung tâm.
*   **Bố cục (Layout):** Phân chia thành 2 danh sách song song (Tab Cửa hàng Franchise và Tab Bếp trung tâm).
*   **Các thành phần giao diện (UI Components):**
    *   **Form thêm/sửa chi nhánh:** Tên chi nhánh, Địa chỉ, Số điện thoại, Hạn mức công nợ (chỉ dành cho Store), Trạng thái hoạt động.

---

## 💡 HƯỚNG DẪN CHO AI ĐỂ GENERATE VIEW MỚI (PROMPT SUGGESTIONS)

Khi bạn copy nội dung file này đưa cho AI thiết kế giao diện (như v0, Lovable, Cursor...), hãy đính kèm các câu lệnh mẫu sau:

1.  **Dành cho việc tạo giao diện đặt hàng (Franchise Staff):**
    > *"Hãy tạo giao diện màn hình Đặt hàng (Franchise Dashboard - Order Tab) bằng Flutter dựa trên mô tả ở mục 2.1 của tài liệu. Giao diện sử dụng phong cách Corporate Modern, màu chủ đạo là `#00236F` và `#0058BE`. Áp dụng Glassmorphism cho phần Card sản phẩm và tích hợp nút tăng giảm số lượng (+ / -) trực tiếp trên Card nếu số lượng trong giỏ hàng lớn hơn 0."*

2.  **Dành cho việc tạo màn hình Kế hoạch sản xuất BOM (Kitchen Staff):**
    > *"Hãy tạo màn hình quản lý Kế hoạch sản xuất và tính toán định mức nguyên liệu BOM (Kitchen Dashboard - BOM Tab) bằng Flutter theo đặc tả ở mục 3.1. Hiển thị danh sách các đơn hàng chờ duyệt (Pending), khi click nút 'Tính BOM tự động' sẽ hiển thị danh sách các nguyên liệu thô cần dùng cùng chỉ số thiếu hụt (Shortage) màu đỏ nếu tồn kho hiện tại không đủ."*

3.  **Dành cho việc tạo màn hình Bản đồ giám sát vận chuyển (Supply Coordinator & Franchise):**
    > *"Hãy thiết kế giao diện Màn hình Bản đồ & GPS (Map Screen) theo đặc tả ở mục 1.3. Vẽ một bản đồ giả lập có tuyến đường di chuyển từ Bếp trung tâm đến Cửa hàng nhượng quyền, hiển thị marker xe tải đang di chuyển theo thời gian thực và một bảng điều khiển giả lập (GPS Simulation Panel) dạng kính nổi trên bản đồ để hỗ trợ tester thay đổi tọa độ nhanh bằng cách bấm nút."*
