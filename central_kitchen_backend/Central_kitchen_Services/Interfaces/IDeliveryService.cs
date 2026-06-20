using Central_kitchen_Services.DTOs.Delivery;

namespace Central_kitchen_Services.Interfaces;

public interface IDeliveryService
{
    Task<DeliveryLogDto> AddDeliveryLogAsync(CreateDeliveryLogDto dto);
    Task<DeliveryLogDto?> GetLatestLocationByOrderIdAsync(int orderId);
    Task<List<DeliveryLogDto>> GetLogsByOrderIdAsync(int orderId);
}
