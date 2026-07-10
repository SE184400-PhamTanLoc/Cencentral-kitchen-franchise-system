using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Inventory;
using Central_kitchen_Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Services.Services;

public class InventoryService : IInventoryService
{
    private readonly IIngredientRepository _ingredientRepository;
    private readonly IBatchRepository _batchRepository;
    private readonly ICentralKitchenRepository _kitchenRepository;
    private readonly IRecipeRepository _recipeRepository;
    private readonly IOrderRepository _orderRepository;

    public InventoryService(
        IIngredientRepository ingredientRepository,
        IBatchRepository batchRepository,
        ICentralKitchenRepository kitchenRepository,
        IRecipeRepository recipeRepository,
        IOrderRepository orderRepository)
    {
        _ingredientRepository = ingredientRepository;
        _batchRepository = batchRepository;
        _kitchenRepository = kitchenRepository;
        _recipeRepository = recipeRepository;
        _orderRepository = orderRepository;
    }

    public async Task<List<IngredientSummaryDto>> GetIngredientsAsync(bool? isRawMaterial = null, string? keyword = null)
    {
        var ingredients = await _ingredientRepository.GetAllAsync(isRawMaterial, keyword);
        return ingredients.Select(MapIngredientSummary).ToList();
    }

    public async Task<IngredientDetailDto?> GetIngredientByIdAsync(int ingredientId)
    {
        var ingredient = await _ingredientRepository.GetByIdAsync(ingredientId);
        if (ingredient == null) return null;
        return MapIngredientDetail(ingredient);
    }

    public async Task<List<BatchResponseDto>> GetBatchesAsync(int? ingredientId = null, int? kitchenId = null)
    {
        var batches = await _batchRepository.GetAllAsync(ingredientId, kitchenId);
        return batches.Select(MapBatch).ToList();
    }

    public async Task<BatchResponseDto?> GetBatchByIdAsync(int batchId)
    {
        var batch = await _batchRepository.GetByIdAsync(batchId);
        return batch == null ? null : MapBatch(batch);
    }

    public async Task<BatchResponseDto> CreateBatchAsync(CreateBatchDto dto)
    {
        await ValidateIngredientExistsAsync(dto.IngredientId);
        await ValidateKitchenExistsAsync(dto.KitchenId);

        var remainingQuantity = dto.RemainingQuantity ?? dto.Quantity;
        ValidateBatchQuantities(dto.Quantity, remainingQuantity);

        var batch = new Batch
        {
            BatchCode = dto.BatchCode.Trim(),
            IngredientId = dto.IngredientId,
            Quantity = dto.Quantity,
            RemainingQuantity = remainingQuantity,
            ManufactureDate = dto.ManufactureDate,
            ExpiryDate = dto.ExpiryDate,
            KitchenId = dto.KitchenId,
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            var created = await _batchRepository.AddAsync(batch);
            return MapBatch(created);
        }
        catch (DbUpdateException ex)
        {
            throw new InvalidOperationException("Không thể tạo lô mới. Vui lòng kiểm tra mã lô hoặc dữ liệu liên quan.", ex);
        }
    }

    public async Task<BatchResponseDto?> UpdateBatchAsync(int batchId, UpdateBatchDto dto)
    {
        var batch = await _batchRepository.GetByIdAsync(batchId);
        if (batch == null) return null;

        await ValidateIngredientExistsAsync(dto.IngredientId);
        await ValidateKitchenExistsAsync(dto.KitchenId);
        ValidateBatchQuantities(dto.Quantity, dto.RemainingQuantity);

        batch.BatchCode = dto.BatchCode.Trim();
        batch.IngredientId = dto.IngredientId;
        batch.Quantity = dto.Quantity;
        batch.RemainingQuantity = dto.RemainingQuantity;
        batch.ManufactureDate = dto.ManufactureDate;
        batch.ExpiryDate = dto.ExpiryDate;
        batch.KitchenId = dto.KitchenId;

        try
        {
            var updated = await _batchRepository.UpdateAsync(batch);
            return MapBatch(updated);
        }
        catch (DbUpdateException ex)
        {
            throw new InvalidOperationException("Không thể cập nhật lô. Vui lòng kiểm tra dữ liệu đầu vào.", ex);
        }
    }

    public async Task<bool> DeleteBatchAsync(int batchId)
    {
        return await _batchRepository.DeleteAsync(batchId);
    }

