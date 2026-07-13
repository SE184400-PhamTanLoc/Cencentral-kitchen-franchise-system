using System;

namespace Central_kitchen_Services.DTOs.Manager;

public class ManagerDashboardStatsDto
{
    public int TotalStores { get; set; }
    public int TotalPendingOrders { get; set; }
    public decimal TotalDebt { get; set; }
    public decimal TodayRevenue { get; set; }
    public int DispatchedOrders { get; set; }
    public int ApprovedOrders { get; set; }
}

public class ManagerPendingOrderDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public string StoreName { get; set; } = string.Empty;
    public int StoreId { get; set; }
    public int ItemCount { get; set; }
    public string OrderStatus { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime OrderDate { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public string Notes { get; set; } = string.Empty;
}
