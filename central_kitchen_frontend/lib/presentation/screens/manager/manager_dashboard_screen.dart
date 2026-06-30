import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_theme.dart';
import '../../../business/providers/manager_provider.dart';
import '../../../business/providers/auth_provider.dart';
import '../../../data/models/manager_stats_model.dart';
import '../../widgets/unified_order_card.dart';
import '../../widgets/shared_order_details_modal.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadDashboardData();
    });
  }

  String _avatarInitial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _openUserMenu(BuildContext context) {
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
                    backgroundColor: AppTheme.primaryContainer,
                    child: Text(
                      _avatarInitial(auth.currentUser?.fullName),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(auth.currentUser?.fullName ?? 'Quản lý'),
                  subtitle: Text(auth.currentUser?.roleName ?? 'Manager'),
                ),
                const SizedBox(height: 8),

                _ManagerMenuTile(
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

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 78,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${auth.currentUser?.fullName ?? 'Quản lý'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 3),
            const Text(
              'Tổng quan hệ thống & quản trị',
              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => context.read<ManagerProvider>().loadDashboardData(),
            icon: const Icon(Icons.refresh_outlined),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _openUserMenu(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  _avatarInitial(auth.currentUser?.fullName),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      body: SafeArea(
        child: Consumer<ManagerProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: provider.isLoadingStats && provider.stats == null
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                        )
                      : provider.errorMessage != null
                          ? Center(
                              child: Text(
                                'Lỗi hệ thống: ${provider.errorMessage}',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            )
                          : _selectedTabIndex == 0
                              ? SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildBentoStatsMatrix(provider.stats, formatCurrency, isDesktop: false),
                                      const SizedBox(height: 24),
                                      _buildCoreModules(isDesktop: false),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _buildOrderCommandCenter(provider, formatCurrency, isMobile: false),
                                ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: const Color(0xFF64748B),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Báo cáo tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions_rounded),
              label: 'Duyệt đơn',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoStatsMatrix(ManagerStatsModel? stats, NumberFormat format, {required bool isDesktop}) {
    if (stats == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chỉ số quan trọng',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildModernStatCard(
                'Tổng Chi Nhánh', 
                stats.totalStores.toString(), 
                Icons.storefront_rounded, 
                const Color(0xFFEFF6FF), 
                const Color(0xFF0058BE),
                '+2 mới'
              ),
              _buildModernStatCard(
                'Doanh thu hôm nay', 
                format.format(stats.todayRevenue), 
                Icons.payments_rounded, 
                const Color(0xFFECFDF5), 
                const Color(0xFF10B981),
                '+12%'
              ),
              _buildModernStatCard(
                'Rủi ro Công nợ', 
                format.format(stats.totalDebt), 
                Icons.trending_down_rounded, 
                const Color(0xFFFEF2F2), 
                const Color(0xFFEF4444),
                '-5%'
              ),
              _buildModernStatCard(
                'Đơn chờ duyệt', 
                stats.totalPendingOrders.toString(), 
                Icons.assignment_late_rounded, 
                const Color(0xFFFFFBEB), 
                const Color(0xFFF59E0B),
                '3 gấp'
              ),
            ],
          )
        else
          Column(
            children: [
              // Card 1: Today's Revenue (Full Width - Primary Highlight)
              SizedBox(
                height: 100,
                width: double.infinity,
                child: _buildModernStatCard(
                  'Doanh thu hôm nay', 
                  format.format(stats.todayRevenue), 
                  Icons.payments_rounded, 
                  const Color(0xFFECFDF5), 
                  const Color(0xFF10B981),
                  '+12%',
                  isFullWidth: true,
                ),
              ),
              const SizedBox(height: 12),
              // Row 2: 2 supporting metrics (Half Width each)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 140,
                      child: _buildModernStatCard(
                        'Đơn chờ duyệt', 
                        stats.totalPendingOrders.toString(), 
                        Icons.assignment_late_rounded, 
                        const Color(0xFFFFFBEB), 
                        const Color(0xFFF59E0B),
                        '3 gấp',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 140,
                      child: _buildModernStatCard(
                        'Tổng Chi Nhánh', 
                        stats.totalStores.toString(), 
                        Icons.storefront_rounded, 
                        const Color(0xFFEFF6FF), 
                        const Color(0xFF0058BE),
                        '+2 mới',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Card 4: Debt Risk (Full Width - Secondary Highlight)
              SizedBox(
                height: 100,
                width: double.infinity,
                child: _buildModernStatCard(
                  'Rủi ro Công nợ', 
                  format.format(stats.totalDebt), 
                  Icons.trending_down_rounded, 
                  const Color(0xFFFEF2F2), 
                  const Color(0xFFEF4444),
                  '-5%',
                  isFullWidth: true,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
    String trend, {
    bool isFullWidth = false,
  }) {
    Color mappedBg = bgColor;
    Color mappedFg = iconColor;
    if (title.contains('Doanh thu')) {
      mappedBg = const Color(0xFFECFDF5);
      mappedFg = const Color(0xFF10B981);
    } else if (title.contains('Công nợ') || title.contains('Rủi ro')) {
      mappedBg = const Color(0xFFFEF2F2);
      mappedFg = const Color(0xFFEF4444);
    } else if (title.contains('chờ duyệt') || title.contains('Đơn')) {
      mappedBg = const Color(0xFFFFFBEB);
      mappedFg = const Color(0xFFF59E0B);
    } else {
      mappedBg = const Color(0xFFEFF6FF);
      mappedFg = const Color(0xFF0058BE);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isFullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mappedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: mappedFg, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: mappedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(color: mappedFg, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mappedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: mappedFg, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: mappedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(color: mappedFg, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCoreModules({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tính năng Quản trị',
          style: TextStyle(color: Color(0xFF334155), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            _buildActionCard(
              context,
              'Danh mục & BOM', 
              Icons.account_tree_rounded, 
              const Color(0xFFF0FDF4), 
              const Color(0xFF16A34A),
              route: '/manager/catalog',
            ),
            _buildActionCard(
              context,
              'Giám sát Tồn kho', 
              Icons.inventory_2_rounded, 
              const Color(0xFFFFF7ED), 
              const Color(0xFFEA580C),
              route: '/manager/inventory',
            ),
            _buildActionCard(
              context,
              'Báo cáo & Phân tích', 
              Icons.analytics_rounded, 
              const Color(0xFFF5F3FF), 
              const Color(0xFF7C3AED),
              route: '/manager/analytics',
            ),
            _buildActionCard(
              context,
              'Quản lý Công nợ', 
              Icons.account_balance_wallet_rounded, 
              const Color(0xFFFEF2F2), 
              const Color(0xFFDC2626),
              route: '/manager/debt',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor, {String? route}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          if (route != null) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chức năng "$title" đang được phát triển!'),
                backgroundColor: const Color(0xFF334155),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              )
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCommandCenter(ManagerProvider provider, NumberFormat format, {bool isMobile = false}) {
    final pendingOnly = provider.pendingOrders
        .where((o) => o.orderStatus.toUpperCase() == 'PENDING')
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách đơn chờ duyệt',
                  style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => provider.loadDashboardData(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (isMobile)
            pendingOnly.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text('Không có đơn hàng nào cần duyệt.', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingOnly.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = pendingOnly[index];
                      return UnifiedOrderCard(
                        orderId: order.orderId,
                        orderCode: order.orderCode,
                        storeName: order.storeName,
                        orderStatus: order.orderStatus,
                        createdAt: order.createdAt,
                        totalAmount: order.totalAmount,
                        itemCount: 0,
                        onTap: () {
                          SharedOrderDetailsModal.show(
                            context,
                            orderId: order.orderId,
                            orderCode: order.orderCode,
                            orderStatus: order.orderStatus,
                            onRefresh: () => provider.loadDashboardData(),
                          );
                        },
                      );
                    },
                  )
          else
            Expanded(
              child: pendingOnly.isEmpty
                  ? const Center(
                      child: Text('Không có đơn hàng nào cần duyệt.', style: TextStyle(color: Color(0xFF94A3B8))),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: pendingOnly.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = pendingOnly[index];
                        return UnifiedOrderCard(
                          orderId: order.orderId,
                          orderCode: order.orderCode,
                          storeName: order.storeName,
                          orderStatus: order.orderStatus,
                          createdAt: order.createdAt,
                          totalAmount: order.totalAmount,
                          itemCount: 0,
                          onTap: () {
                            SharedOrderDetailsModal.show(
                              context,
                              orderId: order.orderId,
                              orderCode: order.orderCode,
                              orderStatus: order.orderStatus,
                              onRefresh: () => provider.loadDashboardData(),
                            );
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class _ManagerMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ManagerMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.error : AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
