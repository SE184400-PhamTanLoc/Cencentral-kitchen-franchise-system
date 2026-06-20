using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class DeliveryLogRepository : IDeliveryLogRepository
{
    private readonly ApplicationDbContext _context;

    public DeliveryLogRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeliveryLog> AddAsync(DeliveryLog log)
    {
        _context.DeliveryLogs.Add(log);
        await _context.SaveChangesAsync();
        return log;
    }

    public async Task<DeliveryLog?> GetLatestByOrderIdAsync(int orderId)
    {
        return await _context.DeliveryLogs
            .Where(l => l.OrderId == orderId)
            .OrderByDescending(l => l.RecordedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<List<DeliveryLog>> GetLogsByOrderIdAsync(int orderId)
    {
        return await _context.DeliveryLogs
            .Where(l => l.OrderId == orderId)
            .OrderBy(l => l.RecordedAt)
            .ToListAsync();
    }
}
