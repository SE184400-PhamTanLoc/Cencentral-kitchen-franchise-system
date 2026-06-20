using System.Collections.Generic;
using System.Threading.Tasks;
using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IOrderRepository
{
    // ==================== KITCHEN SIDE ====================
    /// <summary>Lấy danh sách đơn hàng đang chờ xử lý theo bếp trung tâm.</summary>
    Task<List<Order>> GetPendingOrdersByKitchenAsync(int kitchenId);

    /// <summary>Lấy TẤT CẢ đơn hàng của một bếp (mọi trạng thái, để Manager xem lịch sử).</summary>
    Task<List<Order>> GetAllOrdersByKitchenAsync(int kitchenId);

    /// <summary>
    /// Lấy danh sách UserId của tất cả nhân viên thuộc một cửa hàng franchise.
    /// Dùng để gửi notification hàng loạt.
    /// </summary>
    Task<List<int>> GetStaffUserIdsByStoreAsync(int storeId);

    /// <summary>
    /// Lấy danh sách UserId của Manager và Kitchen Staff thuộc một bếp trung tâm.
    /// Dùng để gửi notification khi franchise đặt hàng.
    /// </summary>
    Task<List<int>> GetKitchenStaffUserIdsByKitchenAsync(int kitchenId);

    // ==================== FRANCHISE SIDE — ORDERS ====================
    /// <summary>Tạo đơn hàng mới từ cửa hàng franchise.</summary>
    Task<Order> CreateOrderAsync(Order order);

    /// <summary>Lấy danh sách đơn hàng theo cửa hàng (tất cả trạng thái, mới nhất trước).</summary>
    Task<List<Order>> GetOrdersByStoreAsync(int storeId);

    /// <summary>Lấy chi tiết một đơn hàng cụ thể (kèm OrderDetails + Ingredient).</summary>
    Task<Order?> GetOrderByIdAsync(int orderId);

    // ==================== FRANCHISE SIDE — INVENTORY ====================
    /// <summary>Lấy toàn bộ tồn kho hiện tại của một cửa hàng franchise.</summary>
    Task<List<StoreInventory>> GetStoreInventoryAsync(int storeId);

    /// <summary>
    /// Cập nhật (cộng thêm) số lượng tồn kho của một nguyên liệu tại cửa hàng.
    /// Nếu bản ghi chưa tồn tại, tự động tạo mới (upsert).
    /// </summary>
    Task UpsertStoreInventoryAsync(int storeId, int ingredientId, decimal quantityDelta);

    /// <summary>
    /// Ghi nhận tiêu thụ/hao hụt: trừ số lượng tồn kho theo từng nguyên liệu.
    /// Ném InvalidOperationException nếu tồn kho không đủ.
    /// </summary>
    Task ConsumeStoreInventoryAsync(int storeId, int ingredientId, decimal quantity);

    /// <summary>Cập nhật trạng thái đơn hàng.</summary>
    Task UpdateOrderStatusAsync(int orderId, string newStatus);

    // ==================== STORE ====================
    /// <summary>Lấy thông tin cửa hàng (dùng để kiểm tra hạn mức công nợ).</summary>
    Task<Store?> GetStoreByIdAsync(int storeId);

    /// <summary>Cập nhật CurrentDebt của cửa hàng sau khi đặt hàng.</summary>
    Task UpdateStoreDebtAsync(int storeId, decimal debtDelta);
}
