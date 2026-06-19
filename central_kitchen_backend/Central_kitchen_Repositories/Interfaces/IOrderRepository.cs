using System.Collections.Generic;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IOrderRepository
{
    Task<List<Order>> GetPendingOrdersByKitchenAsync(int kitchenId);
}
