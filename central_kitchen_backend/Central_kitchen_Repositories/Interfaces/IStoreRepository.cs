using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IStoreRepository
{
    Task<List<Store>> GetAllAsync();
    Task<Store?> GetByIdAsync(int storeId);
    Task<Store> AddAsync(Store store);
    Task<Store> UpdateAsync(Store store);
    Task<bool> DeleteAsync(int storeId);
}
