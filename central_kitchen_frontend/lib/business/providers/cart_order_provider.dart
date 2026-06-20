import 'package:flutter/material.dart';
import '../../data/datasources/order_datasource.dart';
import '../../data/models/order_model.dart';

/// Provider quản lý toàn bộ state của module Giỏ hàng & Đặt hàng.
/// Kế thừa ChangeNotifier để UI tự động cập nhật khi state thay đổi.
///
/// Chịu trách nhiệm:
///   - THAI_FLUT_01: Logic giỏ hàng (thêm/bớt/sửa/xóa, tính tiền)
///   - Gọi API PlaceOrder, GetOrders, ConsumeInventory qua [OrderDatasource]
class CartOrderProvider with ChangeNotifier {
  final OrderDatasource _datasource;

  CartOrderProvider(this._datasource);

  // ─────────────────────────────────────────────────────────────────────────────
  // CART STATE (local — không gọi API)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Giỏ hàng lưu theo ingredientId để tránh trùng lặp.
  final Map<int, CartItemModel> _cartItems = {};

  /// Hằng số thuế VAT (10%) và phí vận chuyển cố định.
  static const double taxRate = 0.10;
  static const double shippingFee = 30000; // 30,000 VNĐ

  // ─── Getters giỏ hàng ────────────────────────────────────────────────────────

  /// Danh sách items trong giỏ (có thứ tự ổn định).
  List<CartItemModel> get cartItems => _cartItems.values.toList();

  /// Số lượng loại mặt hàng khác nhau trong giỏ.
  int get itemCount => _cartItems.length;

  /// Tổng số đơn vị (cộng dồn quantity tất cả items).
  int get totalUnits =>
      _cartItems.values.fold(0, (sum, item) => sum + item.quantity);

  /// Giỏ hàng có trống không.
  bool get isEmpty => _cartItems.isEmpty;

  /// Tổng tiền hàng (chưa tính thuế và phí ship).
  double get subtotal =>
      _cartItems.values.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Tiền thuế VAT (10% của subtotal).
  double get taxAmount => subtotal * taxRate;

  /// Phí vận chuyển cố định (miễn ship nếu đơn >= 500,000 VNĐ).
  double get shippingAmount => subtotal >= 500000 ? 0 : shippingFee;

  /// Tổng thanh toán = subtotal + thuế + ship.
  double get grandTotal => subtotal + taxAmount + shippingAmount;

  // ─── Actions giỏ hàng ────────────────────────────────────────────────────────

  /// Thêm một nguyên liệu vào giỏ hàng.
  /// Nếu đã có → cộng thêm 1 vào số lượng.
  void addItem({
    required int ingredientId,
    required String name,
    required String unit,
    required double unitPrice,
  }) {
    if (_cartItems.containsKey(ingredientId)) {
      _cartItems[ingredientId] = _cartItems[ingredientId]!
          .copyWith(quantity: _cartItems[ingredientId]!.quantity + 1);
    } else {
      _cartItems[ingredientId] = CartItemModel(
        ingredientId: ingredientId,
        name: name,
        unit: unit,
        unitPrice: unitPrice,
      );
    }
    notifyListeners();
  }

