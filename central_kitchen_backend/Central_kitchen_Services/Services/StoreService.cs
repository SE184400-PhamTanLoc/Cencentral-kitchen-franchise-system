using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Store;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class StoreService : IStoreService
{
    private readonly IStoreRepository _storeRepository;

    public StoreService(IStoreRepository storeRepository)
    {
        _storeRepository = storeRepository;
    }

    public async Task<List<StoreResponseDto>> GetAllStoresAsync()
    {
        var stores = await _storeRepository.GetAllAsync();
        return stores.Select(MapToResponseDto).ToList();
    }

    public async Task<StoreResponseDto?> GetStoreByIdAsync(int storeId)
    {
        var store = await _storeRepository.GetByIdAsync(storeId);
        return store == null ? null : MapToResponseDto(store);
    }

    public async Task<StoreResponseDto> CreateStoreAsync(CreateStoreDto dto)
    {
        var store = new Store
        {
            StoreName = dto.StoreName,
            Address = dto.Address,
            PhoneNumber = dto.PhoneNumber,
            CreditLimit = dto.CreditLimit ?? 0,
            CurrentDebt = 0,
            IsActive = true
        };

        var created = await _storeRepository.AddAsync(store);
        return MapToResponseDto(created);
    }

    public async Task<StoreResponseDto?> UpdateStoreAsync(int storeId, UpdateStoreDto dto)
    {
        var store = await _storeRepository.GetByIdAsync(storeId);
        if (store == null) return null;

        store.StoreName = dto.StoreName;
        store.Address = dto.Address;
        store.PhoneNumber = dto.PhoneNumber;
        store.CreditLimit = dto.CreditLimit;
        store.IsActive = dto.IsActive;

        var updated = await _storeRepository.UpdateAsync(store);
        return MapToResponseDto(updated);
    }

    public async Task<bool> DeleteStoreAsync(int storeId)
    {
        return await _storeRepository.DeleteAsync(storeId);
    }

    private static StoreResponseDto MapToResponseDto(Store store)
    {
        return new StoreResponseDto
        {
            StoreId = store.StoreId,
            StoreName = store.StoreName,
            Address = store.Address,
            PhoneNumber = store.PhoneNumber,
            CreditLimit = store.CreditLimit,
            CurrentDebt = store.CurrentDebt,
            IsActive = store.IsActive ?? true,
            StaffCount = store.Users?.Count ?? 0
        };
    }
}
