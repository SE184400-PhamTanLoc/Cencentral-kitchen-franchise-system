import '../../core/network/api_client.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../../core/constants/api_constants.dart';

/// Lớp kết nối trực tiếp với các API endpoints liên quan đến Xác thực.
class AuthDatasource {
  final ApiClient _apiClient;

  AuthDatasource(this._apiClient);

  /// Gọi API đăng nhập hệ thống.
  /// Nhận vào [AuthRequest] chứa thông tin đăng nhập và trả về [AuthResponse].
  Future<AuthResponse> login(AuthRequest request) async {
    final response = await _apiClient.post(ApiConstants.loginUrl, data: request.toJson());
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseBody = response.data;
      final Map<String, dynamic> userData = responseBody['data'];
      return AuthResponse.fromJson(userData);
    } else {
      final errorMessage = response.data?['message'] ?? 'Tên đăng nhập hoặc mật khẩu không chính xác';
      throw Exception(errorMessage);
    }
  }
}
