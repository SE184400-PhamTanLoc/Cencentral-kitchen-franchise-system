/// Lớp dữ liệu UserModel biểu diễn thông tin tài khoản người dùng hệ thống.
/// Ánh xạ từ UserResponseDto của ASP.NET Core Backend.
class UserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final int roleId;
  final String roleCode;
  final String roleName;
  final int? kitchenId;
  final String? kitchenName;
  final int? storeId;
  final String? storeName;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.roleId,
    required this.roleCode,
    required this.roleName,
    this.kitchenId,
    this.kitchenName,
    this.storeId,
    this.storeName,
    required this.isActive,
    this.createdAt,
  });

  /// Hàm khởi tạo Factory chuyển đổi từ dữ liệu JSON của API sang đối tượng Dart.
  /// TODO 1.2.1: Triển khai ánh xạ các thuộc tính từ Map [json] của API.
  /// Gợi ý:
  /// factory UserModel.fromJson(Map<String, dynamic> json) {
  ///   return UserModel(
  ///     userId: json['userId'] ?? 0,
  ///     username: json['username'] ?? '',
  ///     fullName: json['fullName'] ?? '',
  ///     email: json['email'],
  ///     phoneNumber: json['phoneNumber'],
  ///     roleId: json['roleId'] ?? 0,
  ///     roleCode: json['roleCode'] ?? '',
  ///     roleName: json['roleName'] ?? '',
  ///     kitchenId: json['kitchenId'],
  ///     kitchenName: json['kitchenName'],
  ///     storeId: json['storeId'],
  ///     storeName: json['storeName'],
  ///     isActive: json['isActive'] ?? true,
  ///     createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  ///   );
  /// }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      roleId: json['roleId'] ?? 0,
      roleCode: json['roleCode'] ?? '',
      roleName: json['roleName'] ?? '',
      kitchenId: json['kitchenId'],
      kitchenName: json['kitchenName'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  /// Hàm chuyển đổi đối tượng sang định dạng JSON gửi lên API khi Tạo/Cập nhật.
  /// Quyết định gửi các trường cần thiết lên Server.
  /// TODO 1.2.2: Trả về một Map chứa các trường dữ liệu để làm payload cho Create/Update API.
  /// Gợi ý:
  /// Map<String, dynamic> toJson() {
  ///   return {
  ///     'fullName': fullName,
  ///     'email': email,
  ///     'phoneNumber': phoneNumber,
  ///     'roleId': roleId,
  ///     'kitchenId': kitchenId,
  ///     'storeId': storeId,
  ///     'isActive': isActive,
  ///   };
  /// }
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'roleId': roleId,
      'kitchenId': kitchenId,
      'storeId': storeId,
      'isActive': isActive,
    };
  }
}
