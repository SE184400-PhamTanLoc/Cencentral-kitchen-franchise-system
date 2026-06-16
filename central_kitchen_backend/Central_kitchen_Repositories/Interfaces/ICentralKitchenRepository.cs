using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface ICentralKitchenRepository
{
    Task<List<CentralKitchen>> GetAllAsync();
    Task<CentralKitchen?> GetByIdAsync(int kitchenId);
    Task<CentralKitchen> AddAsync(CentralKitchen kitchen);
    Task<CentralKitchen> UpdateAsync(CentralKitchen kitchen);
    Task<bool> DeleteAsync(int kitchenId);
}
