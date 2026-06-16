using Central_kitchen_Services.DTOs.Kitchen;

namespace Central_kitchen_Services.Interfaces;

public interface ICentralKitchenService
{
    Task<List<KitchenResponseDto>> GetAllKitchensAsync();
    Task<KitchenResponseDto?> GetKitchenByIdAsync(int kitchenId);
    Task<KitchenResponseDto> CreateKitchenAsync(CreateKitchenDto dto);
    Task<KitchenResponseDto?> UpdateKitchenAsync(int kitchenId, UpdateKitchenDto dto);
    Task<bool> DeleteKitchenAsync(int kitchenId);
}
