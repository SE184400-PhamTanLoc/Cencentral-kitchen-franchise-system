using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Delivery;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class DeliveryService : IDeliveryService
{
    private readonly IDeliveryLogRepository _deliveryLogRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IUserRepository _userRepository;

    public DeliveryService(
        IDeliveryLogRepository deliveryLogRepository,
        IOrderRepository orderRepository,
        IUserRepository userRepository)
    {
        _deliveryLogRepository = deliveryLogRepository;
        _orderRepository = orderRepository;
        _userRepository = userRepository;
    }

    public async Task<DeliveryLogDto> AddDeliveryLogAsync(CreateDeliveryLogDto dto)
    {
        var order = await _orderRepository.GetOrderByIdAsync(dto.OrderId);
        if (order == null)
            throw new InvalidOperationException("Đơn hàng không tồn tại.");

        var driver = await _userRepository.GetByIdAsync(dto.DriverId);
        if (driver == null)
            throw new InvalidOperationException("Tài xế không tồn tại.");

        var log = new DeliveryLog
        {
            OrderId = dto.OrderId,
            DriverId = dto.DriverId,
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            RecordedAt = DateTime.UtcNow
        };

        var createdLog = await _deliveryLogRepository.AddAsync(log);
        createdLog.Driver = driver;
        return MapToDto(createdLog);
    }

    public async Task<DeliveryLogDto?> GetLatestLocationByOrderIdAsync(int orderId)
    {
        var log = await _deliveryLogRepository.GetLatestByOrderIdAsync(orderId);
        if (log == null) return null;

        var driver = await _userRepository.GetByIdAsync(log.DriverId);
        if (driver != null) log.Driver = driver;
        return MapToDto(log);
    }

    public async Task<List<DeliveryLogDto>> GetLogsByOrderIdAsync(int orderId)
    {
        var logs = await _deliveryLogRepository.GetLogsByOrderIdAsync(orderId);
        foreach (var log in logs)
        {
            var driver = await _userRepository.GetByIdAsync(log.DriverId);
            if (driver != null) log.Driver = driver;
        }
        return logs.Select(MapToDto).ToList();
    }

    private static DeliveryLogDto MapToDto(DeliveryLog log)
    {
        return new DeliveryLogDto
        {
            LogId = log.LogId,
            OrderId = log.OrderId,
            DriverId = log.DriverId,
            DriverName = log.Driver?.FullName ?? $"Driver {log.DriverId}",
            Latitude = log.Latitude,
            Longitude = log.Longitude,
            RecordedAt = log.RecordedAt
        };
    }
}
