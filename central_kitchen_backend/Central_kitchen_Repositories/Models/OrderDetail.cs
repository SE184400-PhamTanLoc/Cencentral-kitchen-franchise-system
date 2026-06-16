using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class OrderDetail
{
    public int OrderDetailId { get; set; }

    public int OrderId { get; set; }

    public int IngredientId { get; set; }

    public decimal QuantityOrdered { get; set; }

    public decimal? QuantityDelivered { get; set; }

    public decimal UnitPrice { get; set; }

    public virtual Ingredient Ingredient { get; set; } = null!;

    public virtual Order Order { get; set; } = null!;
}
