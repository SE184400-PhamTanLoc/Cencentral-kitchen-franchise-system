import '../../core/constants/franchise_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

/// Datasource gọi trực tiếp các REST API endpoint của module Franchise.
/// Nhất quán với pattern của InventoryDatasource.
class OrderDatasource {
  final ApiClient _apiClient;

  OrderDatasource(this._apiClient);

  // ─── TASK THAI_API_01 ─────────────────────────────────────────

  /// Gửi đơn đặt hàng nguyên liệu lên Backend.
  /// [storeId], [kitchenId]: ID cửa hàng và bếp trung tâm.
  /// [items]: danh sách { ingredientId, quantityOrdered, unitPrice }.
  /// [notes]: ghi chú đơn hàng (tùy chọn).
  Future<PlaceOrderResponse> placeOrder({
    required int storeId,
    required int kitchenId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      FranchiseEndpoints.placeOrder,
      data: {
        'storeId': storeId,
        'kitchenId': kitchenId,
        'notes': notes,
        'items': items,
      },
    );
    return PlaceOrderResponse.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map));
  }

  // ─── TASK THAI_API_02 ─────────────────────────────────────────

  /// Lấy danh sách đơn hàng theo cửa hàng franchise.
  Future<List<OrderSummaryModel>> getOrdersByStore(int storeId) async {
    final response =
        await _apiClient.get(FranchiseEndpoints.ordersByStore(storeId));
    final List<dynamic> data = response.data['data'] ?? [];
    return data
        .map((e) => OrderSummaryModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Lấy chi tiết một đơn hàng (bao gồm từng dòng nguyên liệu).
  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    final response =
        await _apiClient.get(FranchiseEndpoints.orderDetail(orderId));
    return OrderDetailModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map));
  }

  // ─── TASK THAI_API_03 ─────────────────────────────────────────

  /// Xác nhận nhận hàng và cập nhật tồn kho cửa hàng.
  /// [receivedItems]: danh sách { ingredientId, quantityDelivered }.
  ///                  Nếu null, hệ thống tự dùng quantityOrdered.
  Future<Map<String, dynamic>> receiveOrder({
    required int orderId,
    List<Map<String, dynamic>>? receivedItems,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      FranchiseEndpoints.receiveOrder(orderId),
      data: {
        'receivedItems': ?receivedItems,
        'notes': ?notes,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── TASK THAI_API_04 ─────────────────────────────────────────

  /// Ghi nhận tiêu thụ hoặc hao hụt/hủy nguyên liệu cuối ngày.
  /// [consumeType]: 'SOLD' | 'WASTE' | 'DISCARD'
  Future<Map<String, dynamic>> consumeInventory({
    required int storeId,
    required String consumeType,
    required List<ConsumeItemPayload> items,
    String? reason,
    DateTime? consumeDate,
  }) async {
    final response = await _apiClient.post(
      FranchiseEndpoints.consumeInventory,
      data: {
        'storeId': storeId,
        'consumeType': consumeType,
        'reason': ?reason,
        if (consumeDate != null)
          'consumeDate': consumeDate.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── EXTRA: Tồn kho cửa hàng ─────────────────────────────────

  /// Lấy danh sách tồn kho hiện tại của cửa hàng franchise.
  Future<List<StoreInventoryModel>> getStoreInventory(int storeId) async {
    final response =
        await _apiClient.get(FranchiseEndpoints.storeInventory(storeId));
    final List<dynamic> data = response.data['data'] ?? [];
    return data
        .map((e) => StoreInventoryModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
