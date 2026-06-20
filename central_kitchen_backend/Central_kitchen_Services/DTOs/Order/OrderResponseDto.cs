using System;
using System.Collections.Generic;

namespace Central_kitchen_Services.DTOs.Order;

/// <summary>
/// Response trả về thông tin tóm tắt đơn hàng (dùng trong danh sách).
/// </summary>
public class OrderSummaryDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public int StoreId { get; set; }
    public string StoreName { get; set; } = string.Empty;
    public int KitchenId { get; set; }
    public string KitchenName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string OrderStatus { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public int ItemCount { get; set; }
    public string CreatedByName { get; set; } = string.Empty;
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

/// <summary>
/// Response trả về thông tin chi tiết đơn hàng (bao gồm từng dòng nguyên liệu).
/// </summary>
public class OrderDetailDto : OrderSummaryDto
{
    public List<OrderDetailItemDto> Items { get; set; } = new();
}

/// <summary>Một dòng chi tiết nguyên liệu trong đơn hàng.</summary>
public class OrderDetailItemDto
{
    public int OrderDetailId { get; set; }
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal QuantityOrdered { get; set; }
    public decimal? QuantityDelivered { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Subtotal => QuantityOrdered * UnitPrice;
}

/// <summary>
/// Response ngắn gọn trả về sau khi đặt hàng thành công.
/// </summary>
public class PlaceOrderResponseDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public string OrderStatus { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime? CreatedAt { get; set; }
    public string Message { get; set; } = string.Empty;
}
