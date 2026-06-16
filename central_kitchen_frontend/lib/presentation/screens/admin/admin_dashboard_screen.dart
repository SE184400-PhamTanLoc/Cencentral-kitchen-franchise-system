import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../business/providers/auth_provider.dart';
import '../../../../business/providers/admin_provider.dart';
import '../../../../core/constants/app_theme.dart';
import 'manage_users_screen.dart';
import 'manage_stores_screen.dart';

/// Màn hình Dashboard trung tâm của Admin.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động tải dữ liệu thống kê ban đầu khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProv = context.read<AdminProvider>();
      adminProv.fetchUsers();
      adminProv.fetchStores();
      adminProv.fetchKitchens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await authProv.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LỜI CHÀO ADMIN ---
            Text(
              'Xin chào, ${authProv.currentUser?.fullName ?? 'N/A'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const Text(
              'Chào mừng bạn đến với hệ thống quản trị Central Kitchen Pro.',
              style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // --- THỐNG KÊ TỔNG QUAN ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Nhân viên',
                    count: adminProv.users.length.toString(),
                    icon: Icons.people_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Cửa hàng',
                    count: adminProv.stores.length.toString(),
                    icon: Icons.store_mall_directory_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Bếp trung tâm',
                    count: adminProv.kitchens.length.toString(),
                    icon: Icons.kitchen_outlined,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- MENU QUẢN LÝ CHỨC NĂNG ---
            const Text(
              'Danh mục Quản lý',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),

            _buildMenuItem(
              title: 'Quản lý Tài khoản Nhân viên',
              subtitle: 'Thêm mới, phân quyền, cấp bếp/cửa hàng cho nhân viên',
              icon: Icons.supervised_user_circle_outlined,
              color: AppTheme.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildMenuItem(
              title: 'Quản lý Cửa hàng & Bếp trung tâm',
              subtitle: 'Quản lý chi nhánh nhượng quyền, bếp sản xuất, hạn mức công nợ',
              icon: Icons.business_outlined,
              color: AppTheme.secondary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageStoresScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng thẻ thống kê số liệu
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  // Widget xây dựng dòng menu chức năng
  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}
