/// Hằng số endpoint cho module Franchise (Giỏ hàng, Đặt hàng & Tiêu thụ).
class FranchiseEndpoints {
  // ─── Đặt hàng nguyên liệu ─────────────────────────────────────
  /// POST /api/franchise/orders — Gửi đơn đặt hàng mới
  static const String placeOrder = '/api/franchise/orders';

  /// GET /api/franchise/orders/{storeId} — Danh sách đơn hàng theo cửa hàng
  static String ordersByStore(int storeId) =>
      '/api/franchise/orders/$storeId';

  /// GET /api/franchise/orders/detail/{orderId} — Chi tiết một đơn hàng
  static String orderDetail(int orderId) =>
      '/api/franchise/orders/detail/$orderId';

  /// PUT /api/franchise/orders/{orderId}/receive — Xác nhận nhận hàng + cập nhật kho
  static String receiveOrder(int orderId) =>
      '/api/franchise/orders/$orderId/receive';

  /// PUT /api/franchise/orders/{orderId}/cancel — Hủy đơn hàng (Pending only)
  static String cancelOrder(int orderId) =>
      '/api/franchise/orders/$orderId/cancel';

  /// PUT /api/franchise/orders/{orderId}/approve — Manager duyệt đơn
  static String approveOrder(int orderId) =>
      '/api/franchise/orders/$orderId/approve';

  /// PUT /api/franchise/orders/{orderId}/dispatch — Bếp trung tâm xuất kho
  static String dispatchOrder(int orderId) =>
      '/api/franchise/orders/$orderId/dispatch';

  /// PUT /api/franchise/orders/{orderId}/reject — Manager từ chối đơn
  static String rejectOrder(int orderId) =>
      '/api/franchise/orders/$orderId/reject';

  /// GET /api/franchise/orders/kitchen/{kitchenId}?status=Pending — Đơn theo bếp
  static String ordersByKitchen(int kitchenId, {String? status}) {
    final base = '/api/franchise/orders/kitchen/$kitchenId';
    return status != null ? '$base?status=$status' : base;
  }

  // ─── Công nợ ──────────────────────────────────────────────────
  /// GET /api/franchise/store/{storeId}/credit-info
  static String creditInfo(int storeId) =>
      '/api/franchise/store/$storeId/credit-info';

  // ─── Tồn kho & Tiêu thụ ───────────────────────────────────────
  /// POST /api/franchise/inventory/consume — Ghi nhận tiêu thụ/hao hụt/hủy
  static const String consumeInventory = '/api/franchise/inventory/consume';

  /// GET /api/franchise/inventory/{storeId} — Xem tồn kho cửa hàng
  static String storeInventory(int storeId) =>
      '/api/franchise/inventory/$storeId';

  // ─── Thông báo ────────────────────────────────────────────────
  /// GET /api/notifications — Lấy danh sách thông báo user hiện tại
  static const String notifications = '/api/notifications';

  /// PUT /api/notifications/{id}/read — Đánh dấu đã đọc
  static String markRead(int id) => '/api/notifications/$id/read';

  /// PUT /api/notifications/read-all — Đánh dấu tất cả đã đọc
  static const String markAllRead = '/api/notifications/read-all';
}