    public async Task<ProductionPlanResponseDto> BuildProductionPlanAsync(ProductionPlanRequestDto dto, int? kitchenId = null)
    {
        var outputIngredient = await _ingredientRepository.GetByIdAsync(dto.OutputIngredientId);
        if (outputIngredient == null)
            throw new InvalidOperationException("Không tìm thấy nguyên liệu đầu ra.");

        if (dto.RequestedQuantity <= 0)
            throw new InvalidOperationException("Số lượng yêu cầu phải lớn hơn 0.");

        var recipe = await _recipeRepository.GetByOutputIngredientIdAsync(dto.OutputIngredientId);
        if (recipe == null)
        {
            if (outputIngredient.IsRawMaterial == true)
            {
                return new ProductionPlanResponseDto
                {
                    OutputIngredientId = outputIngredient.IngredientId,
                    OutputIngredientName = outputIngredient.Name,
                    OutputSku = outputIngredient.Sku,
                    RecipeDescription = null,
                    RequestedQuantity = dto.RequestedQuantity,
                    Materials = new List<ProductionPlanItemDto>
                    {
                        new ProductionPlanItemDto
                        {
                            IngredientId = outputIngredient.IngredientId,
                            IngredientName = outputIngredient.Name,
                            Sku = outputIngredient.Sku,
                            Unit = outputIngredient.Unit,
                            IsRawMaterial = true,
                            RequiredQuantity = dto.RequestedQuantity,
                            AvailableQuantity = GetAvailableQuantity(outputIngredient, kitchenId),
                            ShortageQuantity = Math.Max(0, dto.RequestedQuantity - GetAvailableQuantity(outputIngredient, kitchenId))
                        }
                    }
                };
            }

            throw new InvalidOperationException("Sản phẩm đầu ra chưa có định mức BOM.");
        }

        var rawTotals = new Dictionary<int, decimal>();
        await ExpandToRawMaterialsAsync(recipe.OutputIngredientId, dto.RequestedQuantity, rawTotals, new HashSet<int>(), kitchenId);

        var rawIngredients = await _ingredientRepository.GetByIdsAsync(rawTotals.Keys);
        var ingredientLookup = rawIngredients.ToDictionary(i => i.IngredientId, i => i);

        var materials = rawTotals
            .Select(pair =>
            {
                var ingredient = ingredientLookup[pair.Key];
                var availableQuantity = GetAvailableQuantity(ingredient, kitchenId);
                return new ProductionPlanItemDto
                {
                    IngredientId = ingredient.IngredientId,
                    IngredientName = ingredient.Name,
                    Sku = ingredient.Sku,
                    Unit = ingredient.Unit,
                    IsRawMaterial = ingredient.IsRawMaterial ?? true,
                    RequiredQuantity = pair.Value,
                    AvailableQuantity = availableQuantity,
                    ShortageQuantity = Math.Max(0, pair.Value - availableQuantity)
                };
            })
            .OrderBy(x => x.IngredientName)
            .ToList();

        return new ProductionPlanResponseDto
        {
            OutputIngredientId = outputIngredient.IngredientId,
            OutputIngredientName = outputIngredient.Name,
            OutputSku = outputIngredient.Sku,
            RecipeDescription = recipe.Description,
            RequestedQuantity = dto.RequestedQuantity,
            Materials = materials
        };
    }

    public async Task<List<PendingOrderDto>> GetPendingOrdersAsync(int kitchenId)
    {
        var orders = await _orderRepository.GetPendingOrdersByKitchenAsync(kitchenId);
        return orders.Select(o => new PendingOrderDto
        {
            OrderId = o.OrderId,
            OrderCode = o.OrderCode,
            StoreId = o.StoreId,
            StoreName = o.Store.StoreName,
            TotalAmount = o.TotalAmount,
            OrderStatus = o.OrderStatus,
            CreatedAt = o.CreatedAt,
            OrderDetails = o.OrderDetails.Select(od => new PendingOrderDetailDto
            {
                IngredientId = od.IngredientId,
                IngredientName = od.Ingredient.Name,
                Unit = od.Ingredient.Unit,
                QuantityOrdered = od.QuantityOrdered
            }).ToList()
        }).ToList();
    }

