/// Lớp dữ liệu chứa thông tin phản hồi từ API Đăng nhập thành công.
/// Tương ứng với LoginResponseDto bên phía ASP.NET Core.
class AuthResponse {
  final String token;
  final DateTime expiration;
  final int userId;
  final String username;
  final String fullName;
  final String roleCode;
  final String roleName;
  final int? kitchenId;
  final int? storeId;

  AuthResponse({
    required this.token,
    required this.expiration,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.roleCode,
    required this.roleName,
    this.kitchenId,
    this.storeId,
  });

  /// Hàm khởi tạo Factory để chuyển đổi dữ liệu từ Map JSON (nhận từ API) thành Object Dart.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['Token'] ?? '',
      expiration: DateTime.parse(json['expiration'] ?? json['Expiration'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? json['UserId'] ?? 0,
      username: json['username'] ?? json['Username'] ?? '',
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      roleCode: json['roleCode'] ?? json['RoleCode'] ?? '',
      roleName: json['roleName'] ?? json['RoleName'] ?? '',
      kitchenId: json['kitchenId'] ?? json['KitchenId'],
      storeId: json['storeId'] ?? json['StoreId'],
    );
  }

  /// Hàm chuyển đổi ngược từ Object Dart sang Map JSON để lưu trữ hoặc truyền đi.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiration': expiration.toIso8601String(),
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'roleCode': roleCode,
      'roleName': roleName,
      'kitchenId': kitchenId,
      'storeId': storeId,
    };
  }
}
