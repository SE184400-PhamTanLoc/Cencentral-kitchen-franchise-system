namespace Central_kitchen_Services.DTOs.Store;

public class StoreResponseDto
{
    public int StoreId { get; set; }
    public string StoreName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public decimal? CreditLimit { get; set; }
    public decimal? CurrentDebt { get; set; }
    public bool IsActive { get; set; }
    public int StaffCount { get; set; }
}
