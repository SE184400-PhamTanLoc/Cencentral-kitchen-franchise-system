namespace Central_kitchen_Services.DTOs.Inventory;

public class BatchResponseDto
{
    public int BatchId { get; set; }
    public string BatchCode { get; set; } = null!;
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = null!;
    public decimal Quantity { get; set; }
    public decimal RemainingQuantity { get; set; }
    public DateOnly? ManufactureDate { get; set; }
    public DateOnly ExpiryDate { get; set; }
    public int KitchenId { get; set; }
    public string KitchenName { get; set; } = null!;
    public DateTime? CreatedAt { get; set; }
    public bool IsExpired { get; set; }
}

