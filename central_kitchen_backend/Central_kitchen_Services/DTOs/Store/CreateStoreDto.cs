using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Store;

public class CreateStoreDto
{
    [Required(ErrorMessage = "Tên cửa hàng không được để trống")]
    [StringLength(150)]
    public string StoreName { get; set; } = null!;

    [Required(ErrorMessage = "Địa chỉ không được để trống")]
    public string Address { get; set; } = null!;

    [StringLength(20)]
    public string? PhoneNumber { get; set; }

    public decimal? CreditLimit { get; set; }
}
