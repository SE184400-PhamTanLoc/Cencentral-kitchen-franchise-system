using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Inventory;

public class ExecuteProductionDto
{
    [Required]
    public int OutputIngredientId { get; set; }

    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
    public decimal RequestedQuantity { get; set; }

    [Required]
    public string BatchCode { get; set; } = null!;

    [Required]
    public DateOnly ExpiryDate { get; set; }

    [Required]
    public int KitchenId { get; set; }
}
