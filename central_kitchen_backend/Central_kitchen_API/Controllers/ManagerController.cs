using System.Threading.Tasks;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[Route("api/manager")]
[ApiController]
[Authorize(Roles = "MANAGER,ADMIN")]
public class ManagerController : ControllerBase
{
    private readonly IManagerService _managerService;

    public ManagerController(IManagerService managerService)
    {
        _managerService = managerService;
    }

    [HttpGet("dashboard/stats")]
    public async Task<IActionResult> GetDashboardStats()
    {
        var stats = await _managerService.GetDashboardStatsAsync();
        return Ok(stats);
    }

    [HttpGet("orders/pending")]
    public async Task<IActionResult> GetPendingOrders()
    {
        var orders = await _managerService.GetPendingOrdersAsync();
        return Ok(orders);
    }

    [HttpGet("inventory")]
    public async Task<IActionResult> GetChainInventory()
    {
        var inv = await _managerService.GetChainInventoryAsync();
        return Ok(inv);
    }

    [HttpGet("analytics")]
    public async Task<IActionResult> GetAnalytics([FromQuery] int days = 7)
    {
        var analytics = await _managerService.GetAnalyticsAsync(days);
        return Ok(analytics);
    }

    [HttpGet("stores")]
    public async Task<IActionResult> GetStores()
    {
        var stores = await _managerService.GetStoresAsync();
        return Ok(stores);
    }

    [HttpPut("stores/{storeId}/credit-limit")]
    public async Task<IActionResult> UpdateStoreCreditLimit(int storeId, [FromBody] Central_kitchen_Services.DTOs.Manager.UpdateCreditLimitDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var success = await _managerService.UpdateStoreCreditLimitAsync(storeId, dto.CreditLimit);
        if (!success) return NotFound(new { message = "Store not found" });

        return Ok(new { message = "Credit limit updated successfully" });
    }
}
