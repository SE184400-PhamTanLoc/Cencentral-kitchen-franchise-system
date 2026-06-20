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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (notifProvider.hasUnread)
            TextButton(
              onPressed: () {
                notifProvider.markAllAsReadAsync();
              },
              child: const Text('Đánh dấu tất cả đã đọc', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : notifProvider.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppTheme.outline),
                      SizedBox(height: 16),
                      Text('Không có thông báo nào', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => notifProvider.loadNotificationsAsync(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifProvider.notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = notifProvider.notifications[index];
                      return ListTile(
                        tileColor: n.isRead ? AppTheme.surfaceContainerLowest : AppTheme.primary.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.outlineVariant),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Icon(
                            n.title.contains('❌') ? Icons.cancel_outlined :
                            n.title.contains('✅') ? Icons.check_circle_outline :
                            Icons.notifications_active_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(n.message, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(n.timeAgo, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                        onTap: () {
                          if (!n.isRead) {
                            notifProvider.markAsReadAsync(n.notificationId);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
