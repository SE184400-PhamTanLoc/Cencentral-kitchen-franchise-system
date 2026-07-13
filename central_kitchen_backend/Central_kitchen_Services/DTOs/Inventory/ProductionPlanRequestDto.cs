using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Inventory;

public class ProductionPlanRequestDto
{
    [Required(ErrorMessage = "Nguyên liệu đầu ra không được để trống")]
    public int OutputIngredientId { get; set; }

    [Range(0.01, double.MaxValue, ErrorMessage = "Số lượng yêu cầu phải lớn hơn 0")]
    public decimal RequestedQuantity { get; set; }

    public int? KitchenId { get; set; }
}
