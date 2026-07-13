import '../../core/network/api_client.dart';
import '../../core/constants/franchise_endpoints.dart';
import '../models/manager_stats_model.dart';
import '../models/chain_inventory_model.dart';
import '../models/analytics_model.dart';
import '../models/manager_store_model.dart';

class ManagerDatasource {
  final ApiClient _client;

  ManagerDatasource(this._client);

  Future<ManagerStatsModel> getDashboardStats() async {
    final res = await _client.get('/api/manager/dashboard/stats');
    return ManagerStatsModel.fromJson(res.data);
  }

  Future<List<ManagerPendingOrderModel>> getPendingOrders() async {
    final res = await _client.get('/api/manager/orders/pending');
    return (res.data as List)
        .map((x) => ManagerPendingOrderModel.fromJson(x))
        .toList();
  }

  Future<List<ManagerPendingOrderModel>> getOrderHistory({
    String? status,
  }) async {
    final res = await _client.get(
      '/api/manager/orders/history',
      queryParameters: status == null || status.isEmpty
          ? null
          : {'status': status},
    );
    return (res.data as List)
        .map((x) => ManagerPendingOrderModel.fromJson(x))
        .toList();
  }

  Future<void> approveOrder(int orderId, String notes) async {
    await _client.put(
      FranchiseEndpoints.approveOrder(orderId),
      data: {'notes': notes},
    );
  }

  Future<void> rejectOrder(int orderId, String notes) async {
    await _client.put(
      FranchiseEndpoints.rejectOrder(orderId),
      data: {'notes': notes},
    );
  }

  Future<List<ChainInventoryModel>> getChainInventory() async {
    final res = await _client.get('/api/manager/inventory');
    return (res.data as List)
        .map((x) => ChainInventoryModel.fromJson(x))
        .toList();
  }

  Future<AnalyticsModel> getAnalytics({int days = 7}) async {
    final res = await _client.get(
      '/api/manager/analytics',
      queryParameters: {'days': days},
    );
    return AnalyticsModel.fromJson(res.data);
  }

  Future<List<ManagerStoreModel>> getStores() async {
    final res = await _client.get('/api/manager/stores');
    return (res.data as List)
        .map((x) => ManagerStoreModel.fromJson(x))
        .toList();
  }

  Future<void> updateStoreCreditLimit(int storeId, double creditLimit) async {
    await _client.put(
      '/api/manager/stores/$storeId/credit-limit',
      data: {'creditLimit': creditLimit},
    );
  }
}
