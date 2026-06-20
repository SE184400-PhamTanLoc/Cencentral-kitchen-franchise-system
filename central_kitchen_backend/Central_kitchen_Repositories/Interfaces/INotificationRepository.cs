using System.Collections.Generic;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

/// <summary>
/// Repository xử lý CRUD cho bảng Notifications.
/// </summary>
public interface INotificationRepository
{
    /// <summary>Tạo một notification mới cho người dùng cụ thể.</summary>
    Task<Notification> CreateAsync(Notification notification);

    /// <summary>Gửi cùng một thông báo tới nhiều người dùng (batch insert).</summary>
    Task CreateBatchAsync(IEnumerable<Notification> notifications);

    /// <summary>Lấy danh sách thông báo của một user, mới nhất trước. Giới hạn 50 bản ghi.</summary>
    Task<List<Notification>> GetByUserIdAsync(int userId, int limit = 50);

    /// <summary>Đánh dấu một thông báo cụ thể là đã đọc.</summary>
    Task<bool> MarkAsReadAsync(int notificationId, int userId);

    /// <summary>Đánh dấu TẤT CẢ thông báo của một user là đã đọc.</summary>
    Task MarkAllAsReadAsync(int userId);

    /// <summary>Đếm số thông báo chưa đọc của một user.</summary>
    Task<int> CountUnreadAsync(int userId);
}
