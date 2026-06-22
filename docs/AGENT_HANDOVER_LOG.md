# AGENT HANDOVER LOG & DAILY CHANGELOG
**Quy định bắt buộc đối với tất cả các Agent/Developer:**
Tất cả các agent làm việc trong dự án này bắt buộc phải đọc file này đầu tiên khi bắt đầu phiên làm việc và cập nhật tiến độ công việc ngay trước khi kết thúc phiên. Mục đích là để tránh làm trùng lặp code, ghi đè logic của agent trước, và nắm bắt ngay tình trạng của codebase.

---

## Mẫu báo cáo hằng ngày (Copy form này khi cập nhật):
- **Thời gian:** `[Ngày/Tháng/Năm - Giờ]`
- **Người thực hiện:** `[Tên Agent / Developer]`
- **Công việc đã làm:**
  - `...`
- **File đã chỉnh sửa chính:**
  - `...`
- **Ghi chú/Vấn đề cần lưu ý cho Agent tiếp theo:**
  - `...`

---

## Lịch sử cập nhật:

### 📅 [23/06/2026] - Nâng cấp Coordinator Dashboard, Tích hợp OpenStreetMap và Sửa lỗi Lifecycle
- **Người thực hiện:** Antigravity (AI Agent)
- **Công việc đã làm:**
  - Nâng cấp UI/UX toàn diện cho màn hình Điều phối viên (Coordinator Dashboard) với phong cách Glassmorphism, thanh tìm kiếm, filter thông minh và giao diện hóa đơn chi tiết.
  - Gỡ bỏ hoàn toàn `google_maps_flutter` và Google API Key khỏi AndroidManifest. Tích hợp `flutter_map` (OpenStreetMap) và `latlong2` để hiển thị bản đồ miễn phí mà không cần API Key.
  - Cập nhật Provider (`CartOrderProvider`, `DeliveryChatProvider`) và fix triệt để lỗi unmounted context lifecycle trong `MapScreen` và lỗi `setState during build` trong `ChatScreen`.
  - Fix lỗi giả lập Android bị giới hạn bộ nhớ (INSTALL_FAILED_INSUFFICIENT_STORAGE) bằng cách gỡ các ứng dụng rác, giải phóng dung lượng.
- **File đã chỉnh sửa chính:**
  - `central_kitchen_frontend/lib/presentation/screens/coordinator/coordinator_dashboard_screen.dart`
  - `central_kitchen_frontend/lib/presentation/screens/shared/map_screen.dart`
  - `central_kitchen_frontend/lib/presentation/screens/shared/chat_screen.dart`
  - `central_kitchen_frontend/pubspec.yaml`
  - `central_kitchen_frontend/android/app/src/main/AndroidManifest.xml`
- **Ghi chú/Vấn đề cần lưu ý cho Agent tiếp theo:**
  - Đã chuyển sang dùng `flutter_map` phiên bản v8+, lưu ý `Polyline` cần định dạng Generic Type chuẩn `<Polyline<Object>>`.
  - Nếu cài APK trên giả lập báo lỗi hết dung lượng (Insufficient Storage), hãy vào shell gỡ bớt package rác hoặc wipe data.

### 📅 [20/06/2026] - Phiên làm việc về UI Glassmorphism & Tích hợp Module
- **Người thực hiện:** Antigravity (AI Agent)
- **Công việc đã làm:**
  - Nâng cấp triệt để giao diện Franchise Dashboard (Role 4) với hiệu ứng Glassmorphism tuyệt đẹp.
  - Cập nhật Cart Screen: Thêm progress bar cho phí vận chuyển và khu vực Suggestion Items.
  - Cập nhật Checkout Screen: Thêm Tracking Timeline, khu vực Voucher, Checkbox điều khoản.
  - Đã tích hợp mượt mà `AuthProvider` và `CartOrderProvider` cho chức năng Checkout để gửi đúng thông tin user lên API.
  - Rà soát và fix các lỗi lints, đảm bảo `flutter analyze` trả về 0 errors, 0 warnings.
  - Cập nhật `TASK_PROGRESS_SUMMARY.md` đánh dấu hoàn thành cho Backend và Frontend của Module 3 & Module 4.
