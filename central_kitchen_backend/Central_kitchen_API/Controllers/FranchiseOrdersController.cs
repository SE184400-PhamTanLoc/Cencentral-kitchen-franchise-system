using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Central_kitchen_Services.DTOs.Order;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

/// <summary>
/// Controller xử lý các API cho Cửa Hàng Nhượng Quyền (Franchise):
///   - THAI_API_01: POST   /api/franchise/orders              — Đặt hàng nguyên liệu
///   - THAI_API_02: GET    /api/franchise/orders/{storeId}    — Danh sách đơn theo cửa hàng
///   - THAI_API_02: GET    /api/franchise/orders/detail/{orderId} — Chi tiết đơn hàng
///   - THAI_API_03: PUT    /api/franchise/orders/{orderId}/receive — Xác nhận nhận hàng + cập nhật kho
///   - THAI_API_04: POST   /api/franchise/inventory/consume   — Ghi nhận tiêu thụ/hao hụt
///   - EXTRA:       GET    /api/franchise/inventory/{storeId} — Xem tồn kho cửa hàng
/// </summary>
[ApiController]
[Route("api/franchise")]
[Authorize]
public class FranchiseOrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public FranchiseOrdersController(IOrderService orderService)
    {
        _orderService = orderService;
    }

    // ============================================================
    // TASK THAI_API_01
    // POST /api/franchise/orders
    // Tiếp nhận đơn đặt hàng nguyên liệu từ cửa hàng franchise.
    // Kiểm tra hạn mức công nợ trước khi lưu đơn với status "Pending".
    // ============================================================
    [HttpPost("orders")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> PlaceOrder([FromBody] CreateOrderDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Dữ liệu không hợp lệ.", errors = ModelState });

        // Lấy UserId từ JWT claim
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? User.FindFirst("sub")?.Value;

        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { success = false, message = "Không xác định được người dùng từ token." });

        try
        {
            var result = await _orderService.PlaceOrderAsync(dto, userId);
            return CreatedAtAction(
                nameof(GetOrderDetail),
                new { orderId = result.OrderId },
                new
                {
                    success = true,
                    message = result.Message,
                    data = result
                });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // TASK THAI_API_02 — Danh sách đơn hàng theo cửa hàng
    // GET /api/franchise/orders/{storeId}
    // ============================================================
    [HttpGet("orders/{storeId:int}")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> GetOrdersByStore(int storeId)
    {
        var orders = await _orderService.GetOrdersByStoreAsync(storeId);
        return Ok(new
        {
            success = true,
            message = $"Lấy danh sách đơn hàng của cửa hàng ID={storeId} thành công.",
            totalCount = orders.Count,
            data = orders
        });
    }

    // ============================================================
    // TASK THAI_API_02 — Chi tiết đơn hàng
    // GET /api/franchise/orders/detail/{orderId}
    // ============================================================
    [HttpGet("orders/detail/{orderId:int}")]
    [Authorize(Roles = "FRANCHISE_STAFF,KITCHEN_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> GetOrderDetail(int orderId)
    {
        var order = await _orderService.GetOrderDetailAsync(orderId);
        if (order == null)
            return NotFound(new { success = false, message = $"Không tìm thấy đơn hàng ID={orderId}." });

        return Ok(new
        {
            success = true,
            message = "Lấy chi tiết đơn hàng thành công.",
            data = order
        });
    }

    // ============================================================
    // TASK THAI_API_03
    // PUT /api/franchise/orders/{orderId}/receive
    // Xác nhận nhận hàng + cập nhật tồn kho StoreInventory.
    // ============================================================
    [HttpPut("orders/{orderId:int}/receive")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> ReceiveOrder(int orderId, [FromBody] ReceiveOrderDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Dữ liệu không hợp lệ.", errors = ModelState });

        try
        {
            var result = await _orderService.ReceiveOrderAsync(orderId, dto);
            return Ok(new
            {
                success = true,
                message = $"Đơn hàng {result.OrderCode} đã được xác nhận nhận hàng. Tồn kho đã được cập nhật.",
                data = result
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // TASK THAI_API_04
    // POST /api/franchise/inventory/consume
    // Ghi nhận tiêu thụ hoặc hao hụt/hủy nguyên liệu cuối ngày.
    // Tự động trừ kho StoreInventory tương ứng.
    // ============================================================
    [HttpPost("inventory/consume")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> ConsumeInventory([FromBody] ConsumeInventoryDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Dữ liệu không hợp lệ.", errors = ModelState });

        try
        {
            var result = await _orderService.ConsumeInventoryAsync(dto);
            return Ok(new
            {
                success = true,
                message = $"Ghi nhận tiêu thụ [{dto.ConsumeType}] thành công. " +
                          $"Đã xử lý {result.TotalItemsProcessed} nguyên liệu.",
                data = result
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // EXTRA — Xem tồn kho hiện tại của cửa hàng franchise
    // GET /api/franchise/inventory/{storeId}
    // ============================================================
    [HttpGet("inventory/{storeId:int}")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> GetStoreInventory(int storeId)
    {
        var inventory = await _orderService.GetStoreInventoryAsync(storeId);
        return Ok(new
        {
            success = true,
            message = $"Lấy tồn kho cửa hàng ID={storeId} thành công.",
            totalItems = inventory.Count,
            data = inventory
        });
    }

    // ============================================================
    // BỔ SUNG — Hủy đơn hàng (chỉ khi Pending)
    // PUT /api/franchise/orders/{orderId}/cancel
    // Role: FRANCHISE_STAFF (chỉ cửa hàng của mình)
    // ============================================================
    [HttpPut("orders/{orderId:int}/cancel")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> CancelOrder(int orderId, [FromBody] CancelOrderDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { success = false, message = "Dữ liệu không hợp lệ.", errors = ModelState });

        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? User.FindFirst("sub")?.Value;
        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        try
        {
            var result = await _orderService.CancelOrderAsync(orderId, userId, dto);
            return Ok(new { success = true, message = result.Message, data = result });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // BỔ SUNG — Manager/Admin duyệt đơn hàng
    // PUT /api/franchise/orders/{orderId}/approve
    // Role: MANAGER, ADMIN
    // ============================================================
    [HttpPut("orders/{orderId:int}/approve")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> ApproveOrder(int orderId, [FromBody] OrderStatusActionDto dto)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? User.FindFirst("sub")?.Value;
        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        try
        {
            var result = await _orderService.ApproveOrderAsync(orderId, userId, dto);
            return Ok(new { success = true, message = result.Message, data = result });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // BỔ SUNG — Manager/Admin từ chối đơn hàng
    // PUT /api/franchise/orders/{orderId}/reject
    // Role: MANAGER, ADMIN
    // ============================================================
    [HttpPut("orders/{orderId:int}/reject")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> RejectOrder(int orderId, [FromBody] OrderStatusActionDto dto)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? User.FindFirst("sub")?.Value;
        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        try
        {
            var result = await _orderService.RejectOrderAsync(orderId, userId, dto);
            return Ok(new { success = true, message = result.Message, data = result });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // BỔ SUNG — Bếp trung tâm xuất kho giao hàng
    // PUT /api/franchise/orders/{orderId}/dispatch
    // Role: KITCHEN_STAFF, MANAGER, ADMIN
    // ============================================================
    [HttpPut("orders/{orderId:int}/dispatch")]
    [Authorize(Roles = "KITCHEN_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> DispatchOrder(int orderId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? User.FindFirst("sub")?.Value;
        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { success = false, message = "Không xác định được người dùng." });

        try
        {
            var result = await _orderService.DispatchOrderAsync(orderId, userId);
            return Ok(new { success = true, message = result.Message, data = result });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    // ============================================================
    // BỔ SUNG — Lấy danh sách đơn hàng theo bếp trung tâm
    // GET /api/franchise/orders/kitchen/{kitchenId}?status=Pending
    // Role: MANAGER, KITCHEN_STAFF, ADMIN
    // ============================================================
    [HttpGet("orders/kitchen/{kitchenId:int}")]
    [Authorize(Roles = "MANAGER,KITCHEN_STAFF,ADMIN")]
    public async Task<IActionResult> GetOrdersByKitchen(
        int kitchenId,
        [FromQuery] string? status = null)
    {
        var orders = await _orderService.GetOrdersByKitchenAsync(kitchenId, status);
        return Ok(new
        {
            success = true,
            message = $"Lấy danh sách đơn hàng của bếp ID={kitchenId}" +
                      (status != null ? $" (lọc: {status})" : "") + " thành công.",
            totalCount = orders.Count,
            data = orders
        });
    }

    // ============================================================
    // BỔ SUNG — Xem thông tin công nợ & hạn mức tín dụng cửa hàng
    // GET /api/franchise/store/{storeId}/credit-info
    // Role: FRANCHISE_STAFF, MANAGER, ADMIN
    // ============================================================
    [HttpGet("store/{storeId:int}/credit-info")]
    [Authorize(Roles = "FRANCHISE_STAFF,MANAGER,ADMIN")]
    public async Task<IActionResult> GetStoreCreditInfo(int storeId)
    {
        try
        {
            var creditInfo = await _orderService.GetStoreCreditInfoAsync(storeId);
            return Ok(new
            {
                success = true,
                message = $"Lấy thông tin công nợ cửa hàng ID={storeId} thành công.",
                data = creditInfo
            });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { success = false, message = ex.Message });
        }
    }
}
