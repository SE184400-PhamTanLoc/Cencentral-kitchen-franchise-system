using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Repositories;

public class OrderRepository : IOrderRepository
{
    private readonly ApplicationDbContext _context;

    public OrderRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Order>> GetPendingOrdersByKitchenAsync(int kitchenId)
    {
        return await _context.Orders
            .Include(o => o.Store)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Ingredient)
            .Where(o => o.KitchenId == kitchenId && o.OrderStatus == "Pending")
            .ToListAsync();
    }
}
