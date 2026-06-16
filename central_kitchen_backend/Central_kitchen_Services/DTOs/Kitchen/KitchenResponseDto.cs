namespace Central_kitchen_Services.DTOs.Kitchen;

public class KitchenResponseDto
{
    public int KitchenId { get; set; }
    public string KitchenName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public bool IsActive { get; set; }
    public int StaffCount { get; set; }
}
