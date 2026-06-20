using System;

namespace Central_kitchen_Services.DTOs.Notification;

/// <summary>
/// DTO để trả về thông báo cho người dùng.
/// Dùng cho GET /api/notifications
/// </summary>
public class NotificationDto
{
    public int NotificationId { get; set; }
    public int UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime? CreatedAt { get; set; }
    /// <summary>Thời gian tương đối, ví dụ "5 phút trước".</summary>
    public string TimeAgo => CreatedAt.HasValue ? FormatTimeAgo(CreatedAt.Value) : string.Empty;

    private static string FormatTimeAgo(DateTime dt)
    {
        var diff = DateTime.UtcNow - dt;
        if (diff.TotalMinutes < 1) return "Vừa xong";
        if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes} phút trước";
        if (diff.TotalHours < 24) return $"{(int)diff.TotalHours} giờ trước";
        if (diff.TotalDays < 7) return $"{(int)diff.TotalDays} ngày trước";
        return dt.ToString("dd/MM/yyyy");
    }
}

/// <summary>
/// Response wrapper cho danh sách thông báo, kèm số unread.
/// </summary>
public class NotificationListDto
{
    public int UnreadCount { get; set; }
    public System.Collections.Generic.List<NotificationDto> Items { get; set; } = new();
}
