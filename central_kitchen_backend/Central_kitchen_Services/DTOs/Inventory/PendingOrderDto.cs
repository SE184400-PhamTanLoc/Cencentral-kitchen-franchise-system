using System;
using System.Collections.Generic;

namespace Central_kitchen_Services.DTOs.Inventory;

public class PendingOrderDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = null!;
    public int StoreId { get; set; }
    public string StoreName { get; set; } = null!;
    public decimal TotalAmount { get; set; }
    public string OrderStatus { get; set; } = null!;
    public DateTime? CreatedAt { get; set; }
    public List<PendingOrderDetailDto> OrderDetails { get; set; } = new();
}

public class PendingOrderDetailDto
{
    public int IngredientId { get; set; }
    public string IngredientName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public decimal QuantityOrdered { get; set; }
}
