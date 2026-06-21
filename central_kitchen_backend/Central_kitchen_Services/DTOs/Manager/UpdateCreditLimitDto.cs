using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Manager;

public class UpdateCreditLimitDto
{
    [Required]
    [Range(0, double.MaxValue)]
    public decimal CreditLimit { get; set; }
}
