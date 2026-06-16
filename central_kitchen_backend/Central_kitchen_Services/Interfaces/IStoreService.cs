using Central_kitchen_Services.DTOs.Store;

namespace Central_kitchen_Services.Interfaces;

public interface IStoreService
{
    Task<List<StoreResponseDto>> GetAllStoresAsync();
    Task<StoreResponseDto?> GetStoreByIdAsync(int storeId);
    Task<StoreResponseDto> CreateStoreAsync(CreateStoreDto dto);
    Task<StoreResponseDto?> UpdateStoreAsync(int storeId, UpdateStoreDto dto);
    Task<bool> DeleteStoreAsync(int storeId);
}
