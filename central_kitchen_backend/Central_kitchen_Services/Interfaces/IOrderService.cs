using System.Collections.Generic;
using System.Threading.Tasks;
using Central_kitchen_Services.DTOs.Order;

namespace Central_kitchen_Services.Interfaces;

/// <summary>
/// Interface định nghĩa các nghiệp vụ xử lý đơn hàng và tiêu thụ kho
/// cho module Franchise (Cửa hàng nhượng quyền).
/// </summary>
public interface IOrderService
{
    // ==================== TASK API_01 ====================
    /// <summary>
    /// Tiếp nhận đơn đặt hàng nguyên liệu từ cửa hàng franchise.
    /// Tự động kiểm tra hạn mức công nợ trước khi lưu đơn.
    /// </summary>
    /// <param name="dto">Thông tin đơn hàng và danh sách nguyên liệu.</param>
    /// <param name="createdByUserId">ID người dùng đang đăng nhập (lấy từ JWT claim).</param>
    Task<PlaceOrderResponseDto> PlaceOrderAsync(CreateOrderDto dto, int createdByUserId);

    // ==================== TASK API_02 ====================
    /// <summary>
    /// Lấy danh sách tóm tắt tất cả đơn hàng của một cửa hàng franchise.
    /// </summary>
    Task<List<OrderSummaryDto>> GetOrdersByStoreAsync(int storeId);

    /// <summary>
    /// Lấy chi tiết một đơn hàng cụ thể (bao gồm từng dòng nguyên liệu).
    /// </summary>
    Task<OrderDetailDto?> GetOrderDetailAsync(int orderId);

    // ==================== TASK API_03 ====================
    /// <summary>
    /// Cập nhật tồn kho tại cửa hàng franchise sau khi nhận hàng thành công.
    /// Cộng số lượng thực nhận vào StoreInventory và cập nhật trạng thái đơn thành "Delivered".
    /// </summary>
    Task<ReceiveOrderResponseDto> ReceiveOrderAsync(int orderId, ReceiveOrderDto dto);

    // ==================== TASK API_04 ====================
    /// <summary>
    /// Ghi nhận lượng tiêu thụ (bán/hao hụt/hủy) cuối ngày tại cửa hàng.
    /// Tự động trừ số lượng tương ứng khỏi StoreInventory.
    /// </summary>
    Task<ConsumeInventoryResponseDto> ConsumeInventoryAsync(ConsumeInventoryDto dto);

    /// <summary>
    /// Lấy danh sách tồn kho hiện tại của cửa hàng franchise.
    /// </summary>
    Task<List<StoreInventoryDto>> GetStoreInventoryAsync(int storeId);

    // ==================== BỔ SUNG: HỦY / DUYỆT / TỪ CHỐI ====================

    /// <summary>
    /// Cửa hàng franchise hủy một đơn hàng đang ở trạng thái Pending.
    /// Tự động hoàn lại CurrentDebt tương ứng với tổng tiền đơn hàng bị hủy.
    /// </summary>
    Task<OrderStatusActionResponseDto> CancelOrderAsync(int orderId, int requestUserId, CancelOrderDto dto);

    /// <summary>
    /// Manager/Admin duyệt một đơn hàng Pending → chuyển sang Approved.
    /// Gửi notification cho cửa hàng franchise.
    /// </summary>
    Task<OrderStatusActionResponseDto> ApproveOrderAsync(int orderId, int approvedByUserId, OrderStatusActionDto dto);

    /// <summary>
    /// Bếp trung tâm xuất kho một đơn hàng Approved → chuyển sang Delivering.
    /// Tự động trừ Batches tại bếp trung tâm theo FIFO.
    /// </summary>
    Task<OrderStatusActionResponseDto> DispatchOrderAsync(int orderId, int dispatchedByUserId);

    /// <summary>
    /// Manager/Admin từ chối một đơn hàng Pending → chuyển sang Cancelled.
    /// Hoàn lại CurrentDebt và gửi notification cho cửa hàng franchise.
    /// </summary>
    Task<OrderStatusActionResponseDto> RejectOrderAsync(int orderId, int rejectedByUserId, OrderStatusActionDto dto);

    // ==================== BỔ SUNG: KITCHEN ORDERS ====================

    /// <summary>
    /// Lấy danh sách TẤT CẢ đơn hàng gửi đến một bếp trung tâm.
    /// Dùng cho màn hình quản lý của Manager / Kitchen Staff.
    /// </summary>
    Task<List<OrderSummaryDto>> GetOrdersByKitchenAsync(int kitchenId, string? statusFilter = null);

    // ==================== BỔ SUNG: CREDIT INFO ====================

    /// <summary>
    /// Lấy thông tin công nợ và hạn mức tín dụng của cửa hàng franchise.
    /// Trả về AvailableCredit, UsagePercent, CanPlaceOrder để hiển thị lên UI trước khi đặt hàng.
    /// </summary>
    Task<StoreCreditInfoDto> GetStoreCreditInfoAsync(int storeId);
}
