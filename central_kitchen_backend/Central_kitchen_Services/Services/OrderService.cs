using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Order;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

/// <summary>
/// Triển khai đầy đủ nghiệp vụ đơn hàng franchise:
///   - THAI_API_01: Đặt hàng với kiểm tra công nợ
///   - THAI_API_02: Lấy danh sách / chi tiết đơn theo cửa hàng
///   - THAI_API_03: Nhận hàng + cập nhật tồn kho
///   - THAI_API_04: Ghi nhận tiêu thụ / hao hụt
/// </summary>
public class OrderService : IOrderService
{
    private readonly IOrderRepository _orderRepository;
    private readonly IIngredientRepository _ingredientRepository;
    private readonly INotificationService _notificationService;
    private readonly IBatchRepository _batchRepository;

    public OrderService(
        IOrderRepository orderRepository,
        IIngredientRepository ingredientRepository,
        INotificationService notificationService,
        IBatchRepository batchRepository)
    {
        _orderRepository = orderRepository;
        _ingredientRepository = ingredientRepository;
        _notificationService = notificationService;
        _batchRepository = batchRepository;
    }

    // ==================== TASK THAI_API_01 ====================

    public async Task<PlaceOrderResponseDto> PlaceOrderAsync(CreateOrderDto dto, int createdByUserId)
    {
        // 1. Lấy thông tin cửa hàng để kiểm tra hạn mức công nợ
        var store = await _orderRepository.GetStoreByIdAsync(dto.StoreId)
            ?? throw new InvalidOperationException($"Không tìm thấy cửa hàng ID={dto.StoreId}.");

        if (store.IsActive != true)
            throw new InvalidOperationException("Cửa hàng đã bị vô hiệu hóa, không thể đặt hàng.");

        // 2. Validate và tính tổng tiền đơn hàng
        if (dto.Items == null || dto.Items.Count == 0)
            throw new InvalidOperationException("Đơn hàng phải có ít nhất 1 nguyên liệu.");

        // Kiểm tra tất cả ingredient tồn tại
        foreach (var item in dto.Items)
        {
            var ingredient = await _ingredientRepository.GetByIdAsync(item.IngredientId)
                ?? throw new InvalidOperationException($"Không tìm thấy nguyên liệu ID={item.IngredientId}.");
        }

        var subtotal = dto.Items.Sum(i => i.QuantityOrdered * i.UnitPrice);
        var taxAmount = subtotal * 0.10m; // VAT 10%
        var shippingFee = subtotal >= 500000m ? 0m : 30000m; // Phí ship 30k, miễn ship nếu >= 500k
        var totalAmount = subtotal + taxAmount + shippingFee;

        // 3. Kiểm tra hạn mức công nợ
        var creditLimit = store.CreditLimit ?? 0;
        var currentDebt = store.CurrentDebt ?? 0;
        var newDebt = currentDebt + totalAmount;

        if (creditLimit > 0 && newDebt > creditLimit)
        {
            throw new InvalidOperationException(
                $"Vượt hạn mức công nợ! Hạn mức: {creditLimit:N0} VNĐ, " +
                $"Dư nợ hiện tại: {currentDebt:N0} VNĐ, " +
                $"Đơn hàng này: {totalAmount:N0} VNĐ. " +
                $"Tổng dư nợ nếu đặt: {newDebt:N0} VNĐ.");
        }

        // 4. Tạo mã đơn hàng tự động (ORD-YYYYMMDD-XXXX)
        var orderCode = $"ORD-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString("N")[..6].ToUpper()}";

        // 5. Xây dựng entity Order
        var order = new Order
        {
            OrderCode = orderCode,
            StoreId = dto.StoreId,
            KitchenId = dto.KitchenId,
            TotalAmount = totalAmount,
            OrderStatus = "PENDING",
            Notes = dto.Notes,
            CreatedBy = createdByUserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            OrderDetails = dto.Items.Select(item => new OrderDetail
            {
                IngredientId = item.IngredientId,
                QuantityOrdered = item.QuantityOrdered,
                QuantityDelivered = 0,
                UnitPrice = item.UnitPrice
            }).ToList()
        };

        // 6. Lưu đơn vào Database
        var created = await _orderRepository.CreateOrderAsync(order);

        // 7. Cập nhật CurrentDebt của cửa hàng
        await _orderRepository.UpdateStoreDebtAsync(dto.StoreId, totalAmount);

        // 7. Gửi notification cho Kitchen Staff của bếp trung tâm
        try
        {
            var kitchenStaffIds = await _orderRepository.GetKitchenStaffUserIdsByKitchenAsync(dto.KitchenId);
            if (kitchenStaffIds.Any())
            {
                await _notificationService.PushToUsersAsync(
                    kitchenStaffIds,
                    title: "📦 Đơn hàng mới",
                    message: $"Cửa hàng '{store.StoreName}' vừa đặt đơn {created.OrderCode} " +
                             $"trị giá {created.TotalAmount:N0} VNĐ. Vui lòng xem xét và duyệt đơn."
                );
            }
        }
        catch { /* Không để lỗi notification làm fail toàn bộ luồng đặt hàng */ }

        return new PlaceOrderResponseDto
        {
            OrderId = created.OrderId,
            OrderCode = created.OrderCode,
            OrderStatus = created.OrderStatus,
            TotalAmount = created.TotalAmount,
            CreatedAt = created.CreatedAt,
            Message = $"Đơn hàng {created.OrderCode} đã được ghi nhận thành công. Trạng thái: Chờ duyệt."
        };
    }

