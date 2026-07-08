/// Lớp chứa các hằng số cấu hình API của hệ thống Central Kitchen.
class ApiConstants {
  /// Địa chỉ base URL của API Backend.
  /// LƯU Ý: 'http://10.0.2.2:5170' là địa chỉ đặc biệt trỏ về localhost của máy host
  /// khi chạy trên Android Emulator. Nếu bạn dùng iOS Simulator, hãy đổi thành 'http://localhost:5170'.
  /// Nếu bạn dùng thiết bị thật, hãy cấu hình IP Wi-Fi cục bộ của máy chạy backend.
  static const String baseUrl = 'https://cencentral-kitchen-franchise-system.onrender.com';

  /// Endpoint gọi API Đăng nhập
  static const String loginUrl = '/api/auth/login';

  /// Endpoint quản lý Users (Admin)
  static const String adminUsersUrl = '/api/admin/users';

  /// Endpoint quản lý Cửa hàng Franchise (Admin)
  static const String adminStoresUrl = '/api/admin/stores';

  /// Endpoint quản lý Bếp Trung Tâm (Admin)
  static const String adminKitchensUrl = '/api/admin/stores/kitchens';

  /// Endpoint danh mục nguyên liệu
  static const String ingredientsUrl = '/api/ingredients';

  /// Endpoint batch và production plan
  static const String kitchenBatchesUrl = '/api/kitchen/batches';
  static const String kitchenProductionPlanUrl = '/api/kitchen/production-plan';
}
