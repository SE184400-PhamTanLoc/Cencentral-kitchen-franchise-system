import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/models/auth_request.dart';
import '../../data/models/auth_response.dart';

/// Lớp quản lý trạng thái phiên đăng nhập của người dùng toàn ứng dụng.
/// Kế thừa ChangeNotifier để cập nhật lại UI bất cứ khi nào trạng thái thay đổi.
class AuthProvider with ChangeNotifier {
  final AuthDatasource _authDatasource;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- CÁC BIẾN TRẠNG THÁI (State Variables) ---
  String? _token;
  AuthResponse? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authDatasource);

  // --- CÁC HÀM GETTER (Để UI đọc dữ liệu nhưng không thay đổi trực tiếp được) ---
  bool get isAuthenticated => _token != null;
  AuthResponse? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _currentUser?.roleCode; // Lấy Vai trò (ADMIN, KITCHEN_STAFF...)

  // --- CÁC PHƯƠNG THỨC XỬ LÝ NGHIỆP VỤ ---

  /// Hàm đăng nhập tài khoản.
  /// Trả về [true] nếu đăng nhập thành công, [false] nếu thất bại.
  /// 
  /// TODO 3.1.1: Thực hiện luồng đăng nhập hệ thống.
  /// Gợi ý các bước code chi tiết:
  /// 1. Bật trạng thái tải:
  ///    _isLoading = true;
  ///    _errorMessage = null;
  ///    notifyListeners(); // Báo cho UI biết để hiện vòng xoay Loading
  /// 
  /// 2. Gọi API đăng nhập qua datasource:
  ///    try {
  ///      final response = await _authDatasource.login(
  ///        AuthRequest(username: username, password: password)
  ///      );
  ///      
  ///      // Lưu token và thông tin người dùng vào biến state
  ///      _token = response.token;
  ///      _currentUser = response;
  ///      
  ///      // Lưu bảo mật xuống bộ nhớ trong của máy để tự động đăng nhập lần sau
  ///      await _storage.write(key: 'jwt_token', value: response.token);
  ///      // Gợi ý: Có thể convert thông tin user sang json string để lưu
  ///      // await _storage.write(key: 'user_data', value: json.encode(response.toJson())); 
  ///      
  ///      _isLoading = false;
  ///      notifyListeners(); // Cập nhật lại UI sau khi đã đăng nhập thành công
  ///      return true;
  ///    } catch (e) {
  ///      // Xử lý khi xảy ra lỗi (Sai mật khẩu, Mất mạng...)
  ///      _isLoading = false;
  ///      _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin!';
  ///      notifyListeners();
  ///      return false;
  ///    }
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authDatasource.login(
        AuthRequest(username: username, password: password),
      );
      
      _token = response.token;
      _currentUser = response;
      await _storage.write(key: 'jwt_token', value: response.token);
      await _storage.write(key: 'user_data', value: json.encode(response.toJson()));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('LOGIN ERROR DETECTED: $e');
      _isLoading = false;
      _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin!';
      notifyListeners();
      return false;
    }
  }

  /// Hàm đăng xuất tài khoản.
  /// Xóa sạch thông tin đăng nhập cũ và đưa trạng thái về ban đầu.
  /// 
  /// TODO 3.2.1: Triển khai đăng xuất.
  /// Gợi ý các bước:
  /// 1. Xóa các key đã lưu trong Secure Storage:
  ///    await _storage.delete(key: 'jwt_token');
  ///    await _storage.delete(key: 'user_data');
  /// 2. Gán các biến trạng thái về null:
  ///    _token = null;
  ///    _currentUser = null;
  /// 3. Gọi notifyListeners() để UI cập nhật (ví dụ chuyển hướng về màn hình đăng nhập)
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  /// Hàm kiểm tra Token cũ khi mở App (Tự động đăng nhập).
  /// Trả về [true] nếu Token hợp lệ và chưa hết hạn, ngược lại trả về [false].
  /// 
  /// TODO 3.3.1: Triển khai kiểm tra trạng thái đăng nhập tự động.
  /// Gợi ý các bước:
  /// 1. Đọc token và user_data từ storage:
  ///    final savedToken = await _storage.read(key: 'jwt_token');
  ///    final savedUserData = await _storage.read(key: 'user_data');
  /// 2. Nếu 1 trong 2 thông tin trống -> Trả về false.
  /// 3. Nếu có dữ liệu, kiểm tra thời gian hết hạn (expiration):
  ///    - Parse dữ liệu user_data và so sánh:
  ///      DateTime.now().isBefore(expirationTime)
  /// 4. Nếu Token vẫn hợp lệ:
  ///    - Gán _token = savedToken;
  ///    - Gán _currentUser = AuthResponse.fromJson(json.decode(savedUserData));
  ///    - Gọi notifyListeners() và trả về true.
  /// 5. Nếu hết hạn -> Gọi hàm logout() và trả về false.
  Future<bool> tryAutoLogin() async {
    final savedToken = await _storage.read(key: 'jwt_token');
    final savedUserData = await _storage.read(key: 'user_data');
    if(savedToken == null || savedUserData == null){
      return false;
    }
    try{
      final AuthResponse currentUser = AuthResponse.fromJson(json.decode(savedUserData));
      final DateTime expirationTime = currentUser.expiration.add(const Duration(seconds: -60));
      if(!DateTime.now().isBefore(expirationTime)){
        await logout();
        return false;
      }
      _token = savedToken;
      _currentUser = currentUser;
      notifyListeners();
      return true;
    }catch(e){
      await logout();
      return false;
    }
  }
}
