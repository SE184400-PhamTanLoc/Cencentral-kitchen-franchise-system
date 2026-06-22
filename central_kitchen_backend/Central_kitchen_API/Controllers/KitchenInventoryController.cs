using Central_kitchen_Services.DTOs.Inventory;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/kitchen")]
[Authorize(Roles = "ADMIN,MANAGER,KITCHEN_STAFF,SUPPLY_COORDINATOR")]
public class KitchenInventoryController : ControllerBase
{
    private readonly IInventoryService _inventoryService;

    public KitchenInventoryController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    [HttpGet("batches")]
    public async Task<IActionResult> GetBatches([FromQuery] int? ingredientId = null, [FromQuery] int? kitchenId = null)
    {
        var batches = await _inventoryService.GetBatchesAsync(ingredientId, kitchenId);
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách lô sản xuất thành công.",
            data = batches
        });
    }

    [HttpGet("batches/{id:int}")]
    public async Task<IActionResult> GetBatchById(int id)
    {
        var batch = await _inventoryService.GetBatchByIdAsync(id);
        if (batch == null)
            return NotFound(new { success = false, message = "Không tìm thấy lô sản xuất." });

        return Ok(new
        {
            success = true,
            message = "Lấy chi tiết lô sản xuất thành công.",
            data = batch
        });
    }

    [HttpPost("batches")]
    public async Task<IActionResult> CreateBatch([FromBody] CreateBatchDto dto)
    {
        try
        {
            var batch = await _inventoryService.CreateBatchAsync(dto);
            return CreatedAtAction(nameof(GetBatchById), new { id = batch.BatchId }, new
            {
                success = true,
                message = "Tạo lô sản xuất thành công.",
                data = batch
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    [HttpPut("batches/{id:int}")]
    public async Task<IActionResult> UpdateBatch(int id, [FromBody] UpdateBatchDto dto)
    {
        try
        {
            var batch = await _inventoryService.UpdateBatchAsync(id, dto);
            if (batch == null)
                return NotFound(new { success = false, message = "Không tìm thấy lô sản xuất." });

            return Ok(new
            {
                success = true,
                message = "Cập nhật lô sản xuất thành công.",
                data = batch
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    [HttpDelete("batches/{id:int}")]
    public async Task<IActionResult> DeleteBatch(int id)
    {
        var result = await _inventoryService.DeleteBatchAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy lô sản xuất." });

        return Ok(new
        {
            success = true,
            message = "Xóa lô sản xuất thành công."
        });
    }

    [HttpPost("production-plan")]
    public async Task<IActionResult> BuildProductionPlan([FromBody] ProductionPlanRequestDto dto)
    {
        try
        {
            var kitchenIdClaim = User.FindFirst("KitchenId")?.Value;
            int? kitchenId = int.TryParse(kitchenIdClaim, out var kid) ? kid : null;

            var plan = await _inventoryService.BuildProductionPlanAsync(dto, kitchenId);
            return Ok(new
            {
                success = true,
                message = "Tính toán BOM thành công.",
                data = plan
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }
    [HttpGet("orders/pending")]
    public async Task<IActionResult> GetPendingOrders([FromQuery] int kitchenId)
    {
        var orders = await _inventoryService.GetPendingOrdersAsync(kitchenId);
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách đơn hàng chờ thành công.",
            data = orders
        });
    }

    [HttpPost("production-plan/auto")]
    public async Task<IActionResult> BuildAutoProductionPlan([FromQuery] int kitchenId)
    {
        try
        {
            var plan = await _inventoryService.BuildAutoProductionPlanAsync(kitchenId);
            return Ok(new
            {
                success = true,
                message = "Tự động tính toán BOM từ các đơn hàng chờ thành công.",
                data = plan
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    [HttpPost("production-plan/execute")]
    public async Task<IActionResult> ExecuteProduction([FromBody] ExecuteProductionDto dto)
    {
        try
        {
            var batch = await _inventoryService.ExecuteProductionAsync(dto);
            return Ok(new
            {
                success = true,
                message = "Thực thi sản xuất thành công. Đã tạo lô thành phẩm mới và trừ nguyên liệu thô tương ứng.",
                data = batch
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }
}
