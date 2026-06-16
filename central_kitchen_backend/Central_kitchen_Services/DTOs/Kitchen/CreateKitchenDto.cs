using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Kitchen;

public class CreateKitchenDto
{
    [Required(ErrorMessage = "Tên bếp trung tâm không được để trống")]
    [StringLength(150)]
    public string KitchenName { get; set; } = null!;

    [Required(ErrorMessage = "Địa chỉ không được để trống")]
    public string Address { get; set; } = null!;

    [StringLength(20)]
    public string? PhoneNumber { get; set; }
}
