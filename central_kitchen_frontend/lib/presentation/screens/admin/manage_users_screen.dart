import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../business/providers/admin_provider.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/constants/app_theme.dart';

/// Màn hình quản lý danh sách tài khoản nhân viên.
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // Biến phục vụ thanh tìm kiếm cục bộ
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Tải danh sách người dùng khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final usersList = adminProv.users.where((user) {
      return user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openEditUserDialog(null), // Mở dialog thêm mới (user = null)
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo họ tên hoặc username...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // 2. Trạng thái Loading hoặc danh sách rỗng
          if (adminProv.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (usersList.isEmpty)
            const Expanded(child: Center(child: Text('Không tìm thấy tài khoản nhân viên nào.')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final user = usersList[index];
                  return _buildUserCard(user);
                },
              ),
            ),
        ],
      ),
    );
  }

  // Widget vẽ Card hiển thị thông tin nhân viên
  Widget _buildUserCard(UserModel user) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                // Chip trạng thái hoạt động
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Locked',
                    style: TextStyle(fontSize: 12, color: user.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('@${user.username} - Vai trò: ${user.roleName}', style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            if (user.email != null)
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 14, color: AppTheme.outline),
                  const SizedBox(width: 6),
                  Text(user.email!, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            if (user.phoneNumber != null)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppTheme.outline),
                  const SizedBox(width: 6),
                  Text(user.phoneNumber!, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            // Hiển thị bếp hoặc cửa hàng được phân phối
            if (user.kitchenName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Bếp: ${user.kitchenName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
              )
            else if (user.storeName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Cửa hàng: ${user.storeName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            const Divider(height: 20),
            
            // Các nút Hành động (Sửa, Xóa)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.secondary),
                  onPressed: () => _openEditUserDialog(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined, color: AppTheme.error),
                  onPressed: () => _confirmDeleteUser(user.userId, user.fullName),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- POPUP THÊM/SỬA TÀI KHOẢN ---
  void _openEditUserDialog(UserModel? user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _UserEditDialog(
          user: user,
          onSaved: () {
            context.read<AdminProvider>().fetchUsers(); // Tải lại danh sách sau khi lưu
          },
        );
      },
    );
  }

  // --- POPUP XÁC NHẬN XÓA ---
  void _confirmDeleteUser(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa tài khoản của "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().removeUser(userId);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa tài khoản thành công!')));
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

// Widget Dialog con tự quản lý Form dữ liệu nhập vào để tránh re-render toàn màn hình cha
class _UserEditDialog extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onSaved;

  const _UserEditDialog({this.user, required this.onSaved});

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _selectedRoleId = 3; // Default Role: Franchise Staff (3)
  int? _selectedKitchenId;
  int? _selectedStoreId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    // Điền thông tin cũ vào ô nhập nếu đang ở chế độ Chỉnh sửa (user != null)
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email ?? '';
      _phoneController.text = widget.user!.phoneNumber ?? '';
      _selectedRoleId = widget.user!.roleId;
      _selectedKitchenId = widget.user!.kitchenId;
      _selectedStoreId = widget.user!.storeId;
      _isActive = widget.user!.isActive;
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.user != null;
    final adminProv = context.watch<AdminProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_note_outlined : Icons.person_add_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Chỉnh sửa tài khoản' : 'Thêm tài khoản mới',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Điền thông tin tài khoản nhân sự hệ thống',
                            style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Username (chỉ cho nhập khi Thêm mới)
                TextFormField(
                  controller: _usernameController,
                  enabled: !isEditMode,
                  decoration: _buildInputDecoration('Tên đăng nhập (Username)', Icons.person_outline),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng điền Username' : null,
                ),
                const SizedBox(height: 14),

                // Password (chỉ bắt buộc khi Thêm mới)
                if (!isEditMode) ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Mật khẩu', Icons.lock_outline),
                    validator: (val) => val == null || val.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // FullName
                TextFormField(
                  controller: _fullNameController,
                  decoration: _buildInputDecoration('Họ tên nhân viên', Icons.badge_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng điền họ tên' : null,
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration('Email', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration('Số điện thoại', Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                // Dropdown Chọn Vai trò (RoleId)
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: const [1, 2, 3, 4, 5].contains(_selectedRoleId) ? _selectedRoleId : null,
                  decoration: _buildInputDecoration('Vai trò', Icons.assignment_ind_outlined),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Admin')),
                    DropdownMenuItem(value: 2, child: Text('Quản lý chuỗi', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 3, child: Text('Nhân viên Cửa hàng', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 4, child: Text('Nhân viên Bếp', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 5, child: Text('Điều phối cung ứng', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleId = val;
                        // Reset các lựa chọn phụ thuộc khi đổi vai trò
                        if (_selectedRoleId != 4 && _selectedRoleId != 5) _selectedKitchenId = null;
                        if (_selectedRoleId != 3) _selectedStoreId = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Dropdown Chọn Bếp (Nếu vai trò là Nhân viên Bếp - RoleId = 4 hoặc Điều phối cung ứng - RoleId = 5)
                if (_selectedRoleId == 4 || _selectedRoleId == 5) ...[
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: adminProv.kitchens.any((k) => k.kitchenId == _selectedKitchenId) ? _selectedKitchenId : null,
                    decoration: _buildInputDecoration('Chọn Bếp phân công', Icons.kitchen_outlined),
                    items: adminProv.kitchens.map((k) {
                      return DropdownMenuItem(
                        value: k.kitchenId,
                        child: Text(k.kitchenName, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedKitchenId = val),
                    validator: (val) => val == null ? 'Vui lòng chọn bếp trung tâm' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // Dropdown Chọn Cửa hàng (Nếu vai trò là Nhân viên Cửa hàng - RoleId = 3)
                if (_selectedRoleId == 3) ...[
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: adminProv.stores.any((s) => s.storeId == _selectedStoreId) ? _selectedStoreId : null,
                    decoration: _buildInputDecoration('Chọn Cửa hàng phân công', Icons.store_mall_directory_outlined),
                    items: adminProv.stores.map((s) {
                      return DropdownMenuItem(
                        value: s.storeId,
                        child: Text(s.storeName, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStoreId = val),
                    validator: (val) => val == null ? 'Vui lòng chọn cửa hàng franchise' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                if (isEditMode) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text('Trạng thái hoạt động', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      value: _isActive,
                      activeColor: AppTheme.secondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 10),
                ],

                // Action buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Hủy', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final provider = context.read<AdminProvider>();
                          
                          // Xây dựng DTO dữ liệu
                          final userData = {
                            'fullName': _fullNameController.text.trim(),
                            'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                            'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                            'roleId': _selectedRoleId,
                            'kitchenId': _selectedKitchenId,
                            'storeId': _selectedStoreId,
                            'isActive': _isActive,
                          };

                          bool success;
                          if (isEditMode) {
                            success = await provider.editUser(widget.user!.userId, userData);
                          } else {
                            // Đối với tạo mới, đẩy thêm trường username và password
                            userData['username'] = _usernameController.text.trim();
                            userData['password'] = _passwordController.text;
                            success = await provider.addUser(userData);
                          }

                          if (mounted) {
                            if (success) {
                              Navigator.pop(context);
                              widget.onSaved();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditMode ? 'Cập nhật thành công!' : 'Tạo tài khoản thành công!')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Có lỗi xảy ra!')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
