using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class StoreInventory
{
    public int StoreInventoryId { get; set; }

    public int StoreId { get; set; }

    public int IngredientId { get; set; }

    public decimal? StockQuantity { get; set; }

    public DateTime? LastUpdated { get; set; }

    public virtual Ingredient Ingredient { get; set; } = null!;

    public virtual Store Store { get; set; } = null!;
}
