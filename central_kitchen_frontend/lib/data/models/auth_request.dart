/// Lớp dữ liệu chứa thông tin gửi lên API Đăng nhập.
/// Tương ứng với LoginRequestDto bên phía ASP.NET Core.
class AuthRequest {
  final String username;
  final String password;

  AuthRequest({
    required this.username,
    required this.password,
  });

  /// Hàm chuyển đổi từ Object Dart sang Map JSON để Dio gửi lên Server.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
