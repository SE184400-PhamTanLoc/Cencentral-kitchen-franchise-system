namespace Central_kitchen_Services.DTOs.Manager;

public class ChainInventoryDto
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public decimal KitchenStock { get; set; }
    public decimal StoreStock { get; set; }
    public decimal TotalStock => KitchenStock + StoreStock;
}
