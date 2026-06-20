using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly ApplicationDbContext _context;

    public NotificationRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Notification> CreateAsync(Notification notification)
    {
        notification.CreatedAt = DateTime.UtcNow;
        notification.IsRead = false;
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();
        return notification;
    }

    public async Task CreateBatchAsync(IEnumerable<Notification> notifications)
    {
        var list = notifications.ToList();
        var now = DateTime.UtcNow;
        foreach (var n in list)
        {
            n.CreatedAt = now;
            n.IsRead = false;
        }
        _context.Notifications.AddRange(list);
        await _context.SaveChangesAsync();
    }

    public async Task<List<Notification>> GetByUserIdAsync(int userId, int limit = 50)
    {
        return await _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<bool> MarkAsReadAsync(int notificationId, int userId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.NotificationId == notificationId && n.UserId == userId);

        if (notification == null) return false;

        notification.IsRead = true;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task MarkAllAsReadAsync(int userId)
    {
        await _context.Notifications
            .Where(n => n.UserId == userId && n.IsRead == false)
            .ExecuteUpdateAsync(s => s.SetProperty(n => n.IsRead, true));
    }

    public async Task<int> CountUnreadAsync(int userId)
    {
        return await _context.Notifications
            .CountAsync(n => n.UserId == userId && n.IsRead == false);
    }
}
