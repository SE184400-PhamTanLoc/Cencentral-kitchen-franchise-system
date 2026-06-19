using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class IngredientRepository : IIngredientRepository
{
    private readonly ApplicationDbContext _context;

    public IngredientRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Ingredient>> GetAllAsync(bool? isRawMaterial = null, string? keyword = null)
    {
        var query = _context.Ingredients
            .Include(i => i.Batches)
                .ThenInclude(b => b.Kitchen)
            .Include(i => i.Recipe)
                .ThenInclude(r => r!.RecipeDetails)
                    .ThenInclude(rd => rd.InputIngredient)
            .AsSplitQuery()
            .AsQueryable();

        if (isRawMaterial.HasValue)
            query = query.Where(i => i.IsRawMaterial == isRawMaterial.Value);

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var normalized = keyword.Trim();
            query = query.Where(i =>
                i.Name.Contains(normalized) ||
                i.Sku.Contains(normalized));
        }

        return await query
            .OrderBy(i => i.Name)
            .ToListAsync();
    }

    public async Task<List<Ingredient>> GetByIdsAsync(IEnumerable<int> ingredientIds)
    {
        var ids = ingredientIds.Distinct().ToList();
        return await _context.Ingredients
            .Include(i => i.Batches)
            .Where(i => ids.Contains(i.IngredientId))
            .AsSplitQuery()
            .ToListAsync();
    }

    public async Task<Ingredient?> GetByIdAsync(int ingredientId)
    {
        return await _context.Ingredients
            .Include(i => i.Batches)
                .ThenInclude(b => b.Kitchen)
            .Include(i => i.Recipe)
                .ThenInclude(r => r!.RecipeDetails)
                    .ThenInclude(rd => rd.InputIngredient)
            .AsSplitQuery()
            .FirstOrDefaultAsync(i => i.IngredientId == ingredientId);
    }
}
