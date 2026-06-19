namespace Central_kitchen_Services.DTOs.Inventory;

public class ProductionPlanItemDto
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = null!;
    public string Sku { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public bool IsRawMaterial { get; set; }
    public decimal RequiredQuantity { get; set; }
    public decimal AvailableQuantity { get; set; }
    public decimal ShortageQuantity { get; set; }
}

