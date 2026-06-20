using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Order;

/// <summary>
/// DTO để cập nhật tồn kho cửa hàng franchise sau khi nhận hàng thành công.
/// Dùng cho PUT /api/franchise/orders/{orderId}/receive
/// </summary>
public class ReceiveOrderDto
{
    /// <summary>
    /// Danh sách từng nguyên liệu thực nhận (có thể khác với số lượng đặt).
    /// Nếu bỏ trống, hệ thống dùng QuantityOrdered từ đơn hàng.
    /// </summary>
    public List<ReceivedItemDto>? ReceivedItems { get; set; }

    /// <summary>Ghi chú khi nhận hàng (tùy chọn).</summary>
    public string? Notes { get; set; }
}

/// <summary>Số lượng thực nhận của từng nguyên liệu trong đơn hàng.</summary>
public class ReceivedItemDto
{
    [Required]
    public int IngredientId { get; set; }

    [Required]
    [Range(0, double.MaxValue, ErrorMessage = "Số lượng nhận không được âm.")]
    public decimal QuantityDelivered { get; set; }
}

/// <summary>
/// Response sau khi nhận hàng — trả về snapshot tồn kho cập nhật.
/// </summary>
public class ReceiveOrderResponseDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public string NewStatus { get; set; } = string.Empty;
    public List<InventoryUpdateResultDto> InventoryUpdates { get; set; } = new();
}

/// <summary>Kết quả cập nhật tồn kho từng nguyên liệu.</summary>
public class InventoryUpdateResultDto
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal QuantityAdded { get; set; }
    public decimal NewStockQuantity { get; set; }
    public DateTime LastUpdated { get; set; }
}
