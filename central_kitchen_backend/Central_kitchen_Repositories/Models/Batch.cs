using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class Batch
{
    public int BatchId { get; set; }

    public string BatchCode { get; set; } = null!;

    public int IngredientId { get; set; }

    public decimal Quantity { get; set; }

    public decimal RemainingQuantity { get; set; }

    public DateOnly? ManufactureDate { get; set; }

    public DateOnly ExpiryDate { get; set; }

    public int KitchenId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Ingredient Ingredient { get; set; } = null!;

    public virtual CentralKitchen Kitchen { get; set; } = null!;
}
