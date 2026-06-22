using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Inventory;

public class CreateRecipeDto
{
    [Required]
    public int OutputIngredientId { get; set; }

    [MaxLength(500)]
    public string? Description { get; set; }

    [Required]
    [MinLength(1, ErrorMessage = "Phải có ít nhất 1 nguyên liệu đầu vào.")]
    public List<CreateRecipeDetailDto> Details { get; set; } = new();
}

public class CreateRecipeDetailDto
{
    [Required]
    public int InputIngredientId { get; set; }

    [Range(0.001, double.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0.")]
    public decimal QuantityRequired { get; set; }
}
