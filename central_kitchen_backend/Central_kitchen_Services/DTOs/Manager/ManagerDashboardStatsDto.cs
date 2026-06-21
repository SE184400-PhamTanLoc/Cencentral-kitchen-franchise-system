using System;

namespace Central_kitchen_Services.DTOs.Manager;

public class ManagerDashboardStatsDto
{
    public int TotalStores { get; set; }
    public int TotalPendingOrders { get; set; }
    public decimal TotalDebt { get; set; }
    public decimal TodayRevenue { get; set; }
}

public class ManagerPendingOrderDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public string StoreName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Notes { get; set; } = string.Empty;
}
