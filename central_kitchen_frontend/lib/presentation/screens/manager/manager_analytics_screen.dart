import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../../../business/providers/manager_provider.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ManagerProvider>().loadAnalytics(days: _selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Báo cáo & Phân tích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDays,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 22),
                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 ngày qua')),
                  DropdownMenuItem(value: 30, child: Text('30 ngày qua')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDays = val);
                    _loadData();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAnalytics) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }
          if (provider.analytics == null) {
            return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Color(0xFF94A3B8))));
          }

          final analytics = provider.analytics!;

          double maxRevenue = 0;
          for (var day in analytics.dailyRevenues) {
            if (day.revenue > maxRevenue) maxRevenue = day.revenue;
          }
          if (maxRevenue == 0) maxRevenue = 1;

          return Stack(
            children: [
              // 1. Background Glowing Blobs
              Container(color: const Color(0xFFF8FAFC)), // Base light color
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Color(0x6634D399), // Soft Green
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 200,
                left: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: const BoxDecoration(
                    color: Color(0x443B82F6), // Soft Blue
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Blur Layer over blobs
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // 2. Foreground Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề tổng quan
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tổng quan kinh doanh', 
                            style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Premium Glassmorphism Revenue Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFA7F3D0)),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.trending_up_rounded, color: Color(0xFF059669), size: 16),
                                          SizedBox(width: 4),
                                          Text('Tổng doanh thu', style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)]),
                                        boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                                        shape: BoxShape.circle
                                      ),
                                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  formatCurrency.format(analytics.totalRevenue),
                                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Stats Grid (Glassmorphism)
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassStatCard(
                              'Đơn thành công', 
                              analytics.totalOrders.toString(), 
                              Icons.check_circle_rounded, 
                              const Color(0xFFEFF6FF), 
                              const Color(0xFF3B82F6),
                              const Color(0xFFDBEAFE)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGlassStatCard(
                              'Đơn hủy/Từ chối', 
                              analytics.cancelledOrders.toString(), 
                              Icons.cancel_rounded, 
                              const Color(0xFFFEF2F2), 
                              const Color(0xFFEF4444),
                              const Color(0xFFFEE2E2)
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Biến động doanh thu', 
                            style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Custom Glassmorphic Bar Chart
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                            ),
                            child: Column(
                              children: analytics.dailyRevenues.map((day) {
                                final percentage = day.revenue / maxRevenue;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          day.date.substring(5), // Chỉ lấy MM-DD
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatCurrency.format(day.revenue),
                                              style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 8),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 10,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(5)),
                                                ),
                                                FractionallySizedBox(
                                                  widthFactor: percentage,
                                                  child: Container(
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)]),
                                                      borderRadius: BorderRadius.circular(5),
                                                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 2))]
                                                    ),
                                                  ),
                                                ),
                                                // Thêm đốm sáng ở cuối thanh
                                                if (percentage > 0.05)
                                                  Positioned(
                                                    right: (1 - percentage) * MediaQuery.of(context).size.width, // Không thể align chính xác tuyệt đối không có LayoutBuilder, thay bằng chấm cố định bên phải FractionallySizedBox
                                                    left: 0,
                                                    child: FractionallySizedBox(
                                                      widthFactor: percentage,
                                                      alignment: Alignment.centerLeft,
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Container(
                                                          width: 6, height: 6,
                                                          margin: const EdgeInsets.only(top: 2, right: 2),
                                                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor, Color borderColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
            boxShadow: [BoxShadow(color: iconColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor, 
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
