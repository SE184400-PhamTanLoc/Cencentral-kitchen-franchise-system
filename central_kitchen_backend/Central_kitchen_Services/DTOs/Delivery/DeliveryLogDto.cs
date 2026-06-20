using System;

namespace Central_kitchen_Services.DTOs.Delivery;

public class DeliveryLogDto
{
    public int LogId { get; set; }
    public int OrderId { get; set; }
    public int DriverId { get; set; }
    public string DriverName { get; set; } = null!;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public DateTime? RecordedAt { get; set; }
}
