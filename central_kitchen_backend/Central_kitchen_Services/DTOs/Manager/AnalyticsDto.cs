using System.Collections.Generic;

namespace Central_kitchen_Services.DTOs.Manager;

public class AnalyticsDto
{
    public decimal TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public int CancelledOrders { get; set; }
    public List<DailyRevenueDto> DailyRevenues { get; set; } = new();
}

public class DailyRevenueDto
{
    public string Date { get; set; } = null!;
    public decimal Revenue { get; set; }
}
