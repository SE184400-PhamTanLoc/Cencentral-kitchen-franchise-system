import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/kitchen_model.dart';

/// Lớp thực hiện gọi các API dành riêng cho vai trò quản trị (Admin).
class AdminDatasource {
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
    // Để trống cho bạn tự viết theo hướng dẫn trên
    throw UnimplementedError();
  }

  /// Tạo tài khoản người dùng mới.
  /// [userData] là Map chứa thông tin DTO (CreateUserDto).
  /// TODO 2.1.2: Gửi POST lên ApiConstants.adminUsersUrl và trả về UserModel mới.
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    // Để trống cho bạn tự viết. Gợi ý:
    // final response = await _apiClient.post(ApiConstants.adminUsersUrl, data: userData);
    // return UserModel.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// Cập nhật thông tin người dùng theo ID.
  /// TODO 2.1.3: Gửi PUT lên '${ApiConstants.adminUsersUrl}/$userId' và trả về UserModel đã sửa.
  Future<UserModel> updateUser(int userId, Map<String, dynamic> userData) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Xóa người dùng theo ID.
  /// TODO 2.1.4: Gửi DELETE lên '${ApiConstants.adminUsersUrl}/$userId'.
  Future<void> deleteUser(int userId) async {
    // Để trống cho bạn tự viết. Gợi ý:
    // await _apiClient.delete('${ApiConstants.adminUsersUrl}/$userId');
    throw UnimplementedError();
  }

  // ======================== QUẢN LÝ CỬA HÀNG (STORES) ========================

  /// Lấy danh sách tất cả các cửa hàng nhượng quyền.
  /// TODO 2.2.1: Gọi GET lên ApiConstants.adminStoresUrl và parse sang List<StoreModel>.
  Future<List<StoreModel>> getStores() async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Tạo cửa hàng mới.
  Future<StoreModel> createStore(Map<String, dynamic> storeData) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Cập nhật cửa hàng theo ID.
  Future<StoreModel> updateStore(int storeId, Map<String, dynamic> storeData) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Xóa cửa hàng.
  Future<void> deleteStore(int storeId) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  // ======================== QUẢN LÝ BẾP TRUNG TÂM (KITCHENS) ========================

  /// Lấy danh sách bếp trung tâm.
  /// TODO 2.3.1: Gọi GET lên ApiConstants.adminKitchensUrl và parse sang List<KitchenModel>.
  Future<List<KitchenModel>> getKitchens() async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Tạo bếp trung tâm mới.
  Future<KitchenModel> createKitchen(Map<String, dynamic> kitchenData) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Cập nhật bếp trung tâm.
  Future<KitchenModel> updateKitchen(int kitchenId, Map<String, dynamic> kitchenData) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }

  /// Xóa bếp trung tâm.
  Future<void> deleteKitchen(int kitchenId) async {
    // Để trống cho bạn tự viết.
    throw UnimplementedError();
  }
}