  /// Giảm số lượng một item. Nếu quantity về 0 → tự động xóa khỏi giỏ.
  void decreaseItem(int ingredientId) {
    if (!_cartItems.containsKey(ingredientId)) return;
    final current = _cartItems[ingredientId]!;
    if (current.quantity <= 1) {
      _cartItems.remove(ingredientId);
    } else {
      _cartItems[ingredientId] =
          current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  /// Cập nhật số lượng cụ thể cho một item.
  /// Nếu [quantity] <= 0 → xóa item khỏi giỏ.
  void updateQuantity(int ingredientId, int quantity) {
    if (!_cartItems.containsKey(ingredientId)) return;
    if (quantity <= 0) {
      _cartItems.remove(ingredientId);
    } else {
      _cartItems[ingredientId] =
          _cartItems[ingredientId]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  /// Xóa hoàn toàn một item khỏi giỏ hàng.
  void removeItem(int ingredientId) {
    _cartItems.remove(ingredientId);
    notifyListeners();
  }

  /// Xóa sạch toàn bộ giỏ hàng (sau khi đặt hàng thành công).
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ORDER STATE (kết nối API)
  // ─────────────────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderSummaryModel> _orders = [];
  OrderDetailModel? _selectedOrder;
  List<StoreInventoryModel> _storeInventory = [];
  PlaceOrderResponse? _lastPlacedOrder;

  // ─── Getters trạng thái API ───────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderSummaryModel> get orders => _orders;
  OrderDetailModel? get selectedOrder => _selectedOrder;
  List<StoreInventoryModel> get storeInventory => _storeInventory;
  PlaceOrderResponse? get lastPlacedOrder => _lastPlacedOrder;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── THAI_API_01: Đặt hàng ───────────────────────────────────────────────────

  /// Gửi đơn đặt hàng lên Backend và xóa giỏ nếu thành công.
  /// Trả về [true] nếu thành công, [false] nếu thất bại.
  Future<bool> placeOrderAsync({
    required int storeId,
    required int kitchenId,
    String? notes,
  }) async {
    if (_cartItems.isEmpty) {
      _setError('Giỏ hàng trống. Vui lòng thêm nguyên liệu trước khi đặt hàng.');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Xây dựng payload từ giỏ hàng hiện tại
      final items = _cartItems.values
          .map((item) => {
                'ingredientId': item.ingredientId,
                'quantityOrdered': item.quantity.toDouble(),
                'unitPrice': item.unitPrice,
              })
          .toList();

      final result = await _datasource.placeOrder(
        storeId: storeId,
        kitchenId: kitchenId,
        items: items,
        notes: notes,
      );

      _lastPlacedOrder = result;
      clearCart(); // Xóa giỏ sau khi đặt thành công
      await loadOrdersAsync(storeId); // Tự động load lại danh sách đơn hàng
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── THAI_API_02: Lịch sử đơn hàng ──────────────────────────────────────────

  /// Tải danh sách đơn hàng của cửa hàng.
  Future<void> loadOrdersAsync(int storeId) async {
    print('=== Gọi loadOrdersAsync với storeId = $storeId');
    _setLoading(true);
    _setError(null);
    try {
      _orders = await _datasource.getOrdersByStore(storeId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
    }
  }

  /// Xác nhận nhận hàng và reload tồn kho.
  Future<bool> receiveOrderAsync({
    required int orderId,
    required int storeId,
    List<Map<String, dynamic>>? receivedItems,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _datasource.receiveOrder(
        orderId: orderId,
        receivedItems: receivedItems,
        notes: notes,
      );
      // Reload tồn kho sau khi nhận hàng
      await loadStoreInventoryAsync(storeId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── THAI_API_04: Tiêu thụ kho ───────────────────────────────────────────────

  /// Ghi nhận tiêu thụ/hao hụt/hủy và reload tồn kho.
  Future<bool> consumeInventoryAsync({
    required int storeId,
    required String consumeType,
    required List<ConsumeItemPayload> items,
    String? reason,
    DateTime? consumeDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _datasource.consumeInventory(
        storeId: storeId,
        consumeType: consumeType,
        items: items,
        reason: reason,
        consumeDate: consumeDate,
      );
      // Reload tồn kho sau khi ghi nhận
      await loadStoreInventoryAsync(storeId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      return false;
    }
  }

  // ─── EXTRA: Tồn kho ──────────────────────────────────────────────────────────

  /// Tải danh sách tồn kho của cửa hàng.
  Future<void> loadStoreInventoryAsync(int storeId) async {
    try {
      _storeInventory = await _datasource.getStoreInventory(storeId);
      notifyListeners();
    } catch (_) {
      // Tồn kho không load được → không cần báo lỗi critical
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Parse lỗi từ DioException hoặc generic Exception.
  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('400')) return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    if (msg.contains('401')) return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
    if (msg.contains('403')) return 'Bạn không có quyền thực hiện thao tác này.';
    if (msg.contains('404')) return 'Không tìm thấy dữ liệu yêu cầu.';
    if (msg.contains('SocketException') || msg.contains('connection')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
  }
}
