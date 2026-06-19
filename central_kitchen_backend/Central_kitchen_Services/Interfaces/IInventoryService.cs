using Central_kitchen_Services.DTOs.Inventory;

namespace Central_kitchen_Services.Interfaces;

public interface IInventoryService
{
    Task<List<IngredientSummaryDto>> GetIngredientsAsync(bool? isRawMaterial = null, string? keyword = null);
    Task<IngredientDetailDto?> GetIngredientByIdAsync(int ingredientId);
    Task<List<BatchResponseDto>> GetBatchesAsync(int? ingredientId = null, int? kitchenId = null);
    Task<BatchResponseDto?> GetBatchByIdAsync(int batchId);
    Task<BatchResponseDto> CreateBatchAsync(CreateBatchDto dto);
    Task<BatchResponseDto?> UpdateBatchAsync(int batchId, UpdateBatchDto dto);
    Task<bool> DeleteBatchAsync(int batchId);
    Task<ProductionPlanResponseDto> BuildProductionPlanAsync(ProductionPlanRequestDto dto);
    Task<List<PendingOrderDto>> GetPendingOrdersAsync(int kitchenId);
    Task<ProductionPlanResponseDto> BuildAutoProductionPlanAsync(int kitchenId);
}

