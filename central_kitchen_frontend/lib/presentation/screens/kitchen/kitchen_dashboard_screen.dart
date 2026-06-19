import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/providers/auth_provider.dart';
import '../../../core/constants/app_theme.dart';
import 'kitchen_inventory_management_screen.dart';

class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({super.key});

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen> {
  int _selectedIndex = 0;

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _openAvatarMenu(BuildContext context) {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      _avatarInitial(auth.currentUser?.fullName),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(auth.currentUser?.fullName ?? 'Nhân viên bếp'),
                  subtitle: Text(auth.currentUser?.roleName ?? 'Kitchen staff'),
                ),
                const SizedBox(height: 8),
                _MenuTile(
                  icon: Icons.person_outline,
                  title: 'Trang cá nhân',
                  subtitle: 'Xem thông tin tài khoản và vai trò',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _selectedIndex = 2);
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.logout_outlined,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản hiện tại',
                  danger: true,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _logout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _KitchenHomeTab(
        onOpenInventory: () => setState(() => _selectedIndex = 1),
        onOpenProfile: () => setState(() => _selectedIndex = 2),
        onAvatarTap: () => _openAvatarMenu(context),
      ),
      const KitchenInventoryManagementScreen(),
      _KitchenProfileTab(
        onLogout: () => _logout(context),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceVariant,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Tồn kho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  String _avatarInitial(String? fullName) {
    final name = (fullName ?? 'K').trim();
    if (name.isEmpty) return 'K';
    return name.characters.first.toUpperCase();
  }
}

class _KitchenHomeTab extends StatelessWidget {
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenProfile;
  final VoidCallback onAvatarTap;

  const _KitchenHomeTab({
    required this.onOpenInventory,
    required this.onOpenProfile,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kitchen Ops', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Xin chào, ${auth.currentUser?.fullName ?? 'Nhân viên bếp'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                InkWell(
                  onTap: onAvatarTap,
                  borderRadius: BorderRadius.circular(999),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      _avatarInitial(auth.currentUser?.fullName),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _HeroCard(
              onTap: onOpenInventory,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Kho theo bếp',
                    subtitle: 'Tabs nguyên liệu, batches và BOM',
                    color: AppTheme.secondary,
                    onTap: onOpenInventory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.badge_outlined,
                    title: 'Trang cá nhân',
                    subtitle: 'Xem thông tin tài khoản',
                    color: AppTheme.primary,
                    onTap: onOpenProfile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Luồng làm việc gợi ý',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                  ),
                  SizedBox(height: 12),
                  Text('1. Mở tab Tồn kho để xem batch và nguyên liệu.'),
                  SizedBox(height: 8),
                  Text('2. Dùng tab BOM để tính định mức xuất kho.'),
                  SizedBox(height: 8),
                  Text('3. Bấm avatar để mở trang cá nhân hoặc đăng xuất.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarInitial(String? fullName) {
    final name = (fullName ?? 'K').trim();
    if (name.isEmpty) return 'K';
    return name.characters.first.toUpperCase();
  }
}

class _KitchenProfileTab extends StatelessWidget {
  final Future<void> Function() onLogout;

  const _KitchenProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trang cá nhân',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thông tin tài khoản bếp hiện tại.',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      _avatarInitial(user?.fullName),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Nhân viên bếp',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(user?.username ?? '-', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Vai trò', value: user?.roleName ?? '-'),
                  _InfoRow(label: 'Kitchen ID', value: auth.kitchenId?.toString() ?? '-'),
                  _InfoRow(label: 'Store ID', value: auth.storeId?.toString() ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async => onLogout(),
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarInitial(String? fullName) {
    final name = (fullName ?? 'K').trim();
    if (name.isEmpty) return 'K';
    return name.characters.first.toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF00236F), Color(0xFF0058BE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kho nguyên liệu', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text(
                    'Quản lý danh mục, batch và định mức sản xuất',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bật vào danh mục nguyên liệu để theo dõi tồn kho theo thời gian thực.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Chip(
                    label: Text('Tap to explore'),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.kitchen_outlined, color: Colors.white, size: 38),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : AppTheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? Colors.redAccent.withOpacity(0.06) : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: danger ? Colors.redAccent.withOpacity(0.15) : AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
