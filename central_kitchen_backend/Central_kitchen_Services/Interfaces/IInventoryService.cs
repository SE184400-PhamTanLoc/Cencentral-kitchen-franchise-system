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
    Task<ProductionPlanResponseDto> BuildProductionPlanAsync(ProductionPlanRequestDto dto, int? kitchenId = null);
    Task<List<PendingOrderDto>> GetPendingOrdersAsync(int kitchenId);
    // Ingredient CRUD
    Task<IngredientSummaryDto> CreateIngredientAsync(CreateIngredientDto dto);
    Task<IngredientSummaryDto?> UpdateIngredientAsync(int ingredientId, UpdateIngredientDto dto);
    Task<bool> DeleteIngredientAsync(int ingredientId);

    // Recipe CRUD
    Task<List<RecipeResponseDto>> GetRecipesAsync(int? outputIngredientId = null);
    Task<RecipeResponseDto?> GetRecipeByIdAsync(int recipeId);
    Task<RecipeResponseDto> CreateRecipeAsync(int userId, CreateRecipeDto dto);
    Task<RecipeResponseDto?> UpdateRecipeAsync(int recipeId, UpdateRecipeDto dto);
    Task<bool> DeleteRecipeAsync(int recipeId);

    Task<ProductionPlanResponseDto> BuildAutoProductionPlanAsync(int kitchenId);
    Task<BatchResponseDto> ExecuteProductionAsync(ExecuteProductionDto dto);
}

