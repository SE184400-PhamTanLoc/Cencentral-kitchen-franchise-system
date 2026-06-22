using System.Collections.Generic;
using System.Threading.Tasks;
using Central_kitchen_Services.DTOs.Manager;

namespace Central_kitchen_Services.Interfaces;

public interface IManagerService
{
    Task<ManagerDashboardStatsDto> GetDashboardStatsAsync();
    Task<List<ManagerPendingOrderDto>> GetPendingOrdersAsync();
    
    // Epic 2: Inventory
    Task<List<ChainInventoryDto>> GetChainInventoryAsync();
    
    // Epic 3: Analytics
    Task<AnalyticsDto> GetAnalyticsAsync(int days = 7);
    
    // Epic 4: Debt & Credit Limit
    Task<List<ManagerStoreDto>> GetStoresAsync();
    Task<bool> UpdateStoreCreditLimitAsync(int storeId, decimal newCreditLimit);
}
