import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/manager_datasource.dart';
import '../../data/models/manager_stats_model.dart';
import '../../data/models/chain_inventory_model.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/manager_store_model.dart';

class ManagerProvider extends ChangeNotifier {
  final ManagerDatasource _datasource;

  ManagerProvider(this._datasource);

  bool _isLoadingStats = false;
  bool get isLoadingStats => _isLoadingStats;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  ManagerStatsModel? _stats;
  ManagerStatsModel? get stats => _stats;

  List<ManagerPendingOrderModel> _pendingOrders = [];
  List<ManagerPendingOrderModel> get pendingOrders => _pendingOrders;

  List<ManagerPendingOrderModel> _orderHistory = [];
  List<ManagerPendingOrderModel> get orderHistory => _orderHistory;

  final Set<int> _processingOrderIds = {};
  Set<int> get processingOrderIds => _processingOrderIds;

  bool isOrderProcessing(int orderId) => _processingOrderIds.contains(orderId);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ChainInventoryModel> _inventory = [];
  List<ChainInventoryModel> get inventory => _inventory;

  AnalyticsModel? _analytics;
  AnalyticsModel? get analytics => _analytics;

  List<ManagerStoreModel> _stores = [];
  List<ManagerStoreModel> get stores => _stores;

  bool _isLoadingInventory = false;
  bool get isLoadingInventory => _isLoadingInventory;

  bool _isLoadingAnalytics = false;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  bool _isLoadingStores = false;
  bool get isLoadingStores => _isLoadingStores;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  Future<void> loadDashboardData() async {
    _isLoadingStats = true;
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _datasource.getDashboardStats(),
        _datasource.getPendingOrders(),
      ]);

      _stats = futures[0] as ManagerStatsModel;
      _pendingOrders = futures[1] as List<ManagerPendingOrderModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingStats = false;
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<String?> approveOrder(int orderId, String notes) async {
    if (_processingOrderIds.contains(orderId)) return "Đang xử lý...";
    _processingOrderIds.add(orderId);
    notifyListeners();
    try {
      await _datasource.approveOrder(orderId, notes);
      _pendingOrders.removeWhere((o) => o.orderId == orderId);
      // Reload stats after action
      await loadDashboardData();
      return null; // Success
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return e.toString();
    } finally {
      _processingOrderIds.remove(orderId);
      notifyListeners();
    }
  }

  Future<String?> rejectOrder(int orderId, String notes) async {
    if (_processingOrderIds.contains(orderId)) return "Đang xử lý...";
    _processingOrderIds.add(orderId);
    notifyListeners();
    try {
      await _datasource.rejectOrder(orderId, notes);
      _pendingOrders.removeWhere((o) => o.orderId == orderId);
      // Reload stats after action
      await loadDashboardData();
      return null; // Success
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return e.toString();
    } finally {
      _processingOrderIds.remove(orderId);
      notifyListeners();
    }
  }

  Future<void> loadInventory() async {
    _isLoadingInventory = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _inventory = await _datasource.getChainInventory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingInventory = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics({int days = 7}) async {
    _isLoadingAnalytics = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _analytics = await _datasource.getAnalytics(days: days);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  Future<void> loadStores() async {
    _isLoadingStores = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _stores = await _datasource.getStores();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderHistory({String? status}) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orderHistory = await _datasource.getOrderHistory(status: status);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> updateCreditLimit(int storeId, double limit) async {
    try {
      await _datasource.updateStoreCreditLimit(storeId, limit);
      await loadStores();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
