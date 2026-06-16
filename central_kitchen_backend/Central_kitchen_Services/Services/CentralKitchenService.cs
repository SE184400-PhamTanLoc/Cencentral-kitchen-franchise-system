using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Kitchen;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class CentralKitchenService : ICentralKitchenService
{
    private readonly ICentralKitchenRepository _kitchenRepository;

    public CentralKitchenService(ICentralKitchenRepository kitchenRepository)
    {
        _kitchenRepository = kitchenRepository;
    }

    public async Task<List<KitchenResponseDto>> GetAllKitchensAsync()
    {
        var kitchens = await _kitchenRepository.GetAllAsync();
        return kitchens.Select(MapToResponseDto).ToList();
    }

    public async Task<KitchenResponseDto?> GetKitchenByIdAsync(int kitchenId)
    {
        var kitchen = await _kitchenRepository.GetByIdAsync(kitchenId);
        return kitchen == null ? null : MapToResponseDto(kitchen);
    }

    public async Task<KitchenResponseDto> CreateKitchenAsync(CreateKitchenDto dto)
    {
        var kitchen = new CentralKitchen
        {
            KitchenName = dto.KitchenName,
            Address = dto.Address,
            PhoneNumber = dto.PhoneNumber,
            IsActive = true
        };

        var created = await _kitchenRepository.AddAsync(kitchen);
        return MapToResponseDto(created);
    }

    public async Task<KitchenResponseDto?> UpdateKitchenAsync(int kitchenId, UpdateKitchenDto dto)
    {
        var kitchen = await _kitchenRepository.GetByIdAsync(kitchenId);
        if (kitchen == null) return null;

        kitchen.KitchenName = dto.KitchenName;
        kitchen.Address = dto.Address;
        kitchen.PhoneNumber = dto.PhoneNumber;
        kitchen.IsActive = dto.IsActive;

        var updated = await _kitchenRepository.UpdateAsync(kitchen);
        return MapToResponseDto(updated);
    }

    public async Task<bool> DeleteKitchenAsync(int kitchenId)
    {
        return await _kitchenRepository.DeleteAsync(kitchenId);
    }

    private static KitchenResponseDto MapToResponseDto(CentralKitchen kitchen)
    {
        return new KitchenResponseDto
        {
            KitchenId = kitchen.KitchenId,
            KitchenName = kitchen.KitchenName,
            Address = kitchen.Address,
            PhoneNumber = kitchen.PhoneNumber,
            IsActive = kitchen.IsActive ?? true,
            StaffCount = kitchen.Users?.Count ?? 0
        };
    }
}