    public async Task<ProductionPlanResponseDto> BuildAutoProductionPlanAsync(int kitchenId)
    {
        var orders = await _orderRepository.GetPendingOrdersByKitchenAsync(kitchenId);
        
        // Gộp tất cả các Ingredient yêu cầu từ các đơn
        var requestedTotals = new Dictionary<int, decimal>();
        foreach (var order in orders)
        {
            foreach (var detail in order.OrderDetails)
            {
                if (requestedTotals.ContainsKey(detail.IngredientId))
                {
                    requestedTotals[detail.IngredientId] += detail.QuantityOrdered;
                }
                else
                {
                    requestedTotals[detail.IngredientId] = detail.QuantityOrdered;
                }
            }
        }

        var rawTotals = new Dictionary<int, decimal>();
        foreach (var req in requestedTotals)
        {
            var ingredientId = req.Key;
            var quantity = req.Value;
            await ExpandToRawMaterialsAsync(ingredientId, quantity, rawTotals, new HashSet<int>(), kitchenId);
        }

        var rawIngredients = await _ingredientRepository.GetByIdsAsync(rawTotals.Keys);
        var ingredientLookup = rawIngredients.ToDictionary(i => i.IngredientId, i => i);

        var materials = rawTotals
            .Select(pair =>
            {
                var ingredient = ingredientLookup[pair.Key];
                var availableQuantity = GetAvailableQuantity(ingredient, kitchenId);
                return new ProductionPlanItemDto
                {
                    IngredientId = ingredient.IngredientId,
                    IngredientName = ingredient.Name,
                    Sku = ingredient.Sku,
                    Unit = ingredient.Unit,
                    IsRawMaterial = ingredient.IsRawMaterial ?? true,
                    RequiredQuantity = pair.Value,
                    AvailableQuantity = availableQuantity,
                    ShortageQuantity = Math.Max(0, pair.Value - availableQuantity)
                };
            })
            .OrderBy(x => x.IngredientName)
            .ToList();

        return new ProductionPlanResponseDto
        {
            OutputIngredientId = 0,
            OutputIngredientName = "Auto Plan (Multiple Orders)",
            OutputSku = "AUTO",
            RecipeDescription = $"Plan generated for {orders.Count} pending orders.",
            RequestedQuantity = 1, // Dùng tượng trưng
            Materials = materials
        };
    }

    private async Task ExpandToRawMaterialsAsync(
        int ingredientId, 
        decimal requiredQty, 
        Dictionary<int, decimal> rawTotals, 
        HashSet<int> recursionStack,
        int? kitchenId = null)
    {
        if (recursionStack.Contains(ingredientId))
            throw new InvalidOperationException("Phát hiện vòng lặp trong BOM. Vui lòng kiểm tra lại định mức sản xuất.");

        var ingredient = await _ingredientRepository.GetByIdAsync(ingredientId);
        if (ingredient == null)
            throw new InvalidOperationException($"Không tìm thấy nguyên liệu có ID = {ingredientId}.");

        var availableQty = GetAvailableQuantity(ingredient, kitchenId);

        // Nếu lượng tồn kho khả dụng đáp ứng đủ nhu cầu, ghi nhận nhu cầu trực tiếp và dừng việc phân tách BOM
        if (availableQty >= requiredQty)
        {
            if (rawTotals.ContainsKey(ingredientId))
                rawTotals[ingredientId] += requiredQty;
            else
                rawTotals[ingredientId] = requiredQty;
            return;
        }

        // Nếu tồn kho có một ít nhưng không đủ, tiêu thụ hết lượng tồn kho khả dụng đó
        var shortageQty = requiredQty - availableQty;
        if (availableQty > 0)
        {
            if (rawTotals.ContainsKey(ingredientId))
                rawTotals[ingredientId] += availableQty;
            else
                rawTotals[ingredientId] = availableQty;
        }

        // Tìm công thức định mức để sản xuất lượng thiếu (shortageQty)
        var recipe = await _recipeRepository.GetByOutputIngredientIdAsync(ingredientId);
        if (recipe == null)
        {
            // Nếu không có công thức (nguyên liệu thô hoặc BFP chưa khai báo BOM), lượng thiếu này sẽ được yêu cầu trực tiếp
            if (rawTotals.ContainsKey(ingredientId))
                rawTotals[ingredientId] += shortageQty;
            else
                rawTotals[ingredientId] = shortageQty;
            return;
        }

        // Phân tách lượng thiếu thành các nguyên liệu thành phần theo công thức
        recursionStack.Add(ingredientId);

        foreach (var detail in recipe.RecipeDetails)
        {
            var componentRequiredQty = detail.QuantityRequired * shortageQty;
            await ExpandToRawMaterialsAsync(detail.InputIngredientId, componentRequiredQty, rawTotals, recursionStack, kitchenId);
        }

        recursionStack.Remove(ingredientId);
    }

