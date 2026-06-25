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
* **Quản lý & Đặt mua nguyên vật liệu:**
  * Xem danh sách toàn bộ nguyên liệu của Bếp Trung tâm kèm đơn giá, đơn vị tính, hình ảnh minh họa và mô tả chi tiết.
  * Phân loại bộ lọc nguyên liệu theo nhóm: Rau củ, thịt cá, gia vị... giúp tìm kiếm nhanh chóng.
  * Quản lý giỏ hàng tạm thời: Cho phép thêm mới nguyên liệu vào giỏ, tăng/giảm số lượng hoặc xóa bỏ sản phẩm.
  * Theo dõi tổng giá trị đơn hàng tạm tính và đối chiếu với hạn mức nợ khả dụng (Credit Limit) trước khi gửi đi nhằm đảm bảo đơn hàng không vượt hạn mức nợ cho phép.
  * Tạo đơn đặt hàng chính thức và gửi yêu cầu phê duyệt lên hệ thống.
* **Nhận hàng & Cập nhật tồn kho tự động:**
  * Theo dõi lịch sử và trạng thái xử lý đơn đặt hàng qua tiến trình trực quan 5 bước (`Khởi tạo` -> `Đã duyệt` -> `Đang giao` -> `Tới nơi` -> `Đã nhận`).
  * Thực hiện **Xác nhận nhận hàng** khi xe hàng đã cập bến chi nhánh (trạng thái `SHIPPED`): Cho phép kiểm đếm và điền số lượng **Thực nhận (Actual Received)** thực tế cho từng mặt hàng (để bù đắp và ghi nhận chênh lệch do hư hỏng, hao hụt lúc vận chuyển).
  * Nhập ghi chú nhận hàng và xác nhận hoàn tất để hệ thống chuyển trạng thái đơn thành `DELIVERED`, đồng thời tự động cộng số lượng nguyên vật liệu thực nhận vào kho của cửa hàng nhượng quyền.
* **Quản lý tồn kho & Báo cáo tiêu thụ cuối ngày:**
  * Xem báo cáo số lượng tồn kho thực tế thời gian thực tại chi nhánh, hiển thị cảnh báo đỏ nổi bật khi số lượng dưới ngưỡng tối thiểu (dưới 5 đơn vị).
  * Báo cáo tiêu thụ/hao hụt cuối ngày bằng cách nhập số lượng nguyên liệu thâm hụt tương ứng theo 3 loại:
    * `SOLD` (Đã bán): Lượng nguyên liệu đã chế biến thành món bán cho khách.
    * `WASTE` (Hao hụt): Lượng nguyên liệu bị hỏng hóc, dập nát, ôi thiu trong quá trình bảo quản tại cửa hàng.
    * `DISCARD` (Hủy bỏ): Lượng nguyên liệu hết hạn sử dụng buộc phải tiêu hủy.
  * Nhập giải trình/lý do hao hụt (bắt buộc cho loại WASTE và DISCARD) trước khi ghi nhận để hệ thống tự động trừ kho chi nhánh.
* **Trao đổi & Liên lạc nội bộ:**
  * Nhắn tin (Chat) thời gian thực trực tiếp với Bếp Trung tâm hoặc tài xế/điều phối viên để phản hồi về tình trạng hàng hóa hoặc giao trễ.

### 3.2. Central Kitchen Staff (Nhân viên bếp trung tâm)
* **Quản lý nguyên liệu thô & Theo dõi lô hàng (Batch):**
  * Nhập kho nguyên liệu thô từ nhà cung cấp theo từng lô hàng (Batch) riêng biệt để quản lý xuất xứ và chất lượng.
  * Cấu hình hạn sử dụng (HSD) và ngày sản xuất cho từng lô hàng cụ thể.
  * Hệ thống hiển thị cảnh báo hạn sử dụng theo màu sắc (màu đỏ nếu hết hạn) để nhân viên ưu tiên xuất kho theo nguyên tắc FIFO (hàng nhập trước/hạn dùng trước xuất trước).
* **Kế hoạch & Định mức sản xuất (BOM):**
  * Tiếp nhận danh sách các đơn đặt hàng từ chi nhánh đã được Quản lý phê duyệt (`Approved`).
  * **Tính toán định mức sản xuất (BOM)**: Dựa trên số lượng sản phẩm chi nhánh yêu cầu, hệ thống tự động tính toán tổng số lượng nguyên liệu thô thô tương ứng cần sử dụng từ kho bếp để chế biến (ví dụ: cần bao nhiêu kg thịt thô, gia vị thô để làm ra số hộp thịt chế biến).
  * **Thực thi sản xuất**: Bấm xác nhận thực thi kế hoạch để hệ thống tự động khấu trừ tồn kho nguyên liệu thô thô tương ứng tại Bếp Trung tâm.
