import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/providers/notification_provider.dart';
import '../../../core/constants/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotificationsAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: AppTheme.background.withOpacity(0.7),
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.primary),
              title: const Text('Thông báo', style: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                if (notifProvider.hasUnread)
                  TextButton.icon(
                    onPressed: () {
                      notifProvider.markAllAsReadAsync();
                    },
                    icon: const Icon(Icons.done_all_rounded, color: AppTheme.primary, size: 18),
                    label: const Text('Đọc tất cả', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background bubbles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.15), AppTheme.secondary.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.secondary.withOpacity(0.12), AppTheme.primary.withOpacity(0.05)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
            ),
          ),
          // Blur layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: AppTheme.background.withOpacity(0.7),
              ),
            ),
          ),
          // Main Body
          SafeArea(
            child: notifProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : notifProvider.notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.outline),
                            SizedBox(height: 16),
                            Text('Không có thông báo nào', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: () => notifProvider.loadNotificationsAsync(),
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: notifProvider.notifications.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final n = notifProvider.notifications[index];
                            final isError = n.title.contains('❌') || n.title.contains('Hủy') || n.title.contains('vượt');
                            final isSuccess = n.title.contains('✅') || n.title.contains('duyệt') || n.title.contains('nhận');

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: InkWell(
                                  onTap: () {
                                    if (!n.isRead) {
                                      notifProvider.markAsReadAsync(n.notificationId);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: n.isRead ? Colors.white.withOpacity(0.4) : AppTheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: n.isRead ? Colors.white.withOpacity(0.6) : AppTheme.primary.withOpacity(0.3),
                                        width: n.isRead ? 1.2 : 1.8,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: (isError
                                                ? AppTheme.error
                                                : isSuccess
                                                    ? const Color(0xFF16A34A)
                                                    : AppTheme.primary)
                                                .withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isError
                                                ? Icons.cancel_outlined
                                                : isSuccess
                                                    ? Icons.check_circle_outline_rounded
                                                    : Icons.notifications_active_outlined,
                                            color: isError
                                                ? AppTheme.error
                                                : isSuccess
                                                    ? const Color(0xFF16A34A)
                                                    : AppTheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppTheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n.message,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                                                  height: 1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                n.timeAgo,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
