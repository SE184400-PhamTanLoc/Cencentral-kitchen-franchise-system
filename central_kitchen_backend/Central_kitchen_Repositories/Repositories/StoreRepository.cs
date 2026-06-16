using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class StoreRepository : IStoreRepository
{
    private readonly ApplicationDbContext _context;

    public StoreRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Store>> GetAllAsync()
    {
        return await _context.Stores
            .Include(s => s.Users)
            .OrderBy(s => s.StoreName)
            .ToListAsync();
    }

    public async Task<Store?> GetByIdAsync(int storeId)
    {
        return await _context.Stores
            .Include(s => s.Users)
            .FirstOrDefaultAsync(s => s.StoreId == storeId);
    }

    public async Task<Store> AddAsync(Store store)
    {
        _context.Stores.Add(store);
        await _context.SaveChangesAsync();
        return store;
    }

    public async Task<Store> UpdateAsync(Store store)
    {
        _context.Stores.Update(store);
        await _context.SaveChangesAsync();
        return store;
    }

    public async Task<bool> DeleteAsync(int storeId)
    {
        var store = await _context.Stores.FindAsync(storeId);
        if (store == null) return false;
        _context.Stores.Remove(store);
        await _context.SaveChangesAsync();
        return true;
    }
}