* **Đóng gói & Bàn giao xuất kho:**
  * Thực hiện **Xuất kho giao hàng (Dispatch)** đơn hàng đã chuẩn bị xong để chuyển trạng thái sang `DELIVERING` (Đang giao) và bàn giao cho tài xế bắt đầu hành trình.

### 3.3. Supply Coordinator & Driver (Điều phối cung ứng & Tài xế)
* **Theo dõi lộ trình giao nhận:**
  * Xem danh sách các đơn hàng cần giao từ Bếp Trung tâm. Lọc nhanh theo đơn `Chờ giao` (Approved) và đơn `Đang giao` (Delivering).
  * Xem chi tiết thông tin cửa hàng nhận, địa chỉ, số điện thoại liên lạc và danh sách hàng hóa đi kèm.
* **Xác thực vị trí GPS & Xác nhận đến cửa hàng:**
  * Bản đồ hiển thị lộ trình di chuyển thực tế/mô phỏng của tài xế đi qua các cột mốc (Bếp Trung tâm -> Điểm trung gian -> Cửa hàng).
  * **Xác thực tọa độ an toàn (GPS Boundary Check)**: Hệ thống sử dụng GPS của tài xế để đo khoảng cách với vĩ độ và kinh độ của cửa hàng nhận. Nút **"Xác nhận đã đến cửa hàng"** chỉ được kích hoạt khi tài xế đã di chuyển thực sự vào trong bán kính an toàn quy định. Nếu chưa tới nơi, nút sẽ bị khóa và hiển thị cảnh báo đỏ.
  * Bấm xác nhận khi đến nơi thành công để tự động chuyển đơn hàng sang trạng thái `SHIPPED` (Đã tới nơi), gửi thông báo cho chi nhánh nhượng quyền chuẩn bị nhận hàng.
* **Kênh trao đổi sự cố:**
  * Nhắn tin trực tiếp với điều phối viên và nhân viên nhận hàng của chi nhánh để báo cáo các sự cố phát sinh trên đường (tai nạn, hỏng xe, kẹt xe...).

### 3.4. Manager (Quản lý vận hành)
* **Giám sát hoạt động toàn chuỗi (Dashboard):**
  * Theo dõi tổng doanh thu của toàn bộ hệ thống chuỗi cửa hàng.
  * Quản lý và xem số lượng chi nhánh nhượng quyền đang hoạt động.
  * Giám sát số lượng đơn hàng đang chờ duyệt và số lượng đơn hàng đang đi giao ngoài đường thời gian thực.
* **Kiểm soát & Phê duyệt đơn hàng nội bộ:**
  * Xem danh sách các đơn đặt hàng mới có trạng thái `Pending` (Chờ duyệt).
  * Kiểm tra chi tiết nguyên liệu yêu cầu, số lượng và tổng số tiền đơn hàng của chi nhánh.
  * **Phê duyệt đơn hàng (`Approve`)**: Chuyển trạng thái sang `Approved` để chuyển lệnh sản xuất xuống Bếp Trung tâm.
  * **Hủy đơn hàng (`Reject`/`Cancel`)**: Từ chối đơn hàng và bắt buộc điền lý do hủy bỏ (ví dụ: "Cửa hàng vượt hạn mức tín dụng", "Bếp trung tâm tạm hết hàng thô").

### 3.5. Admin (Quản trị hệ thống)
* **Quản trị người dùng & Cấp quyền:**
  * Quản lý thông tin tài khoản nhân sự (Thêm mới, chỉnh sửa thông tin, khóa tài khoản hoặc xóa tài khoản).
  * Phân quyền vai trò người dùng (Admin, Manager, Kitchen Staff, Franchise Staff, Coordinator).
  * Gán cơ sở hoạt động trực thuộc: Liên kết tài khoản nhân viên với cơ sở Bếp Trung tâm hoặc Cửa hàng nhượng quyền cụ thể để phân quyền bảo mật dữ liệu.
* **Quản trị cơ sở dữ liệu cốt lõi:**
  * Quản lý danh sách các cửa hàng franchise: Thiết lập thông tin liên hệ, tên cửa hàng, địa chỉ và **kinh độ/vĩ độ GPS** phục vụ hệ thống bản đồ giao hàng.
  * Quản lý danh sách các bếp trung tâm.
* **Cấu hình tham số tài chính & hệ thống:**
  * Thiết lập **Hạn mức công nợ (Credit Limit)** cho mỗi cửa hàng franchise để kiểm soát rủi ro nợ xấu của hệ thống chuỗi nhượng quyền.
  * Cấu đặt log hoạt động hệ thống và xem báo cáo tổng hợp.

