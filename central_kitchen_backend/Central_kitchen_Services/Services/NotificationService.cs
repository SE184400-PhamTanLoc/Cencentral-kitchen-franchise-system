using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Notification;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _notificationRepository;

    public NotificationService(INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }

    public async Task<NotificationListDto> GetNotificationsAsync(int userId)
    {
        var notifications = await _notificationRepository.GetByUserIdAsync(userId);
        var unreadCount = await _notificationRepository.CountUnreadAsync(userId);

        return new NotificationListDto
        {
            UnreadCount = unreadCount,
            Items = notifications.Select(n => new NotificationDto
            {
                NotificationId = n.NotificationId,
                UserId = n.UserId,
                Title = n.Title,
                Message = n.Message,
                IsRead = n.IsRead ?? false,
                CreatedAt = n.CreatedAt
            }).ToList()
        };
    }

    public async Task<bool> MarkAsReadAsync(int notificationId, int userId)
    {
        return await _notificationRepository.MarkAsReadAsync(notificationId, userId);
    }

    public async Task MarkAllAsReadAsync(int userId)
    {
        await _notificationRepository.MarkAllAsReadAsync(userId);
    }

    public async Task PushToUsersAsync(IEnumerable<int> userIds, string title, string message)
    {
        var notifications = userIds
            .Distinct()
            .Select(uid => new Notification
            {
                UserId = uid,
                Title = title,
                Message = message
            });

        await _notificationRepository.CreateBatchAsync(notifications);
    }
}
