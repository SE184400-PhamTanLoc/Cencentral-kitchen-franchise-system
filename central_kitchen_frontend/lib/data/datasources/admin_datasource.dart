import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/kitchen_model.dart';

/// Lớp thực hiện gọi các API dành riêng cho vai trò quản trị (Admin).
class AdminDatasource {
  // ignore: unused_field
  final ApiClient _apiClient;

  AdminDatasource(this._apiClient);

  // ======================== QUẢN LÝ TÀI KHOẢN (USERS) ========================

  /// Lấy danh sách toàn bộ người dùng từ Backend.
  /// TODO 2.1.1: Gọi GET lên ApiConstants.adminUsersUrl và parse danh sách người dùng.
  /// Gợi ý:
  /// Future<List<UserModel>> getUsers() async {
  ///   final response = await _apiClient.get(ApiConstants.adminUsersUrl);
  ///   final List<dynamic> dataList = response.data['data'] ?? [];
  ///   return dataList.map((json) => UserModel.fromJson(json)).toList();
  /// }
  Future<List<UserModel>> getUsers() async {
    final response = await _apiClient.get(ApiConstants.adminUsersUrl);
    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Tạo tài khoản người dùng mới.
  /// [userData] là Map chứa thông tin DTO (CreateUserDto).
  /// TODO 2.1.2: Gửi POST lên ApiConstants.adminUsersUrl và trả về UserModel mới.
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(ApiConstants.adminUsersUrl, data: userData);
    return UserModel.fromJson(response.data['data']);
  }

  /// Cập nhật thông tin người dùng theo ID.
  /// TODO 2.1.3: Gửi PUT lên '${ApiConstants.adminUsersUrl}/$userId' và trả về UserModel đã sửa.
  Future<UserModel> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await _apiClient.put('${ApiConstants.adminUsersUrl}/$userId', data: userData);
    return UserModel.fromJson(response.data['data']);
  }

  /// Xóa người dùng theo ID.
  /// TODO 2.1.4: Gửi DELETE lên '${ApiConstants.adminUsersUrl}/$userId'.
  Future<void> deleteUser(int userId) async {
    await _apiClient.delete('${ApiConstants.adminUsersUrl}/$userId');
  }

  // ======================== QUẢN LÝ CỬA HÀNG (STORES) ========================

  /// Lấy danh sách tất cả các cửa hàng nhượng quyền.
  /// TODO 2.2.1: Gọi GET lên ApiConstants.adminStoresUrl và parse sang List<StoreModel>.
  Future<List<StoreModel>> getStores() async {
    final response = await _apiClient.get(ApiConstants.adminStoresUrl);
    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((json) => StoreModel.fromJson(json)).toList();
  }

  /// Tạo cửa hàng mới.
  Future<StoreModel> createStore(Map<String, dynamic> storeData) async {
    final response = await _apiClient.post(ApiConstants.adminStoresUrl, data: storeData);
    return StoreModel.fromJson(response.data['data']);
  }

  /// Cập nhật cửa hàng theo ID.
  Future<StoreModel> updateStore(int storeId, Map<String, dynamic> storeData) async {
    final response = await _apiClient.put('${ApiConstants.adminStoresUrl}/$storeId', data: storeData);
    return StoreModel.fromJson(response.data['data']);
  }

  /// Xóa cửa hàng.
  Future<void> deleteStore(int storeId) async {
    await _apiClient.delete('${ApiConstants.adminStoresUrl}/$storeId');
  }

  // ======================== QUẢN LÝ BẾP TRUNG TÂM (KITCHENS) ========================

  /// Lấy danh sách bếp trung tâm.
  /// TODO 2.3.1: Gọi GET lên ApiConstants.adminKitchensUrl và parse sang List<KitchenModel>.
  Future<List<KitchenModel>> getKitchens() async {
    final response = await _apiClient.get(ApiConstants.adminKitchensUrl);
    final List<dynamic> dataList = response.data['data'] ?? [];
    return dataList.map((json) => KitchenModel.fromJson(json)).toList();
  }

  /// Tạo bếp trung tâm mới.
  Future<KitchenModel> createKitchen(Map<String, dynamic> kitchenData) async {
    final response = await _apiClient.post(ApiConstants.adminKitchensUrl, data: kitchenData);
    return KitchenModel.fromJson(response.data['data']);
  }

  /// Cập nhật bếp trung tâm.
  Future<KitchenModel> updateKitchen(int kitchenId, Map<String, dynamic> kitchenData) async {
    final response = await _apiClient.put('${ApiConstants.adminKitchensUrl}/$kitchenId', data: kitchenData);
    return KitchenModel.fromJson(response.data['data']);
  }

  /// Xóa bếp trung tâm.
  Future<void> deleteKitchen(int kitchenId) async {
    await _apiClient.delete('${ApiConstants.adminKitchensUrl}/$kitchenId');
  }
}
