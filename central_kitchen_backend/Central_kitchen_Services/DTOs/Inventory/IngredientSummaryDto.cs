namespace Central_kitchen_Services.DTOs.Inventory;

public class IngredientSummaryDto
{
    public int IngredientId { get; set; }
    public string Name { get; set; } = null!;
    public string Sku { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public decimal UnitPrice { get; set; }
    public bool IsRawMaterial { get; set; }
    public decimal MinStockLevel { get; set; }
    public DateTime? CreatedAt { get; set; }
    public decimal AvailableQuantity { get; set; }
    public int BatchCount { get; set; }
    public DateOnly? LatestExpiryDate { get; set; }
    public string? LatestBatchCode { get; set; }
    public bool HasRecipe { get; set; }
}

