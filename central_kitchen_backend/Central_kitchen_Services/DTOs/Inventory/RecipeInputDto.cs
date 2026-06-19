namespace Central_kitchen_Services.DTOs.Inventory;

public class RecipeInputDto
{
    public int InputIngredientId { get; set; }
    public string InputIngredientName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public bool IsRawMaterial { get; set; }
    public decimal QuantityRequired { get; set; }
}

