using System.Threading.Tasks;
using Central_kitchen_Services.DTOs.Notification;

namespace Central_kitchen_Services.Interfaces;

/// <summary>
/// Service quản lý thông báo trong hệ thống.
/// Được inject vào OrderService để gửi notification khi có sự kiện đơn hàng.
/// </summary>
public interface INotificationService
{
    /// <summary>Lấy danh sách thông báo kèm số unread của một user.</summary>
    Task<NotificationListDto> GetNotificationsAsync(int userId);

    /// <summary>Đánh dấu một notification cụ thể là đã đọc.</summary>
    Task<bool> MarkAsReadAsync(int notificationId, int userId);

    /// <summary>Đánh dấu TẤT CẢ thông báo của user là đã đọc.</summary>
    Task MarkAllAsReadAsync(int userId);

    /// <summary>
    /// Gửi notification cho một danh sách users (batch).
    /// Được gọi nội bộ từ OrderService sau các sự kiện như PlaceOrder, Approve, Reject.
    /// </summary>
    Task PushToUsersAsync(IEnumerable<int> userIds, string title, string message);
}
