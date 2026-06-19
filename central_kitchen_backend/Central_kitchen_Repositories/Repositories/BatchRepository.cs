using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class BatchRepository : IBatchRepository
{
    private readonly ApplicationDbContext _context;

    public BatchRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Batch>> GetAllAsync(int? ingredientId = null, int? kitchenId = null)
    {
        var query = _context.Batches
            .Include(b => b.Ingredient)
            .Include(b => b.Kitchen)
            .AsQueryable();

        if (ingredientId.HasValue)
            query = query.Where(b => b.IngredientId == ingredientId.Value);

        if (kitchenId.HasValue)
            query = query.Where(b => b.KitchenId == kitchenId.Value);

        return await query
            .OrderByDescending(b => b.ExpiryDate)
            .ThenByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<Batch?> GetByIdAsync(int batchId)
    {
        return await _context.Batches
            .Include(b => b.Ingredient)
            .Include(b => b.Kitchen)
            .FirstOrDefaultAsync(b => b.BatchId == batchId);
    }

    public async Task<Batch> AddAsync(Batch batch)
    {
        _context.Batches.Add(batch);
        await _context.SaveChangesAsync();
        await _context.Entry(batch).Reference(b => b.Ingredient).LoadAsync();
        await _context.Entry(batch).Reference(b => b.Kitchen).LoadAsync();
        return batch;
    }

    public async Task<Batch> UpdateAsync(Batch batch)
    {
        _context.Batches.Update(batch);
        await _context.SaveChangesAsync();
        await _context.Entry(batch).Reference(b => b.Ingredient).LoadAsync();
        await _context.Entry(batch).Reference(b => b.Kitchen).LoadAsync();
        return batch;
    }

    public async Task<bool> DeleteAsync(int batchId)
    {
        var batch = await _context.Batches.FindAsync(batchId);
        if (batch == null) return false;
        _context.Batches.Remove(batch);
        await _context.SaveChangesAsync();
        return true;
    }
}

