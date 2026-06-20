using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Order;

/// <summary>
/// DTO để ghi nhận tiêu thụ hoặc hao hụt/hủy nguyên liệu cuối ngày tại cửa hàng.
/// Dùng cho POST /api/franchise/inventory/consume
/// </summary>
public class ConsumeInventoryDto
{
    /// <summary>ID cửa hàng franchise đang báo cáo tiêu thụ.</summary>
    [Required]
    public int StoreId { get; set; }

    /// <summary>
    /// Loại tiêu thụ: "SOLD" (đã bán), "WASTE" (hao hụt/hỏng), "DISCARD" (hủy).
    /// </summary>
    [Required]
    [RegularExpression("^(SOLD|WASTE|DISCARD)$",
        ErrorMessage = "ConsumeType phải là 'SOLD', 'WASTE' hoặc 'DISCARD'.")]
    public string ConsumeType { get; set; } = "SOLD";

    /// <summary>Ghi chú lý do hao hụt/hủy (bắt buộc nếu ConsumeType là WASTE hoặc DISCARD).</summary>
    public string? Reason { get; set; }

    /// <summary>Ngày ghi nhận tiêu thụ (mặc định là ngày hiện tại nếu không truyền).</summary>
    public DateTime? ConsumeDate { get; set; }

    /// <summary>Danh sách nguyên liệu cần trừ kho.</summary>
    [Required]
    [MinLength(1, ErrorMessage = "Phải có ít nhất 1 nguyên liệu cần trừ kho.")]
    public List<ConsumeItemDto> Items { get; set; } = new();
}

/// <summary>Một dòng nguyên liệu cần trừ kho.</summary>
public class ConsumeItemDto
{
    [Required]
    public int IngredientId { get; set; }

    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Số lượng tiêu thụ phải lớn hơn 0.")]
    public decimal Quantity { get; set; }
}

/// <summary>Response sau khi ghi nhận tiêu thụ thành công.</summary>
public class ConsumeInventoryResponseDto
{
    public int StoreId { get; set; }
    public string ConsumeType { get; set; } = string.Empty;
    public DateTime ConsumedAt { get; set; }
    public int TotalItemsProcessed { get; set; }
    public List<ConsumeResultItemDto> Results { get; set; } = new();
}

/// <summary>Kết quả trừ kho cho từng nguyên liệu.</summary>
public class ConsumeResultItemDto
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal QuantityConsumed { get; set; }
    public decimal RemainingStock { get; set; }
}

/// <summary>
/// DTO trả về danh sách tồn kho hiện tại của một cửa hàng franchise.
/// Dùng cho GET /api/franchise/inventory/{storeId}
/// </summary>
public class StoreInventoryDto
{
    public int StoreInventoryId { get; set; }
    public int StoreId { get; set; }
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal StockQuantity { get; set; }
    public DateTime? LastUpdated { get; set; }
}
