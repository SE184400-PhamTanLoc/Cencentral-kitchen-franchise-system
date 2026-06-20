using Central_kitchen_Services.DTOs.Delivery;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/delivery")]
public class DeliveryController : ControllerBase
{
    private readonly IDeliveryService _deliveryService;

    public DeliveryController(IDeliveryService deliveryService)
    {
        _deliveryService = deliveryService;
    }

    [HttpPost("location")]
    public async Task<IActionResult> UpdateLocation([FromBody] CreateDeliveryLogDto dto)
    {
        try
        {
            var log = await _deliveryService.AddDeliveryLogAsync(dto);
            return Ok(log);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("location/{orderId:int}")]
    public async Task<IActionResult> GetLatestLocation(int orderId)
    {
        var log = await _deliveryService.GetLatestLocationByOrderIdAsync(orderId);
        if (log == null)
            return NotFound(new { message = "Không tìm thấy toạ độ GPS cho đơn hàng này." });

        return Ok(log);
    }
}
