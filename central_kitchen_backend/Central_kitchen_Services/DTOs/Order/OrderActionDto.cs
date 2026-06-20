using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Order;

/// <summary>
/// DTO hủy đơn hàng.
/// Dùng cho PUT /api/franchise/orders/{orderId}/cancel
/// </summary>
public class CancelOrderDto
{
    /// <summary>Lý do hủy đơn hàng (bắt buộc).</summary>
    [Required(ErrorMessage = "Lý do hủy đơn là bắt buộc.")]
    [MinLength(5, ErrorMessage = "Lý do hủy phải có ít nhất 5 ký tự.")]
    public string Reason { get; set; } = string.Empty;
}

/// <summary>
/// DTO để Manager duyệt hoặc từ chối đơn hàng.
/// Dùng cho PUT /api/franchise/orders/{orderId}/approve
/// và      PUT /api/franchise/orders/{orderId}/reject
/// </summary>
public class OrderStatusActionDto
{
    /// <summary>Ghi chú của Manager khi duyệt/từ chối (tùy chọn).</summary>
    public string? Note { get; set; }

    /// <summary>
    /// Thời gian dự kiến giao hàng (chỉ dùng khi duyệt đơn, tùy chọn).
    /// </summary>
    public string? EstimatedDeliveryTime { get; set; }
}

/// <summary>
/// Response sau khi hủy / duyệt / từ chối đơn hàng.
/// </summary>
public class OrderStatusActionResponseDto
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public string PreviousStatus { get; set; } = string.Empty;
    public string NewStatus { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    /// <summary>Số tiền hoàn lại vào hạn mức nợ (khi hủy hoặc từ chối).</summary>
    public decimal? DebtReversed { get; set; }
}

/// <summary>
/// Thông tin công nợ và hạn mức tín dụng của cửa hàng franchise.
/// Dùng cho GET /api/franchise/store/{storeId}/credit-info
/// </summary>
public class StoreCreditInfoDto
{
    public int StoreId { get; set; }
    public string StoreName { get; set; } = string.Empty;

    /// <summary>Hạn mức tín dụng tối đa (0 = không giới hạn).</summary>
    public decimal CreditLimit { get; set; }

    /// <summary>Dư nợ hiện tại (tổng các đơn Pending + Approved chưa thanh toán).</summary>
    public decimal CurrentDebt { get; set; }

    /// <summary>Hạn mức còn lại có thể đặt hàng. Âm = đã vượt hạn mức.</summary>
    public decimal AvailableCredit => CreditLimit <= 0 ? decimal.MaxValue : CreditLimit - CurrentDebt;

    /// <summary>Phần trăm đã sử dụng hạn mức (0-100%).</summary>
    public decimal UsagePercent => CreditLimit <= 0 ? 0 : Math.Round((CurrentDebt / CreditLimit) * 100, 1);

    /// <summary>Cửa hàng có thể đặt hàng thêm không.</summary>
    public bool CanPlaceOrder => CreditLimit <= 0 || CurrentDebt < CreditLimit;

    /// <summary>Số đơn hàng đang chờ xử lý (Pending).</summary>
    public int PendingOrderCount { get; set; }

    /// <summary>Số đơn hàng đang được duyệt / vận chuyển.</summary>
    public int ActiveOrderCount { get; set; }
}