    private static decimal GetAvailableQuantity(Ingredient ingredient, int? kitchenId = null)
    {
        if (kitchenId.HasValue)
        {
            return ingredient.Batches?.Where(b => b.KitchenId == kitchenId.Value).Sum(b => b.RemainingQuantity) ?? 0m;
        }
        return ingredient.Batches?.Sum(b => b.RemainingQuantity) ?? 0m;
    }

    private static IngredientSummaryDto MapIngredientSummary(Ingredient ingredient)
    {
        var batches = ingredient.Batches ?? new List<Batch>();
        return new IngredientSummaryDto
        {
            IngredientId = ingredient.IngredientId,
            Name = ingredient.Name,
            Sku = ingredient.Sku,
            Unit = ingredient.Unit,
            UnitPrice = ingredient.UnitPrice,
            IsRawMaterial = ingredient.IsRawMaterial ?? true,
            MinStockLevel = ingredient.MinStockLevel ?? 0m,
            CreatedAt = ingredient.CreatedAt,
            AvailableQuantity = batches.Sum(b => b.RemainingQuantity),
            BatchCount = batches.Count,
            LatestExpiryDate = batches.Count == 0 ? null : batches.OrderBy(b => b.ExpiryDate).Last().ExpiryDate,
            LatestBatchCode = batches.Count == 0 ? null : batches.OrderBy(b => b.CreatedAt).Last().BatchCode,
            HasRecipe = ingredient.Recipe != null
        };
    }

    private static IngredientDetailDto MapIngredientDetail(Ingredient ingredient)
    {
        var batches = (ingredient.Batches ?? new List<Batch>())
            .OrderByDescending(b => b.ExpiryDate)
            .ThenByDescending(b => b.CreatedAt)
            .Select(MapBatch)
            .ToList();

        return new IngredientDetailDto
        {
            IngredientId = ingredient.IngredientId,
            Name = ingredient.Name,
            Sku = ingredient.Sku,
            Unit = ingredient.Unit,
            UnitPrice = ingredient.UnitPrice,
            IsRawMaterial = ingredient.IsRawMaterial ?? true,
            MinStockLevel = ingredient.MinStockLevel ?? 0m,
            CreatedAt = ingredient.CreatedAt,
            AvailableQuantity = ingredient.Batches?.Sum(b => b.RemainingQuantity) ?? 0m,
            BatchCount = ingredient.Batches?.Count ?? 0,
            LatestExpiryDate = ingredient.Batches == null || ingredient.Batches.Count == 0
                ? null
                : ingredient.Batches.OrderBy(b => b.ExpiryDate).Last().ExpiryDate,
            LatestBatchCode = ingredient.Batches == null || ingredient.Batches.Count == 0
                ? null
                : ingredient.Batches.OrderBy(b => b.CreatedAt).Last().BatchCode,
            HasRecipe = ingredient.Recipe != null,
            RecipeDescription = ingredient.Recipe?.Description,
            RecipeInputs = ingredient.Recipe?.RecipeDetails
                .OrderBy(rd => rd.InputIngredient.Name)
                .Select(rd => new RecipeInputDto
                {
                    InputIngredientId = rd.InputIngredientId,
                    InputIngredientName = rd.InputIngredient.Name,
                    Unit = rd.InputIngredient.Unit,
                    IsRawMaterial = rd.InputIngredient.IsRawMaterial ?? true,
                    QuantityRequired = rd.QuantityRequired
                })
                .ToList() ?? new List<RecipeInputDto>(),
            Batches = batches
        };
    }

    private static BatchResponseDto MapBatch(Batch batch)
    {
        return new BatchResponseDto
        {
            BatchId = batch.BatchId,
            BatchCode = batch.BatchCode,
            IngredientId = batch.IngredientId,
            IngredientName = batch.Ingredient?.Name ?? string.Empty,
            Quantity = batch.Quantity,
            RemainingQuantity = batch.RemainingQuantity,
            ManufactureDate = batch.ManufactureDate,
            ExpiryDate = batch.ExpiryDate,
            KitchenId = batch.KitchenId,
            KitchenName = batch.Kitchen?.KitchenName ?? string.Empty,
            CreatedAt = batch.CreatedAt,
            IsExpired = batch.ExpiryDate < DateOnly.FromDateTime(DateTime.UtcNow)
        };
    }

