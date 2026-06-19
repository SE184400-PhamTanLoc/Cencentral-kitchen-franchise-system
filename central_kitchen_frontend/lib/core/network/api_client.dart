import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../navigation/navigator_key.dart';

/// Lớp HttpClient trung tâm đóng gói thư viện Dio.
/// Quản lý gọi API, tự động đính kèm Token và xử lý lỗi hệ thống.
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Khởi tạo instance ApiClient và cấu hình các thuộc tính cơ bản
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10), // Hạn chờ kết nối: 10s
            receiveTimeout: const Duration(seconds: 10), // Hạn chờ nhận dữ liệu: 10s
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Đăng ký các bộ chặn (Interceptors) để tự động hóa luồng request/response
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Đọc Token đã lưu từ Flutter Secure Storage
          String? token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('--> [REQUEST] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('<-- [RESPONSE] ${response.statusCode} ${response.realUri}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print('[ERROR] ${error.response?.statusCode} - ${error.message}');
          
          if (error.response?.statusCode == 401) {
            // Token hết hạn hoặc không hợp lệ -> Xóa token cũ và điều hướng về Login
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'user_data');
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  /// Getter để các Datasources khác lấy instance của Dio ra sử dụng
  Dio get dio => _dio;

  // --- CÁC HÀM TIỆN ÍCH GỌI API RÚT GỌN ---
  // Bạn có thể dùng trực tiếp các hàm này ở DataSources để code ngắn gọn hơn.

  /// Gửi HTTP GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// Gửi HTTP POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// Gửi HTTP PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Gửi HTTP DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
