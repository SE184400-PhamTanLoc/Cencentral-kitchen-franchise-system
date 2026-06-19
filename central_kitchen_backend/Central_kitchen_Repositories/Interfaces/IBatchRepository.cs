using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IBatchRepository
{
    Task<List<Batch>> GetAllAsync(int? ingredientId = null, int? kitchenId = null);
    Task<Batch?> GetByIdAsync(int batchId);
    Task<Batch> AddAsync(Batch batch);
    Task<Batch> UpdateAsync(Batch batch);
    Task<bool> DeleteAsync(int batchId);
}