    public async Task<IngredientSummaryDto> CreateIngredientAsync(CreateIngredientDto dto)
    {
        var ingredient = new Ingredient
        {
            Name = dto.Name,
            Sku = dto.Sku,
            Unit = dto.Unit,
            UnitPrice = dto.UnitPrice,
            IsRawMaterial = dto.IsRawMaterial,
            MinStockLevel = dto.MinStockLevel,
            CreatedAt = DateTime.UtcNow
        };
        var created = await _ingredientRepository.AddAsync(ingredient);
        return MapIngredientSummary(created);
    }

    public async Task<IngredientSummaryDto?> UpdateIngredientAsync(int ingredientId, UpdateIngredientDto dto)
    {
        var ingredient = await _ingredientRepository.GetByIdAsync(ingredientId);
        if (ingredient == null) return null;

        if (dto.Name != null) ingredient.Name = dto.Name;
        if (dto.Sku != null) ingredient.Sku = dto.Sku;
        if (dto.Unit != null) ingredient.Unit = dto.Unit;
        if (dto.UnitPrice.HasValue) ingredient.UnitPrice = dto.UnitPrice.Value;
        if (dto.IsRawMaterial.HasValue) ingredient.IsRawMaterial = dto.IsRawMaterial.Value;
        if (dto.MinStockLevel.HasValue) ingredient.MinStockLevel = dto.MinStockLevel.Value;

        var updated = await _ingredientRepository.UpdateAsync(ingredient);
        return MapIngredientSummary(updated);
    }

    public async Task<bool> DeleteIngredientAsync(int ingredientId)
    {
        return await _ingredientRepository.DeleteAsync(ingredientId);
    }

    public async Task<List<RecipeResponseDto>> GetRecipesAsync(int? outputIngredientId = null)
    {
        var recipes = await _recipeRepository.GetAllAsync();
        if (outputIngredientId.HasValue)
        {
            recipes = recipes.Where(r => r.OutputIngredientId == outputIngredientId.Value).ToList();
        }
        return recipes.Select(MapRecipeResponse).ToList();
    }

    public async Task<RecipeResponseDto?> GetRecipeByIdAsync(int recipeId)
    {
        var recipe = await _recipeRepository.GetByIdAsync(recipeId);
        if (recipe == null) return null;
        return MapRecipeResponse(recipe);
    }

    public async Task<RecipeResponseDto> CreateRecipeAsync(int userId, CreateRecipeDto dto)
    {
        var recipe = new Recipe
        {
            OutputIngredientId = dto.OutputIngredientId,
            Description = dto.Description,
            CreatedBy = userId,
            RecipeDetails = dto.Details.Select(d => new RecipeDetail
            {
                InputIngredientId = d.InputIngredientId,
                QuantityRequired = d.QuantityRequired
            }).ToList()
        };
        var created = await _recipeRepository.AddAsync(recipe);
        return MapRecipeResponse(await _recipeRepository.GetByIdAsync(created.RecipeId) ?? created);
    }

    public async Task<RecipeResponseDto?> UpdateRecipeAsync(int recipeId, UpdateRecipeDto dto)
    {
        var recipe = await _recipeRepository.GetByIdAsync(recipeId);
        if (recipe == null) return null;

        recipe.Description = dto.Description;
        
        recipe.RecipeDetails.Clear();
        foreach(var detail in dto.Details) {
            recipe.RecipeDetails.Add(new RecipeDetail {
                RecipeId = recipeId,
                InputIngredientId = detail.InputIngredientId,
                QuantityRequired = detail.QuantityRequired
            });
        }

        var updated = await _recipeRepository.UpdateAsync(recipe);
        return MapRecipeResponse(await _recipeRepository.GetByIdAsync(updated.RecipeId) ?? updated);
    }

    public async Task<bool> DeleteRecipeAsync(int recipeId)
    {
        return await _recipeRepository.DeleteAsync(recipeId);
    }

