import 'package:flutter/material.dart';
import '../../data/datasources/admin_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/models/store_model.dart';
import '../../data/models/kitchen_model.dart';

/// Bộ quản lý trạng thái AdminProvider phục vụ các giao diện quản trị Admin.
/// Giúp lưu danh sách động của Users, Stores, Kitchens và tự cập nhật giao diện.
class AdminProvider with ChangeNotifier {
  final AdminDatasource _adminDatasource;

  // --- TRẠNG THÁI (State Variables) ---
  List<UserModel> _users = [];
  List<StoreModel> _stores = [];
  List<KitchenModel> _kitchens = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminProvider(this._adminDatasource);

  // --- GETTERS ---
  List<UserModel> get users => _users;
  List<StoreModel> get stores => _stores;
  List<KitchenModel> get kitchens => _kitchens;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ======================== QUẢN LÝ TÀI KHOẢN (USERS) ========================

  /// Hàm tải danh sách tài khoản nhân viên.
  /// TODO 3.1.1: Gọi datasource tải danh sách và cập nhật trạng thái.
  /// Gợi ý:
  /// Future<void> fetchUsers() async {
  ///   _isLoading = true;
  ///   _errorMessage = null;
  ///   notifyListeners();
  ///   try {
  ///     _users = await _adminDatasource.getUsers();
  ///     _isLoading = false;
  ///     notifyListeners();
  ///   } catch (e) {
  ///     _isLoading = false;
  ///     _errorMessage = 'Không thể tải danh sách tài khoản.';
  ///     notifyListeners();
  ///   }
  /// }
  Future<void> fetchUsers() async {
    // Để trống cho bạn tự viết theo hướng dẫn trên
    throw UnimplementedError();
  }

  /// Thêm tài khoản mới.
  /// TODO 3.1.2: Gọi datasource tạo và chèn vào danh sách cục bộ để UI tự vẽ lại.
  Future<bool> addUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newUser = await _adminDatasource.createUser(userData);
      _users.insert(0, newUser); // Đưa user mới lên đầu danh sách
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Tạo tài khoản thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật tài khoản.
  /// TODO 3.1.3: Gọi datasource chỉnh sửa, cập nhật lại phần tử trong danh sách cục bộ.
  Future<bool> editUser(int userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedUser = await _adminDatasource.updateUser(userId, userData);
      final index = _users.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Cập nhật tài khoản thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Xóa tài khoản.
  /// TODO 3.1.4: Xóa tài khoản qua API và xóa khỏi danh sách cục bộ.
  Future<bool> removeUser(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _adminDatasource.deleteUser(userId);
      _users.removeWhere((user) => user.userId == userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Xóa tài khoản thất bại.';
      notifyListeners();
      return false;
    }
  }

  // ======================== QUẢN LÝ CỬA HÀNG (STORES) ========================

  /// Tải danh sách cửa hàng Franchise.
  Future<void> fetchStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _stores = await _adminDatasource.getStores();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải danh sách cửa hàng.';
      notifyListeners();
    }
  }

  /// Thêm cửa hàng.
  Future<bool> addStore(Map<String, dynamic> storeData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newStore = await _adminDatasource.createStore(storeData);
      _stores.insert(0, newStore);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Thêm cửa hàng thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Sửa cửa hàng.
  Future<bool> editStore(int storeId, Map<String, dynamic> storeData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedStore = await _adminDatasource.updateStore(storeId, storeData);
      final index = _stores.indexWhere((s) => s.storeId == storeId);
      if (index != -1) {
        _stores[index] = updatedStore;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Cập nhật cửa hàng thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Xóa cửa hàng.
  Future<bool> removeStore(int storeId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminDatasource.deleteStore(storeId);
      _stores.removeWhere((s) => s.storeId == storeId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Xóa cửa hàng thất bại.';
      notifyListeners();
      return false;
    }
  }

  // ======================== QUẢN LÝ BẾP TRUNG TÂM (KITCHENS) ========================

  /// Tải danh sách bếp trung tâm.
  Future<void> fetchKitchens() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _kitchens = await _adminDatasource.getKitchens();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải danh sách bếp trung tâm.';
      notifyListeners();
    }
  }

  /// Thêm bếp trung tâm.
  Future<bool> addKitchen(Map<String, dynamic> kitchenData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newKitchen = await _adminDatasource.createKitchen(kitchenData);
      _kitchens.insert(0, newKitchen);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Thêm bếp trung tâm thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Sửa bếp trung tâm.
  Future<bool> editKitchen(int kitchenId, Map<String, dynamic> kitchenData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedKitchen = await _adminDatasource.updateKitchen(kitchenId, kitchenData);
      final index = _kitchens.indexWhere((k) => k.kitchenId == kitchenId);
      if (index != -1) {
        _kitchens[index] = updatedKitchen;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Cập nhật bếp trung tâm thất bại.';
      notifyListeners();
      return false;
    }
  }

  /// Xóa bếp trung tâm.
  Future<bool> removeKitchen(int kitchenId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _adminDatasource.deleteKitchen(kitchenId);
      _kitchens.removeWhere((k) => k.kitchenId == kitchenId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Xóa bếp trung tâm thất bại.';
      notifyListeners();
      return false;
    }
  }
}
