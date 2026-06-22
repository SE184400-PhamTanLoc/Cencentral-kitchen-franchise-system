using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IRecipeRepository
{
    Task<Recipe?> GetByOutputIngredientIdAsync(int outputIngredientId);
    Task<List<Recipe>> GetAllAsync();
    Task<Recipe?> GetByIdAsync(int recipeId);
    Task<Recipe> AddAsync(Recipe recipe);
    Task<Recipe> UpdateAsync(Recipe recipe);
    Task<bool> DeleteAsync(int recipeId);
}