    private static RecipeResponseDto MapRecipeResponse(Recipe recipe)
    {
        return new RecipeResponseDto
        {
            RecipeId = recipe.RecipeId,
            OutputIngredientId = recipe.OutputIngredientId,
            OutputIngredientName = recipe.OutputIngredient?.Name ?? "N/A",
            Description = recipe.Description,
            CreatedByName = recipe.CreatedByNavigation?.FullName,
            Details = recipe.RecipeDetails.Select(rd => new RecipeInputDto
            {
                InputIngredientId = rd.InputIngredientId,
                InputIngredientName = rd.InputIngredient?.Name ?? "N/A",
                Unit = rd.InputIngredient?.Unit ?? "N/A",
                IsRawMaterial = rd.InputIngredient?.IsRawMaterial ?? true,
                QuantityRequired = rd.QuantityRequired
            }).ToList()
        };
    }

    private async Task ValidateIngredientExistsAsync(int ingredientId)
    {
        var ingredient = await _ingredientRepository.GetByIdAsync(ingredientId);
        if (ingredient == null)
            throw new InvalidOperationException("Không tìm thấy nguyên liệu.");
    }

    private async Task ValidateKitchenExistsAsync(int kitchenId)
    {
        var kitchen = await _kitchenRepository.GetByIdAsync(kitchenId);
        if (kitchen == null)
            throw new InvalidOperationException("Không tìm thấy bếp trung tâm.");
    }

    private static void ValidateBatchQuantities(decimal quantity, decimal remainingQuantity)
    {
        if (quantity <= 0)
            throw new InvalidOperationException("Số lượng lô phải lớn hơn 0.");

        if (remainingQuantity < 0)
            throw new InvalidOperationException("Số lượng còn lại không hợp lệ.");

        if (remainingQuantity > quantity)
            throw new InvalidOperationException("Số lượng còn lại không được lớn hơn tổng số lượng lô.");
    }

    public async Task<BatchResponseDto> ExecuteProductionAsync(ExecuteProductionDto dto)
    {
        await ValidateIngredientExistsAsync(dto.OutputIngredientId);
        await ValidateKitchenExistsAsync(dto.KitchenId);

        var planRequest = new ProductionPlanRequestDto
        {
            OutputIngredientId = dto.OutputIngredientId,
            RequestedQuantity = dto.RequestedQuantity
        };

        var plan = await BuildProductionPlanAsync(planRequest);

        if (plan.Materials.Any(m => m.ShortageQuantity > 0))
        {
            throw new InvalidOperationException("Không đủ nguyên liệu thô để sản xuất. Vui lòng nhập thêm kho.");
        }

        var allBatches = await _batchRepository.GetAllAsync();

        // Deduct raw materials using FIFO
        foreach (var material in plan.Materials)
        {
            var batchesToDeduct = allBatches
                .Where(b => b.IngredientId == material.IngredientId && b.KitchenId == dto.KitchenId)
                .Where(b => b.RemainingQuantity > 0 && b.ExpiryDate >= DateOnly.FromDateTime(DateTime.UtcNow))
                .OrderBy(b => b.ExpiryDate)
                .ToList();

            decimal remainingToDeduct = material.RequiredQuantity;

            foreach (var batch in batchesToDeduct)
            {
                if (remainingToDeduct <= 0) break;

                if (batch.RemainingQuantity >= remainingToDeduct)
                {
                    batch.RemainingQuantity -= remainingToDeduct;
                    remainingToDeduct = 0;
                }
                else
                {
                    remainingToDeduct -= batch.RemainingQuantity;
                    batch.RemainingQuantity = 0;
                }
                await _batchRepository.UpdateAsync(batch);
            }

            if (remainingToDeduct > 0)
            {
                throw new InvalidOperationException($"Lỗi đồng bộ: Không đủ lô nguyên liệu cho {material.IngredientName}.");
            }
        }

        // Create new batch for the output ingredient
        var newBatch = new Batch
        {
            BatchCode = dto.BatchCode,
            IngredientId = dto.OutputIngredientId,
            Quantity = dto.RequestedQuantity,
            RemainingQuantity = dto.RequestedQuantity,
            ManufactureDate = DateOnly.FromDateTime(DateTime.UtcNow),
            ExpiryDate = dto.ExpiryDate,
            KitchenId = dto.KitchenId,
            CreatedAt = DateTime.UtcNow
        };

        try
        {
            var created = await _batchRepository.AddAsync(newBatch);
            var createdWithIncludes = await _batchRepository.GetByIdAsync(created.BatchId) ?? created;
            return MapBatch(createdWithIncludes);
        }
        catch (DbUpdateException ex)
        {
            throw new InvalidOperationException("Mã lô thành phẩm đã tồn tại hoặc có lỗi dữ liệu. Vui lòng thử lại với mã lô khác.", ex);
        }
    }
}

