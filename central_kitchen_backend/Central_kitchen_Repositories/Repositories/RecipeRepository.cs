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

    public async Task<List<Recipe>> GetAllAsync()
    {
        return await _context.Recipes
            .Include(r => r.OutputIngredient)
            .Include(r => r.CreatedByNavigation)
            .Include(r => r.RecipeDetails)
                .ThenInclude(rd => rd.InputIngredient)
            .ToListAsync();
    }

    public async Task<Recipe?> GetByIdAsync(int recipeId)
    {
        return await _context.Recipes
            .Include(r => r.OutputIngredient)
            .Include(r => r.CreatedByNavigation)
            .Include(r => r.RecipeDetails)
                .ThenInclude(rd => rd.InputIngredient)
            .FirstOrDefaultAsync(r => r.RecipeId == recipeId);
    }

    public async Task<Recipe> AddAsync(Recipe recipe)
    {
        _context.Recipes.Add(recipe);
        await _context.SaveChangesAsync();
        return recipe;
    }

    public async Task<Recipe> UpdateAsync(Recipe recipe)
    {
        _context.Recipes.Update(recipe);
        await _context.SaveChangesAsync();
        return recipe;
    }

    public async Task<bool> DeleteAsync(int recipeId)
    {
        var recipe = await _context.Recipes.FindAsync(recipeId);
        if (recipe == null) return false;
        
        // Let EF handle cascade delete if configured, or delete details explicitly if needed.
        // Assuming cascade delete is set up for RecipeDetails.
        _context.Recipes.Remove(recipe);
        await _context.SaveChangesAsync();
        return true;
    }
}

