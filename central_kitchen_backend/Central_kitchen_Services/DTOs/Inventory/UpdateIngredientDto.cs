using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Inventory;

public class UpdateIngredientDto
{
    [MaxLength(100)]
    public string? Name { get; set; }

    [MaxLength(50)]
    public string? Sku { get; set; }

    [MaxLength(20)]
    public string? Unit { get; set; }

    [Range(0, double.MaxValue)]
    public decimal? UnitPrice { get; set; }

    public bool? IsRawMaterial { get; set; }

    [Range(0, double.MaxValue)]
    public decimal? MinStockLevel { get; set; }
}
