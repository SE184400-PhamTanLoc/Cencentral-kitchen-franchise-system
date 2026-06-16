using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.User;

public class CreateUserDto
{
    [Required(ErrorMessage = "Tên đăng nhập không được để trống")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Tên đăng nhập phải từ 3-50 ký tự")]
    public string Username { get; set; } = null!;

    [Required(ErrorMessage = "Mật khẩu không được để trống")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Mật khẩu phải từ 6-100 ký tự")]
    public string Password { get; set; } = null!;

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
}