- **File đã chỉnh sửa chính:**
  - `central_kitchen_frontend/lib/presentation/screens/franchise/franchise_dashboard_screen.dart`
  - `central_kitchen_frontend/lib/presentation/screens/franchise/cart_screen.dart`
  - `central_kitchen_frontend/lib/presentation/screens/franchise/checkout_screen.dart`
  - `central_kitchen_frontend/lib/presentation/screens/franchise/notification_screen.dart`
  - `central_kitchen_frontend/lib/main.dart`
  - `central_kitchen_backend/Central_kitchen_API/Program.cs`
  - `TASK_PROGRESS_SUMMARY.md`
- **Ghi chú/Vấn đề cần lưu ý cho Agent tiếp theo:**
  - Các phần UI hiện đang sử dụng `BackdropFilter` khá nhiều để tạo hiệu ứng blur. Cần cân nhắc về performance trên các thiết bị yếu nếu có phản hồi giật lag.
  - Chưa có Unit Test cho Module 3, Module 4, Module 1 (cần hoàn thiện).
  - Nhiệm vụ sắp tới: Viết Unit Tests, Deploy Backend, và Build APK.

---
*(Hãy cập nhật tiếp bên trên dòng này)*

### 📅 [22/06/2026] - Hoàn thiện chức năng Bếp Trung Tâm (Kitchen Staff)
- **Người thực hiện:** Antigravity (AI Agent)
- **Công việc đã làm:**
  - Phát triển tính năng Thực thi Sản xuất (Execute Production) cho Bếp Trung Tâm, sử dụng thuật toán FIFO để tự động trừ nguyên liệu thô theo hạn sử dụng và tạo Batch thành phẩm mới.
  - Phát triển tính năng Xuất Kho Giao Hàng (Dispatch Order) cho các đơn hàng ở trạng thái APPROVED. Tự động trừ tồn kho theo FIFO và chuyển trạng thái đơn sang DELIVERING, kèm gửi thông báo FCM.
  - Tích hợp API vào giao diện `KitchenInventoryManagementScreen` trên Frontend (thêm nút Thực thi sản xuất và Xuất kho).
  - Cập nhật backend (`InventoryService`, `OrderService`, các Controllers) và frontend (`inventory_datasource`, `inventory_provider`).
  - Gộp 2 file `TASK_PROGRESS_SUMMARY.md` và `PRM393 - Project Assigment.md` thành một.
- **File đã chỉnh sửa chính:**
  - `central_kitchen_backend/Central_kitchen_Services/Services/InventoryService.cs`
  - `central_kitchen_backend/Central_kitchen_Services/Services/OrderService.cs`
  - `central_kitchen_frontend/lib/presentation/screens/kitchen/kitchen_inventory_management_screen.dart`
  - `central_kitchen_frontend/lib/business/providers/inventory_provider.dart`
  - `docs/TASK_PROGRESS_SUMMARY.md`
- **Ghi chú/Vấn đề cần lưu ý cho Agent tiếp theo:**
  - Các luồng tính toán FIFO trừ kho phức tạp đã hoạt động tốt. Cần kiểm thử End-to-End trên thiết bị thực hoặc Emulator.
  - Chuẩn bị bước vào quá trình viết Unit Tests và Deploy.



### 📅 [21/06/2026] - Dọn dẹp cấu trúc thư mục tài liệu (Docs)
- **Người thực hiện:** Antigravity (AI Agent)
- **Công việc đã làm:**
  - Gom các file tài liệu Markdown rải rác (`AGENT_HANDOVER_LOG.md`, `DESIGN.md`, `TASK_PROGRESS_SUMMARY.md`) vào thư mục `docs/`.
  - Tạo file `docs/functional_requirements.md` chi tiết hóa danh sách chức năng từ tài liệu đặc tả theo vai trò.
- **File đã chỉnh sửa chính:**
  - `docs/functional_requirements.md` (Mới)
- **Ghi chú/Vấn đề cần lưu ý cho Agent tiếp theo:**
  - Mọi tài liệu dự án (documents) hãy lưu tập trung trong thư mục `docs/` để codebase gọn gàng hơn.
