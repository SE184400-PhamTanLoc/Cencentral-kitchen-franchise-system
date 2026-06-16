using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class DeliveryLog
{
    public int LogId { get; set; }

    public int OrderId { get; set; }

    public int DriverId { get; set; }

    public decimal Latitude { get; set; }

    public decimal Longitude { get; set; }

    public DateTime? RecordedAt { get; set; }

    public virtual User Driver { get; set; } = null!;

    public virtual Order Order { get; set; } = null!;
}
