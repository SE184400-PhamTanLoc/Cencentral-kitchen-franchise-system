using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.User;

public class UpdateUserDto
{
    [Required(ErrorMessage = "Họ tên không được để trống")]
    [StringLength(100)]
    public string FullName { get; set; } = null!;

    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    [StringLength(100)]
    public string? Email { get; set; }

    [StringLength(20)]
    public string? PhoneNumber { get; set; }

    [Required(ErrorMessage = "Vai trò không được để trống")]
    public int RoleId { get; set; }

    public int? KitchenId { get; set; }

    public int? StoreId { get; set; }

    public bool IsActive { get; set; } = true;
}
