using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IIngredientRepository
{
    Task<List<Ingredient>> GetAllAsync(bool? isRawMaterial = null, string? keyword = null);
    Task<List<Ingredient>> GetByIdsAsync(IEnumerable<int> ingredientIds);
    Task<Ingredient?> GetByIdAsync(int ingredientId);
    Task<Ingredient> AddAsync(Ingredient ingredient);
    Task<Ingredient> UpdateAsync(Ingredient ingredient);
    Task<bool> DeleteAsync(int ingredientId);
}

