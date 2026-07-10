using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Data;
using Central_kitchen_Services.DTOs.Manager;
using Central_kitchen_Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Services.Services;

public class ManagerService : IManagerService
{
    private readonly ApplicationDbContext _context;

    public ManagerService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ManagerDashboardStatsDto> GetDashboardStatsAsync()
    {
        var totalStores = await _context.Stores.CountAsync();
        var pendingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "PENDING");
        var dispatchedOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "DELIVERING" || o.OrderStatus == "SHIPPING" || o.OrderStatus == "DISPATCHED");
        var approvedOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "APPROVED");
        var totalDebt = await _context.Stores.SumAsync(s => (decimal?)s.CurrentDebt) ?? 0;
        
        // Revenue is based on completed/shipped/approved orders today
        var today = DateTime.UtcNow.Date;
        var todayRevenue = await _context.Orders
            .Where(o => o.CreatedAt >= today && o.OrderStatus != "CANCELLED" && o.OrderStatus != "REJECTED")
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;

        return new ManagerDashboardStatsDto
        {
            TotalStores = totalStores,
            TotalPendingOrders = pendingOrders,
            TotalDebt = totalDebt,
            TodayRevenue = todayRevenue,
            DispatchedOrders = dispatchedOrders,
            ApprovedOrders = approvedOrders
        };
    }

    public async Task<List<ManagerPendingOrderDto>> GetPendingOrdersAsync()
    {
        return await _context.Orders
            .Include(o => o.Store)
            .Where(o => o.OrderStatus == "PENDING" || o.OrderStatus == "APPROVED" || o.OrderStatus == "DELIVERING" || o.OrderStatus == "SHIPPING" || o.OrderStatus == "DISPATCHED")
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new ManagerPendingOrderDto
            {
                OrderId = o.OrderId,
                OrderCode = o.OrderCode,
                StoreName = o.Store.StoreName,
                StoreId = o.StoreId,
                ItemCount = o.OrderDetails.Count,
                OrderStatus = o.OrderStatus ?? string.Empty,
                TotalAmount = o.TotalAmount,
                CreatedAt = o.CreatedAt ?? DateTime.UtcNow,
                OrderDate = o.CreatedAt ?? DateTime.UtcNow,

                Notes = o.Notes ?? string.Empty
            })
            .ToListAsync();
    }

    public async Task<List<ChainInventoryDto>> GetChainInventoryAsync()
    {
        var ingredients = await _context.Ingredients.ToListAsync();
        var kitchenBatches = await _context.Batches.ToListAsync();
        var storeInventory = await _context.StoreInventories.ToListAsync();

        var result = new List<ChainInventoryDto>();

        foreach (var ing in ingredients)
        {
            var kitchenStock = kitchenBatches.Where(b => b.IngredientId == ing.IngredientId).Sum(b => b.Quantity);
            var storeStock = storeInventory.Where(s => s.IngredientId == ing.IngredientId).Sum(s => s.StockQuantity) ?? 0;

            result.Add(new ChainInventoryDto
            {
                IngredientId = ing.IngredientId,
                IngredientName = ing.Name,
                Unit = ing.Unit,
                KitchenStock = (decimal)kitchenStock,
                StoreStock = storeStock
            });
        }

        return result.OrderByDescending(x => x.TotalStock).ToList();
    }

    public async Task<AnalyticsDto> GetAnalyticsAsync(int days = 7)
    {
        var startDate = DateTime.UtcNow.Date.AddDays(-days + 1);

        var orders = await _context.Orders
            .Where(o => o.CreatedAt >= startDate)
            .ToListAsync();

        var completedOrders = orders.Where(o => o.OrderStatus == "APPROVED" || o.OrderStatus == "SHIPPED" || o.OrderStatus == "DELIVERED").ToList();
        var cancelledOrders = orders.Where(o => o.OrderStatus == "CANCELLED" || o.OrderStatus == "REJECTED").ToList();

        var dailyRevenues = new List<DailyRevenueDto>();
        for (int i = 0; i < days; i++)
        {
            var date = startDate.AddDays(i);
            var revenue = completedOrders
                .Where(o => o.CreatedAt?.Date == date.Date)
                .Sum(o => (decimal?)o.TotalAmount) ?? 0;

            dailyRevenues.Add(new DailyRevenueDto
            {
                Date = date.ToString("yyyy-MM-dd"),
                Revenue = revenue
            });
        }

        return new AnalyticsDto
        {
            TotalRevenue = completedOrders.Sum(o => (decimal?)o.TotalAmount) ?? 0,
            TotalOrders = orders.Count,
            CancelledOrders = cancelledOrders.Count,
            DailyRevenues = dailyRevenues
        };
    }

    public async Task<List<ManagerStoreDto>> GetStoresAsync()
    {
        return await _context.Stores
            .Select(s => new ManagerStoreDto
            {
                StoreId = s.StoreId,
                StoreName = s.StoreName,
                Address = s.Address ?? string.Empty,
                CreditLimit = s.CreditLimit ?? 0,
                CurrentDebt = s.CurrentDebt ?? 0,
                IsActive = s.IsActive ?? true
            })
            .ToListAsync();
    }

    public async Task<bool> UpdateStoreCreditLimitAsync(int storeId, decimal newCreditLimit)
    {
        var store = await _context.Stores.FindAsync(storeId);
        if (store == null) return false;

        store.CreditLimit = newCreditLimit;
        await _context.SaveChangesAsync();
        return true;
    }
}
