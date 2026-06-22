namespace Central_kitchen_Services.DTOs.Manager;

public class ManagerStoreDto
{
    public int StoreId { get; set; }
    public string StoreName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public decimal CreditLimit { get; set; }
    public decimal CurrentDebt { get; set; }
    public bool IsActive { get; set; }
}
