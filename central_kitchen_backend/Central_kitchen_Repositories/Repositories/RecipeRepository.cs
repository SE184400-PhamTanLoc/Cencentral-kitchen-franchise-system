using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class RecipeRepository : IRecipeRepository
{
    private readonly ApplicationDbContext _context;

    public RecipeRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Recipe?> GetByOutputIngredientIdAsync(int outputIngredientId)
    {
        return await _context.Recipes
            .Include(r => r.OutputIngredient)
            .Include(r => r.CreatedByNavigation)
            .Include(r => r.RecipeDetails)
                .ThenInclude(rd => rd.InputIngredient)
            .FirstOrDefaultAsync(r => r.OutputIngredientId == outputIngredientId);
    }
}

