using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Delivery;

public class CreateDeliveryLogDto
{
    [Required]
    public int OrderId { get; set; }
    
    [Required]
    public int DriverId { get; set; }
    
    [Required]
    public decimal Latitude { get; set; }
    
    [Required]
    public decimal Longitude { get; set; }
}
