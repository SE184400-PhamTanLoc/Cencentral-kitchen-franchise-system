using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IRecipeRepository
{
    Task<Recipe?> GetByOutputIngredientIdAsync(int outputIngredientId);
}