    // ==================== TASK THAI_API_02 ====================

    public async Task<List<OrderSummaryDto>> GetOrdersByStoreAsync(int storeId)
    {
        var orders = await _orderRepository.GetOrdersByStoreAsync(storeId);
        return orders.Select(MapToSummary).ToList();
    }

    public async Task<OrderDetailDto?> GetOrderDetailAsync(int orderId)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId);
        if (order == null) return null;
        return MapToDetail(order);
    }

    // ==================== TASK THAI_API_03 ====================

    public async Task<ReceiveOrderResponseDto> ReceiveOrderAsync(int orderId, ReceiveOrderDto dto)
    {
        // 1. Lấy đơn hàng và kiểm tra tồn tại
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        var currentStatus = order.OrderStatus?.ToUpper() ?? "";
        if (currentStatus == "DELIVERED")
            throw new InvalidOperationException("Đơn hàng này đã được xác nhận nhận hàng trước đó.");

        if (currentStatus == "CANCELLED" || currentStatus == "REJECTED")
            throw new InvalidOperationException("Không thể xác nhận đơn hàng đã bị hủy hoặc từ chối.");

        if (currentStatus == "PENDING")
            throw new InvalidOperationException("Đơn hàng chưa được duyệt. Vui lòng đợi Manager xác nhận trước khi nhận hàng.");

        if (currentStatus != "APPROVED" && currentStatus != "DELIVERING" && currentStatus != "SHIPPED")
            throw new InvalidOperationException($"Không thể nhận hàng khi đơn ở trạng thái '{order.OrderStatus}'.");

        // 2. Xác định số lượng thực nhận từng nguyên liệu
        // Nếu không truyền danh sách → dùng QuantityOrdered từ đơn hàng gốc
        var receivedMap = dto.ReceivedItems?
            .ToDictionary(r => r.IngredientId, r => r.QuantityDelivered)
            ?? new Dictionary<int, decimal>();

        var inventoryResults = new List<InventoryUpdateResultDto>();

        // 3. Cập nhật tồn kho từng nguyên liệu
        foreach (var detail in order.OrderDetails)
        {
            var quantityToAdd = receivedMap.TryGetValue(detail.IngredientId, out var qty)
                ? qty
                : detail.QuantityOrdered;

            if (quantityToAdd <= 0) continue;

            await _orderRepository.UpsertStoreInventoryAsync(
                order.StoreId, detail.IngredientId, quantityToAdd);

            // Đọc lại tồn kho mới để trả về trong response
            var updatedInventory = await _orderRepository.GetStoreInventoryAsync(order.StoreId);
            var newRecord = updatedInventory
                .FirstOrDefault(si => si.IngredientId == detail.IngredientId);

            inventoryResults.Add(new InventoryUpdateResultDto
            {
                IngredientId = detail.IngredientId,
                IngredientName = detail.Ingredient?.Name ?? string.Empty,
                Unit = detail.Ingredient?.Unit ?? string.Empty,
                QuantityAdded = quantityToAdd,
                NewStockQuantity = newRecord?.StockQuantity ?? quantityToAdd,
                LastUpdated = newRecord?.LastUpdated ?? DateTime.UtcNow
            });
        }

        // 4. Cập nhật trạng thái đơn hàng thành "DELIVERED"
        await _orderRepository.UpdateOrderStatusAsync(order.OrderId, "DELIVERED");

        return new ReceiveOrderResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            NewStatus = "DELIVERED",
            InventoryUpdates = inventoryResults
        };
    }

    // ==================== TASK THAI_API_04 ====================

    public async Task<ConsumeInventoryResponseDto> ConsumeInventoryAsync(ConsumeInventoryDto dto)
    {
        // 1. Kiểm tra cửa hàng tồn tại
        var store = await _orderRepository.GetStoreByIdAsync(dto.StoreId)
            ?? throw new InvalidOperationException($"Không tìm thấy cửa hàng ID={dto.StoreId}.");

        // 2. Validate WASTE/DISCARD phải có lý do
        if (dto.ConsumeType != "SOLD" && string.IsNullOrWhiteSpace(dto.Reason))
            throw new InvalidOperationException(
                $"Trường 'Reason' bắt buộc phải có khi ghi nhận '{dto.ConsumeType}'.");

        var results = new List<ConsumeResultItemDto>();
        var consumedAt = dto.ConsumeDate ?? DateTime.UtcNow;

        // 3. Trừ kho từng nguyên liệu
        foreach (var item in dto.Items)
        {
            // Lấy tên nguyên liệu để đưa vào response
            var ingredient = await _ingredientRepository.GetByIdAsync(item.IngredientId);

            // Thực hiện trừ kho (ném exception nếu không đủ tồn kho)
            await _orderRepository.ConsumeStoreInventoryAsync(dto.StoreId, item.IngredientId, item.Quantity);

            // Đọc lại tồn kho sau khi trừ
            var updatedInventory = await _orderRepository.GetStoreInventoryAsync(dto.StoreId);
            var remaining = updatedInventory
                .FirstOrDefault(si => si.IngredientId == item.IngredientId)?.StockQuantity ?? 0;

            results.Add(new ConsumeResultItemDto
            {
                IngredientId = item.IngredientId,
                IngredientName = ingredient?.Name ?? $"ID={item.IngredientId}",
                Unit = ingredient?.Unit ?? string.Empty,
                QuantityConsumed = item.Quantity,
                RemainingStock = remaining
            });
        }

        return new ConsumeInventoryResponseDto
        {
            StoreId = dto.StoreId,
            ConsumeType = dto.ConsumeType,
            ConsumedAt = consumedAt,
            TotalItemsProcessed = results.Count,
            Results = results
        };
    }

    // ==================== EXTRA: Lấy tồn kho ====================

    public async Task<List<StoreInventoryDto>> GetStoreInventoryAsync(int storeId)
    {
        var inventories = await _orderRepository.GetStoreInventoryAsync(storeId);
        return inventories.Select(si => new StoreInventoryDto
        {
            StoreInventoryId = si.StoreInventoryId,
            StoreId = si.StoreId,
            IngredientId = si.IngredientId,
            IngredientName = si.Ingredient?.Name ?? string.Empty,
            Sku = si.Ingredient?.Sku ?? string.Empty,
            Unit = si.Ingredient?.Unit ?? string.Empty,
            StockQuantity = si.StockQuantity ?? 0,
            LastUpdated = si.LastUpdated
        }).ToList();
    }

    // ==================== PRIVATE MAPPERS ====================

    private static OrderSummaryDto MapToSummary(Order o) => new()
    {
        OrderId = o.OrderId,
        OrderCode = o.OrderCode,
        StoreId = o.StoreId,
        StoreName = o.Store?.StoreName ?? string.Empty,
        KitchenId = o.KitchenId,
        KitchenName = o.Kitchen?.KitchenName ?? string.Empty,
        TotalAmount = o.TotalAmount,
        OrderStatus = o.OrderStatus,
        Notes = o.Notes,
        ItemCount = o.OrderDetails?.Count ?? 0,
        CreatedByName = o.CreatedByNavigation?.FullName ?? string.Empty,
        CreatedAt = o.CreatedAt,
        UpdatedAt = o.UpdatedAt
    };

    private static OrderDetailDto MapToDetail(Order o) => new()
    {
        OrderId = o.OrderId,
        OrderCode = o.OrderCode,
        StoreId = o.StoreId,
        StoreName = o.Store?.StoreName ?? string.Empty,
        KitchenId = o.KitchenId,
        KitchenName = o.Kitchen?.KitchenName ?? string.Empty,
        TotalAmount = o.TotalAmount,
        OrderStatus = o.OrderStatus,
        Notes = o.Notes,
        ItemCount = o.OrderDetails?.Count ?? 0,
        CreatedByName = o.CreatedByNavigation?.FullName ?? string.Empty,
        CreatedAt = o.CreatedAt,
        UpdatedAt = o.UpdatedAt,
        Items = o.OrderDetails?.Select(od => new OrderDetailItemDto
        {
            OrderDetailId = od.OrderDetailId,
            IngredientId = od.IngredientId,
            IngredientName = od.Ingredient?.Name ?? string.Empty,
            Unit = od.Ingredient?.Unit ?? string.Empty,
            QuantityOrdered = od.QuantityOrdered,
            QuantityDelivered = od.QuantityDelivered,
            UnitPrice = od.UnitPrice
        }).ToList() ?? new()
    };

    // ==================== BỔ SUNG: HỦY ĐƠN ====================

    public async Task<OrderStatusActionResponseDto> CancelOrderAsync(
        int orderId, int requestUserId, CancelOrderDto dto)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        // Chỉ cho hủy khi đơn đang Pending
        if (order.OrderStatus?.ToUpper() != "PENDING")
            throw new InvalidOperationException(
                $"Chỉ có thể hủy đơn hàng ở trạng thái 'Pending'. Trạng thái hiện tại: '{order.OrderStatus}'.");

        var previousStatus = order.OrderStatus;

        // Cập nhật trạng thái
        await _orderRepository.UpdateOrderStatusAsync(orderId, "CANCELLED");

        // Hoàn lại công nợ (trừ đi số tiền đơn đã cộng vào khi đặt)
        await _orderRepository.UpdateStoreDebtAsync(order.StoreId, -order.TotalAmount);

        // Gửi notification cho Kitchen Staff
        try
        {
            var kitchenStaffIds = await _orderRepository.GetKitchenStaffUserIdsByKitchenAsync(order.KitchenId);
            if (kitchenStaffIds.Any())
            {
                await _notificationService.PushToUsersAsync(
                    kitchenStaffIds,
                    title: "❌ Đơn hàng bị hủy",
                    message: $"Đơn hàng {order.OrderCode} đã bị cửa hàng hủy. Lý do: {dto.Reason}"
                );
            }
        }
        catch { }

        return new OrderStatusActionResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PreviousStatus = previousStatus,
            NewStatus = "CANCELLED",
            DebtReversed = order.TotalAmount,
            Message = $"Đơn hàng {order.OrderCode} đã được hủy. Hạn mức công nợ hoàn lại: {order.TotalAmount:N0} VNĐ."
        };
    }

    // ==================== BỔ SUNG: DUYỆT ĐƠN ====================

    public async Task<OrderStatusActionResponseDto> ApproveOrderAsync(
        int orderId, int approvedByUserId, OrderStatusActionDto dto)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        if (order.OrderStatus?.ToUpper() != "PENDING")
            throw new InvalidOperationException(
                $"Chỉ có thể duyệt đơn hàng ở trạng thái 'Pending'. Trạng thái hiện tại: '{order.OrderStatus}'.");

        await _orderRepository.UpdateOrderStatusAsync(orderId, "APPROVED");

        // Gửi notification cho franchise staff của cửa hàng
        try
        {
            var franchiseStaffIds = await _orderRepository.GetStaffUserIdsByStoreAsync(order.StoreId);
            if (franchiseStaffIds.Any())
            {
                var noteText = string.IsNullOrWhiteSpace(dto.Note) ? "" : $" Ghi chú: {dto.Note}";
                var deliveryText = string.IsNullOrWhiteSpace(dto.EstimatedDeliveryTime)
                    ? ""
                    : $" Dự kiến giao: {dto.EstimatedDeliveryTime}.";

                await _notificationService.PushToUsersAsync(
                    franchiseStaffIds,
                    title: "✅ Đơn hàng được duyệt",
                    message: $"Đơn hàng {order.OrderCode} của bạn đã được duyệt.{deliveryText}{noteText}"
                );
            }
        }
        catch { }

        return new OrderStatusActionResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PreviousStatus = "PENDING",
            NewStatus = "APPROVED",
            Message = $"Đơn hàng {order.OrderCode} đã được duyệt thành công."
        };
    }

    public async Task<OrderStatusActionResponseDto> DispatchOrderAsync(int orderId, int dispatchedByUserId)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        if (order.OrderStatus?.ToUpper() != "APPROVED")
            throw new InvalidOperationException(
                $"Chỉ có thể xuất kho đơn hàng ở trạng thái 'Approved'. Trạng thái hiện tại: '{order.OrderStatus}'.");

        var allBatches = await _batchRepository.GetAllAsync();

        foreach (var detail in order.OrderDetails)
        {
            var batchesToDeduct = allBatches
                .Where(b => b.IngredientId == detail.IngredientId && b.KitchenId == order.KitchenId)
                .Where(b => b.RemainingQuantity > 0 && b.ExpiryDate >= DateOnly.FromDateTime(DateTime.UtcNow))
                .OrderBy(b => b.ExpiryDate)
                .ToList();

            decimal remainingToDeduct = detail.QuantityOrdered;

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
                throw new InvalidOperationException($"Không đủ tồn kho Bếp Trung Tâm cho nguyên liệu ID={detail.IngredientId}. Thiếu: {remainingToDeduct}");
            }
        }

        await _orderRepository.UpdateOrderStatusAsync(orderId, "DELIVERING");

        try
        {
            await _notificationService.PushToUsersAsync(
                new List<int> { order.CreatedBy },
                "Đơn hàng đang giao",
                $"Đơn hàng {order.OrderCode} của bạn đã được xuất kho và đang trên đường giao đến."
            );
        }
        catch { }

        return new OrderStatusActionResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PreviousStatus = "APPROVED",
            NewStatus = "DELIVERING",
            Message = $"Đơn hàng {order.OrderCode} đã được xuất kho thành công."
        };
    }

    public async Task<OrderStatusActionResponseDto> ArriveOrderAsync(int orderId, int arrivedByUserId)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        var currentStatus = order.OrderStatus?.ToUpper() ?? "";
        if (currentStatus != "DELIVERING" && currentStatus != "SHIPPING" && currentStatus != "DISPATCHED")
            throw new InvalidOperationException(
                $"Chỉ có thể cập nhật đã giao tới nơi cho đơn hàng ở trạng thái đang giao. Trạng thái hiện tại: '{order.OrderStatus}'.");

        await _orderRepository.UpdateOrderStatusAsync(orderId, "SHIPPED");

        try
        {
            await _notificationService.PushToUsersAsync(
                new List<int> { order.CreatedBy },
                "Đơn hàng đã đến nơi",
                $"Đơn hàng {order.OrderCode} đã giao tới cửa hàng của bạn. Vui lòng xác nhận nhận hàng và kiểm kho."
            );
        }
        catch { }

        return new OrderStatusActionResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PreviousStatus = order.OrderStatus,
            NewStatus = "SHIPPED",
            Message = $"Đơn hàng {order.OrderCode} đã cập nhật trạng thái 'SHIPPED' (Giao tới nơi) thành công."
        };
    }

    // ==================== BỔ SUNG: TỪ CHỐI ĐƠN ====================

    public async Task<OrderStatusActionResponseDto> RejectOrderAsync(
        int orderId, int rejectedByUserId, OrderStatusActionDto dto)
    {
        var order = await _orderRepository.GetOrderByIdAsync(orderId)
            ?? throw new InvalidOperationException($"Không tìm thấy đơn hàng ID={orderId}.");

        if (order.OrderStatus?.ToUpper() != "PENDING")
            throw new InvalidOperationException(
                $"Chỉ có thể từ chối đơn hàng ở trạng thái 'Pending'. Trạng thái hiện tại: '{order.OrderStatus}'.");

        await _orderRepository.UpdateOrderStatusAsync(orderId, "REJECTED");

        // Hoàn lại công nợ cho cửa hàng
        await _orderRepository.UpdateStoreDebtAsync(order.StoreId, -order.TotalAmount);

        // Gửi notification cho franchise staff
        try
        {
            var franchiseStaffIds = await _orderRepository.GetStaffUserIdsByStoreAsync(order.StoreId);
            if (franchiseStaffIds.Any())
            {
                var noteText = string.IsNullOrWhiteSpace(dto.Note) ? "" : $" Lý do: {dto.Note}";
                await _notificationService.PushToUsersAsync(
                    franchiseStaffIds,
                    title: "🚫 Đơn hàng bị từ chối",
                    message: $"Đơn hàng {order.OrderCode} của bạn đã bị từ chối.{noteText} Hạn mức nợ đã hoàn lại."
                );
            }
        }
        catch { }

        return new OrderStatusActionResponseDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PreviousStatus = "PENDING",
            NewStatus = "REJECTED",
            DebtReversed = order.TotalAmount,
            Message = $"Đơn hàng {order.OrderCode} đã bị từ chối. Hạn mức công nợ hoàn lại: {order.TotalAmount:N0} VNĐ."
        };
    }

    // ==================== BỔ SUNG: KITCHEN ORDERS ====================

    public async Task<List<OrderSummaryDto>> GetOrdersByKitchenAsync(
        int kitchenId, string? statusFilter = null)
    {
        var orders = await _orderRepository.GetAllOrdersByKitchenAsync(kitchenId);

        // Lọc theo status nếu có yêu cầu
        if (!string.IsNullOrWhiteSpace(statusFilter))
            orders = orders.Where(o => o.OrderStatus?.ToUpper() == statusFilter.ToUpper()).ToList();

        return orders.Select(MapToSummary).ToList();
    }

    // ==================== BỔ SUNG: CREDIT INFO ====================

    public async Task<StoreCreditInfoDto> GetStoreCreditInfoAsync(int storeId)
    {
        var store = await _orderRepository.GetStoreByIdAsync(storeId)
            ?? throw new InvalidOperationException($"Không tìm thấy cửa hàng ID={storeId}.");

        var allOrders = await _orderRepository.GetOrdersByStoreAsync(storeId);
        var pendingCount = allOrders.Count(o => o.OrderStatus?.ToUpper() == "PENDING");
        var activeCount = allOrders.Count(o => o.OrderStatus?.ToUpper() == "APPROVED" || o.OrderStatus?.ToUpper() == "DELIVERING" || o.OrderStatus?.ToUpper() == "SHIPPED");

        return new StoreCreditInfoDto
        {
            StoreId = store.StoreId,
            StoreName = store.StoreName,
            CreditLimit = store.CreditLimit ?? 0,
            CurrentDebt = store.CurrentDebt ?? 0,
            PendingOrderCount = pendingCount,
            ActiveOrderCount = activeCount
        };
    }

    // ==================== PRIVATE MAPPERS ====================

}
