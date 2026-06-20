using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Order;

/// <summary>
/// DTO để tạo đơn hàng mới từ cửa hàng franchise.
/// Dùng cho POST /api/franchise/orders
/// </summary>
public class CreateOrderDto
{
    /// <summary>ID cửa hàng franchise đang đặt hàng.</summary>
    [Required]
    public int StoreId { get; set; }

    /// <summary>ID bếp trung tâm nhận đơn.</summary>
    [Required]
    public int KitchenId { get; set; }

    /// <summary>Ghi chú thêm cho đơn hàng (tùy chọn).</summary>
    public string? Notes { get; set; }

    /// <summary>Danh sách các nguyên liệu cần đặt.</summary>
    [Required]
    [MinLength(1, ErrorMessage = "Đơn hàng phải có ít nhất 1 nguyên liệu.")]
    public List<CreateOrderItemDto> Items { get; set; } = new();
}

/// <summary>Một dòng trong đơn hàng.</summary>
public class CreateOrderItemDto
{
    /// <summary>ID nguyên liệu cần đặt.</summary>
    [Required]
    public int IngredientId { get; set; }

    /// <summary>Số lượng đặt hàng.</summary>
    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0.")]
    public decimal QuantityOrdered { get; set; }

    /// <summary>Đơn giá tại thời điểm đặt (lấy từ Ingredient.UnitPrice).</summary>
    [Required]
    [Range(0, double.MaxValue)]
    public decimal UnitPrice { get; set; }
}
