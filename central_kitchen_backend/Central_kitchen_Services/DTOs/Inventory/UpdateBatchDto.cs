using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Inventory;

public class UpdateBatchDto
{
    [Required(ErrorMessage = "Mã lô không được để trống")]
    [StringLength(50)]
    public string BatchCode { get; set; } = null!;

    [Required(ErrorMessage = "Nguyên liệu không được để trống")]
    public int IngredientId { get; set; }

    [Range(0.01, double.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
    public decimal Quantity { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Số lượng còn lại không hợp lệ")]
    public decimal RemainingQuantity { get; set; }

    public DateOnly? ManufactureDate { get; set; }

    [Required(ErrorMessage = "Hạn sử dụng không được để trống")]
    public DateOnly ExpiryDate { get; set; }

    [Required(ErrorMessage = "Bếp trung tâm không được để trống")]
    public int KitchenId { get; set; }
}

