using Central_kitchen_Services.DTOs.Inventory;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/ingredients")]
[Authorize]
public class IngredientsController : ControllerBase
{
    private readonly IInventoryService _inventoryService;

    public IngredientsController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool? isRawMaterial = null, [FromQuery] string? keyword = null)
    {
        var ingredients = await _inventoryService.GetIngredientsAsync(isRawMaterial, keyword);
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách nguyên liệu thành công.",
            data = ingredients
        });
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var ingredient = await _inventoryService.GetIngredientByIdAsync(id);
        if (ingredient == null)
            return NotFound(new { success = false, message = "Không tìm thấy nguyên liệu." });

        return Ok(new
        {
            success = true,
            message = "Lấy chi tiết nguyên liệu thành công.",
            data = ingredient
        });
    }

    [HttpPost]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Create([FromBody] CreateIngredientDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        
        var created = await _inventoryService.CreateIngredientAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.IngredientId }, new
        {
            success = true,
            message = "Tạo nguyên liệu thành công.",
            data = created
        });
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateIngredientDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _inventoryService.UpdateIngredientAsync(id, dto);
        if (updated == null)
            return NotFound(new { success = false, message = "Không tìm thấy nguyên liệu để cập nhật." });

        return Ok(new
        {
            success = true,
            message = "Cập nhật nguyên liệu thành công.",
            data = updated
        });
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _inventoryService.DeleteIngredientAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy nguyên liệu để xóa." });

        return Ok(new { success = true, message = "Xóa nguyên liệu thành công." });
    }
}

