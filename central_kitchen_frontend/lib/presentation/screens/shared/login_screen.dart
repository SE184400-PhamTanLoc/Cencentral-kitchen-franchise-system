import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../business/providers/auth_provider.dart';
import '../../../../core/constants/app_theme.dart';

/// Màn hình đăng nhập tài khoản hệ thống (Login Screen).
/// Kế thừa StatefulWidget để quản lý trạng thái ẩn/hiện mật khẩu ngay tại giao diện.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- CÁC BIẾN QUẢN LÝ FORM & INPUT ---
  
  // Khóa định danh cho Form để kiểm tra hợp lệ dữ liệu (Validation)
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển dữ liệu nhập vào ô Email/Mật khẩu
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Trạng thái ẩn/hiện mật khẩu (true: ẩn dưới dạng ••••, false: hiện rõ chữ)
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    // Giải phóng bộ nhớ của các bộ điều khiển khi hủy màn hình
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- CÁC HÀM XỬ LÝ SỰ KIỆN (Event Handlers) ---

  /// Xử lý sự kiện khi bấm nút Đăng nhập.
  /// 
  /// TODO 4.1.1: Thực hiện đăng nhập và điều hướng theo vai trò (Role Routing).
  /// Gợi ý các bước triển khai:
  /// 1. Kiểm tra validation của form:
  ///    if (!_formKey.currentState!.validate()) return; // Nếu dữ liệu không hợp lệ thì dừng lại
  /// 
  /// 2. Lấy đối tượng AuthProvider từ context:
  ///    final authProvider = context.read<AuthProvider>();
  /// 
  /// 3. Gọi hàm login bên Provider và đợi kết quả:
  ///    final isSuccess = await authProvider.login(
  ///      _emailController.text.trim(),
  ///      _passwordController.text
  ///    );
  /// 
  /// 4. Xử lý sau khi gọi API:
  ///    if (isSuccess) {
  ///       // Đăng nhập thành công -> Hiển thị Snackbar hoặc Dialog thông báo thành công
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         const SnackBar(content: Text('Đăng nhập thành công!'))
  ///       );
  ///       
  ///       // Lấy vai trò của user vừa đăng nhập để điều hướng
  ///       final role = authProvider.userRole;
  ///       
  ///       // TODO 4.1.2: Điều hướng người dùng vào đúng phân hệ:
  ///       // - role == 'ADMIN' -> Đi tới trang Admin Dashboard
  ///       // - role == 'KITCHEN_STAFF' -> Đi tới trang Bếp Trung Tâm (Kitchen)
  ///       // - role == 'FRANCHISE_STAFF' -> Đi tới trang Cửa hàng Nhượng Quyền (Franchise)
  ///       // Gợi ý: Navigator.pushReplacementNamed(context, '/admin');
  ///    } else {
  ///       // Đăng nhập thất bại -> Hiển thị thông báo lỗi lên màn hình
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text(authProvider.errorMessage ?? 'Có lỗi xảy ra'))
  ///       );
  ///    }
  void _submitLogin() async {
    // 1. Kiểm tra validation của form
    if (!_formKey.currentState!.validate()) {
      return; // Dừng lại nếu form không hợp lệ
    }

    final authProvider = context.read<AuthProvider>();

    // 2. Gọi hàm login bên Provider và đợi kết quả
    final isSuccess = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Kiểm tra Widget còn hiển thị trong Widget Tree hay không trước khi gọi BuildContext
    if (!mounted) return;

    // 3. Xử lý sau khi gọi API
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công!')),
      );

      final role = authProvider.userRole;

      // Điều hướng người dùng vào đúng phân hệ dựa theo vai trò
      if (role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'KITCHEN_STAFF') {
        Navigator.pushReplacementNamed(context, '/kitchen');
      } else if (role == 'SUPPLY_COORDINATOR') {
        Navigator.pushReplacementNamed(context, '/coordinator');
      } else if (role == 'MANAGER') {
        Navigator.pushReplacementNamed(context, '/manager');
      } else {
        Navigator.pushReplacementNamed(context, '/franchise');
      }
    } else {
      // Đăng nhập thất bại -> Hiển thị thông báo lỗi lên màn hình
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Tên đăng nhập hoặc mật khẩu không chính xác')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đọc trạng thái loading từ AuthProvider để hiển thị vòng xoay tải dữ liệu
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Lớp hình nền mờ (Watermark / Blur Background)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // 2. Nội dung chính màn hình Đăng nhập (Căn giữa)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- LOGO THƯƠNG HIỆU ---
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- TIÊU ĐỀ HỆ THỐNG ---
                      Center(
                        child: Text(
                          'Central Kitchen Pro',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Logistics & Supply Chain Management',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- KHUNG ĐIỀN THÔNG TIN ĐĂNG NHẬP (Form Container) ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- Ô NHẬP USERNAME HOẶC EMAIL ---
                            Text(
                              'ENTERPRISE USERNAME OR EMAIL',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'admin hoặc name@company.com',
                                prefixIcon: Icon(Icons.person_outline, color: AppTheme.onSurfaceVariant),
                              ),
                              // Kiểm tra dữ liệu đầu vào không được để trống
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tên đăng nhập hoặc Email không được để trống';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // --- Ô NHẬP MẬT KHẨU ---
                            Text(
                              'PASSWORD',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isPasswordObscured,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscured
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscured = !_isPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mật khẩu không được để trống';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // --- QUÊN MẬT KHẨU ---
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  // Xử lý khi nhấn Quên mật khẩu
                                },
                                child: const Text(
                                  'Forgot Enterprise Password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- NÚT ĐĂNG NHẬP (Bấm để kích hoạt luồng Submit) ---
                            ElevatedButton(
                              onPressed: isLoading ? null : _submitLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Login'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- LIÊN HỆ ĐỘI IT (HỖ TRỢ) ---
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppTheme.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ADMIN SUPPORT',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          const Expanded(child: Divider(color: AppTheme.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Xử lý khi nhấn Liên hệ IT Support
                        },
                        icon: const Icon(Icons.contact_support_outlined, color: AppTheme.onSurfaceVariant),
                        label: const Text(
                          'Contact Corporate IT Support',
                          style: TextStyle(color: AppTheme.onSurfaceVariant),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: const BorderSide(color: AppTheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      // --- CHÂN TRANG (Footer) ---
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const Text('Security Standards', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('•', style: TextStyle(color: AppTheme.outlineVariant)),
                          ),
                          InkWell(
                            onTap: () {},
                            child: const Text('Privacy Policy', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'System v4.2.0 • Build 2023.11.24',
                          style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant), // Loại bỏ thuộc tính opacity không hợp lệ
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
