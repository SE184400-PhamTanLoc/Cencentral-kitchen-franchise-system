using System.Security.Claims;
using System.Threading.Tasks;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

/// <summary>
/// Controller quản lý thông báo của người dùng:
///   GET  /api/notifications          — Lấy danh sách thông báo + số unread
///   PUT  /api/notifications/{id}/read — Đánh dấu một thông báo đã đọc
///   PUT  /api/notifications/read-all  — Đánh dấu tất cả đã đọc
/// </summary>
[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    // ============================================================
    // GET /api/notifications
    // Lấy danh sách thông báo của user hiện tại (tối đa 50 bản ghi, mới nhất trước)
    // ============================================================
    [HttpGet]
    public async Task<IActionResult> GetMyNotifications()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        var result = await _notificationService.GetNotificationsAsync(userId.Value);
        return Ok(new
        {
            success = true,
            unreadCount = result.UnreadCount,
            totalCount = result.Items.Count,
            data = result.Items
        });
    }

    // ============================================================
    // PUT /api/notifications/{id}/read
    // Đánh dấu một notification cụ thể là đã đọc
    // ============================================================
    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        var success = await _notificationService.MarkAsReadAsync(id, userId.Value);
        if (!success)
            return NotFound(new { success = false, message = $"Không tìm thấy thông báo ID={id} hoặc không có quyền truy cập." });

        return Ok(new { success = true, message = "Đã đánh dấu thông báo là đã đọc." });
    }

    // ============================================================
    // PUT /api/notifications/read-all
    // Đánh dấu TẤT CẢ thông báo của user là đã đọc
    // ============================================================
    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        await _notificationService.MarkAllAsReadAsync(userId.Value);
        return Ok(new { success = true, message = "Đã đánh dấu tất cả thông báo là đã đọc." });
    }

    // ─── Helper ─────────────────────────────────────────────────
    private int? GetCurrentUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
        return int.TryParse(claim, out var id) ? id : null;
    }
}
