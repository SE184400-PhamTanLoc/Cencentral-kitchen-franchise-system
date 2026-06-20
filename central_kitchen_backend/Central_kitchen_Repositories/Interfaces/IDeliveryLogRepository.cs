using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IDeliveryLogRepository
{
    Task<DeliveryLog> AddAsync(DeliveryLog log);
    Task<DeliveryLog?> GetLatestByOrderIdAsync(int orderId);
    Task<List<DeliveryLog>> GetLogsByOrderIdAsync(int orderId);
}
