namespace Central_kitchen_Services.DTOs.User;

public class UserResponseDto
{
    public int UserId { get; set; }
    public string Username { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public int RoleId { get; set; }
    public string RoleCode { get; set; } = null!;
    public string RoleName { get; set; } = null!;
    public int? KitchenId { get; set; }
    public string? KitchenName { get; set; }
    public int? StoreId { get; set; }
    public string? StoreName { get; set; }
    public bool IsActive { get; set; }
    public DateTime? CreatedAt { get; set; }
}
