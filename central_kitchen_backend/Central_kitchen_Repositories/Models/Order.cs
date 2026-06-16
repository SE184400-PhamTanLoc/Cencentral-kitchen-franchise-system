using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class Order
{
    public int OrderId { get; set; }

    public string OrderCode { get; set; } = null!;

    public int StoreId { get; set; }

    public int KitchenId { get; set; }

    public decimal TotalAmount { get; set; }

    public string OrderStatus { get; set; } = null!;

    public string? Notes { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual ICollection<DeliveryLog> DeliveryLogs { get; set; } = new List<DeliveryLog>();

    public virtual CentralKitchen Kitchen { get; set; } = null!;

    public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

    public virtual Store Store { get; set; } = null!;
}
