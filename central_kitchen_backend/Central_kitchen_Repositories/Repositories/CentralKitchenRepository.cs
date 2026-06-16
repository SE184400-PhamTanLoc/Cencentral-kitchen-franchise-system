using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class CentralKitchenRepository : ICentralKitchenRepository
{
    private readonly ApplicationDbContext _context;

    public CentralKitchenRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<CentralKitchen>> GetAllAsync()
    {
        return await _context.CentralKitchens
            .Include(k => k.Users)
            .OrderBy(k => k.KitchenName)
            .ToListAsync();
    }

    public async Task<CentralKitchen?> GetByIdAsync(int kitchenId)
    {
        return await _context.CentralKitchens
            .Include(k => k.Users)
            .FirstOrDefaultAsync(k => k.KitchenId == kitchenId);
    }

    public async Task<CentralKitchen> AddAsync(CentralKitchen kitchen)
    {
        _context.CentralKitchens.Add(kitchen);
        await _context.SaveChangesAsync();
        return kitchen;
    }

    public async Task<CentralKitchen> UpdateAsync(CentralKitchen kitchen)
    {
        _context.CentralKitchens.Update(kitchen);
        await _context.SaveChangesAsync();
        return kitchen;
    }

    public async Task<bool> DeleteAsync(int kitchenId)
    {
        var kitchen = await _context.CentralKitchens.FindAsync(kitchenId);
        if (kitchen == null) return false;
        _context.CentralKitchens.Remove(kitchen);
        await _context.SaveChangesAsync();
        return true;
    }
}
