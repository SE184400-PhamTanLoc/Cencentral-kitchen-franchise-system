using System;
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

    // ==================== KITCHEN SIDE ====================

    public async Task<List<Order>> GetPendingOrdersByKitchenAsync(int kitchenId)
    {
        return await _context.Orders
            .Include(o => o.Store)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Ingredient)
            .Where(o => o.KitchenId == kitchenId && o.OrderStatus == "Pending")
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Order>> GetAllOrdersByKitchenAsync(int kitchenId)
    {
        return await _context.Orders
            .Include(o => o.Store)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Ingredient)
            .Include(o => o.CreatedByNavigation)
            .Where(o => o.KitchenId == kitchenId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<int>> GetStaffUserIdsByStoreAsync(int storeId)
    {
        return await _context.Users
            .Where(u => u.StoreId == storeId && u.IsActive == true)
            .Select(u => u.UserId)
            .ToListAsync();
    }

    public async Task<List<int>> GetKitchenStaffUserIdsByKitchenAsync(int kitchenId)
    {
        return await _context.Users
            .Where(u => u.KitchenId == kitchenId && u.IsActive == true)
            .Select(u => u.UserId)
            .ToListAsync();
    }

    // ==================== FRANCHISE SIDE — ORDERS ====================

    public async Task<Order> CreateOrderAsync(Order order)
    {
        _context.Orders.Add(order);
        await _context.SaveChangesAsync();
        return order;
    }

    public async Task<List<Order>> GetOrdersByStoreAsync(int storeId)
    {
        return await _context.Orders
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Ingredient)
            .Include(o => o.CreatedByNavigation)
            .Where(o => o.StoreId == storeId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    public async Task<Order?> GetOrderByIdAsync(int orderId)
    {
        return await _context.Orders
            .Include(o => o.Store)
            .Include(o => o.Kitchen)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Ingredient)
            .Include(o => o.CreatedByNavigation)
            .FirstOrDefaultAsync(o => o.OrderId == orderId);
    }

    // ==================== FRANCHISE SIDE — INVENTORY ====================

    public async Task<List<StoreInventory>> GetStoreInventoryAsync(int storeId)
    {
        return await _context.StoreInventories
            .Include(si => si.Ingredient)
            .Where(si => si.StoreId == storeId)
            .OrderBy(si => si.Ingredient.Name)
            .ToListAsync();
    }

    public async Task UpsertStoreInventoryAsync(int storeId, int ingredientId, decimal quantityDelta)
    {
        var record = await _context.StoreInventories
            .FirstOrDefaultAsync(si => si.StoreId == storeId && si.IngredientId == ingredientId);

        if (record == null)
        {
            _context.StoreInventories.Add(new StoreInventory
            {
                StoreId = storeId,
                IngredientId = ingredientId,
                StockQuantity = Math.Max(0, quantityDelta),
                LastUpdated = DateTime.UtcNow
            });
        }
        else
        {
            record.StockQuantity = (record.StockQuantity ?? 0) + quantityDelta;
            if (record.StockQuantity < 0) record.StockQuantity = 0;
            record.LastUpdated = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }

    public async Task ConsumeStoreInventoryAsync(int storeId, int ingredientId, decimal quantity)
    {
        var record = await _context.StoreInventories
            .FirstOrDefaultAsync(si => si.StoreId == storeId && si.IngredientId == ingredientId);

        if (record == null)
            throw new InvalidOperationException($"Cửa hàng không có tồn kho cho nguyên liệu ID={ingredientId}.");

        if ((record.StockQuantity ?? 0) < quantity)
            throw new InvalidOperationException(
                $"Tồn kho không đủ. Hiện có: {record.StockQuantity}, cần trừ: {quantity}.");

        record.StockQuantity -= quantity;
        record.LastUpdated = DateTime.UtcNow;

        await _context.SaveChangesAsync();
    }

    public async Task UpdateOrderStatusAsync(int orderId, string newStatus)
    {
        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) return;

        order.OrderStatus = newStatus;
        order.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    // ==================== STORE ====================

    public async Task<Store?> GetStoreByIdAsync(int storeId)
    {
        return await _context.Stores.FindAsync(storeId);
    }

    public async Task UpdateStoreDebtAsync(int storeId, decimal debtDelta)
    {
        var store = await _context.Stores.FindAsync(storeId);
        if (store == null) return;

        store.CurrentDebt = (store.CurrentDebt ?? 0) + debtDelta;
        await _context.SaveChangesAsync();
    }
}
