# Hệ thống Quản lý Bếp Trung Tâm và Cửa hàng Franchise
**Central Kitchen and Franchise Store Management System**

- **Mã dự án:** SP26SWP07
- **Giảng viên hướng dẫn:** MinhTTH5
- **Sinh viên thực hiện:** Nguyễn Hưng Thịnh

---

## 1. Bối cảnh & Vấn đề (Context & Pain points)
**Bối cảnh:** Trong mô hình kinh doanh chuỗi (franchise), bếp trung tâm đóng vai trò sản xuất – sơ chế – cung ứng nguyên liệu/thành phẩm cho nhiều cửa hàng. Việc quản lý đơn hàng nội bộ, tồn kho, sản xuất, phân phối và chất lượng giữa bếp trung tâm và các cửa hàng franchise đòi hỏi một hệ thống phần mềm tập trung, chính xác và theo thời gian thực để đảm bảo đồng bộ vận hành, giảm lãng phí và duy trì chất lượng sản phẩm.

**Vấn đề thực tế:** Nhiều chuỗi franchise hiện tại quản lý bếp trung tâm và cửa hàng bằng các công cụ rời rạc (Excel, giấy tờ, phần mềm đơn lẻ), dẫn đến:
- Thiếu đồng bộ thông tin tồn kho, đơn đặt hàng và kế hoạch sản xuất.
- Dự báo nhu cầu kém chính xác, gây thiếu hoặc dư nguyên liệu.
- Khó kiểm soát chất lượng, hạn sử dụng và truy xuất nguồn gốc.
- Quy trình giao nhận giữa bếp trung tâm và cửa hàng thiếu minh bạch.
- Nhà quản lý khó theo dõi hiệu quả vận hành toàn chuỗi.

Điều này ảnh hưởng trực tiếp đến chi phí, chất lượng dịch vụ và khả năng mở rộng hệ thống franchise.

---

## 2. Các vai trò trong hệ thống (Roles)
1. **Franchise Store Staff** (Nhân viên cửa hàng)
2. **Central Kitchen Staff** (Nhân viên bếp trung tâm)
3. **Supply Coordinator** (Điều phối cung ứng)
4. **Manager** (Quản lý vận hành)
5. **Admin** (Quản trị hệ thống)

---

## 3. Đặc tả danh sách chức năng chi tiết (Detailed Functional Requirements)

### 3.1. Franchise Store Staff (Nhân viên cửa hàng)
1. **Quản lý đơn đặt hàng:**
   - Xem danh mục nguyên vật liệu và bán thành phẩm từ bếp trung tâm.
   - Thêm vào giỏ hàng và tạo đơn đặt hàng mới.
   - Theo dõi trạng thái xử lý và giao hàng của đơn đặt (Chờ duyệt, Đang xử lý, Đang giao).
   - Xác nhận đã nhận hàng (Nhập kho cửa hàng) và đánh giá/phản hồi chất lượng hàng nhận.
2. **Quản lý tồn kho cửa hàng:**
   - Xem tồn kho hiện tại tại cửa hàng (Real-time).
   - Báo cáo số lượng tiêu thụ hàng ngày hoặc hao hụt/hư hỏng để trừ kho.
3. **Trao đổi nội bộ:**
   - Nhắn tin (Chat) trực tiếp với bếp trung tâm hoặc điều phối viên liên quan đến đơn đặt hàng cụ thể.

### 3.2. Central Kitchen Staff (Nhân viên bếp trung tâm)
1. **Tiếp nhận & Xử lý đơn hàng:**
   - Xem danh sách các đơn đặt hàng pending từ các cửa hàng franchise.
   - Duyệt hoặc điều chỉnh số lượng đơn hàng (nếu không đủ kho).
2. **Kế hoạch & Định mức sản xuất (BOM):**
   - Lập kế hoạch sản xuất dựa trên tổng hợp nhu cầu (các đơn hàng cần giao).
   - Tự động tính toán số lượng nguyên liệu thô cần dùng dựa theo cấu hình công thức định mức (BOM).
3. **Quản lý tồn kho bếp trung tâm:**
   - Quản lý nguyên liệu đầu vào, cập nhật hạn sử dụng và theo dõi theo lô sản xuất (Batch management).
   - Cập nhật trạng thái sản xuất và xuất kho (Trừ nguyên liệu thô, cộng số lượng bán thành phẩm).

### 3.3. Supply Coordinator (Điều phối cung ứng)
1. **Điều phối giao hàng:**
   - Tổng hợp và phân loại đơn đặt hàng theo tuyến đường hoặc khu vực cửa hàng.
   - Điều phối việc phân bổ hàng hóa từ kho bếp trung tâm ra xe giao hàng.
2. **Lập lịch & Theo dõi xe (GPS Tracking):**
   - Lập lịch giao hàng cho từng xe.
   - Phát tọa độ GPS khi đang trên đường giao hàng để cửa hàng có thể theo dõi thời gian thực.
3. **Xử lý sự cố:**
   - Ghi nhận và xử lý các vấn đề phát sinh trên đường (thiếu hàng, giao trễ, xe hỏng, hủy đơn).

### 3.4. Manager (Quản lý vận hành)
1. **Quản lý danh mục & Cấu hình:**
   - Quản lý danh mục nguyên vật liệu, bán thành phẩm (Thêm/Sửa/Xóa).
   - Cấu hình công thức định mức (BOM - Bill of Materials) cho từng bán thành phẩm.
2. **Giám sát tồn kho chuỗi:**
   - Xem báo cáo tồn kho tại bếp trung tâm và tổng hợp tồn kho tại tất cả các cửa hàng.
3. **Báo cáo & Phân tích:**
   - Theo dõi hiệu suất sản xuất, tốc độ phân phối và số lượng tiêu thụ (bán hàng).
   - Thống kê chi phí, tỷ lệ hao hụt nguyên liệu và đánh giá hiệu quả vận hành toàn chuỗi.
4. **Quản lý công nợ:**
   - Cấu hình hạn mức tín dụng (Credit Limit) cho từng cửa hàng nhượng quyền.

### 3.5. Admin (Quản trị hệ thống)
1. **Quản trị người dùng & Phân quyền:**
   - Quản lý tài khoản (Thêm/Sửa/Xóa/Khóa) nhân viên.
   - Phân quyền theo Role (Franchise, Kitchen, Coordinator, Manager, Admin).
2. **Quản trị cơ sở dữ liệu cốt lõi:**
   - Quản lý danh sách các cửa hàng franchise (Thông tin liên hệ, địa chỉ, trạng thái hoạt động).
   - Quản lý danh sách các bếp trung tâm.
3. **Cấu hình hệ thống:**
   - Cài đặt tham số vận hành chung, đơn vị tính, cảnh báo hệ thống.
   - Xem log hoạt động và báo cáo tổng hợp toàn hệ thống.
