namespace Central_kitchen_Services.DTOs.Inventory;

public class ProductionPlanResponseDto
{
    public int OutputIngredientId { get; set; }
    public string OutputIngredientName { get; set; } = null!;
    public string? OutputSku { get; set; }
    public string? RecipeDescription { get; set; }
    public decimal RequestedQuantity { get; set; }
    public List<ProductionPlanItemDto> Materials { get; set; } = new();
}

