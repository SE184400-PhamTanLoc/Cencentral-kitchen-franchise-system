using Central_kitchen_Services.DTOs.Inventory;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/recipes")]
[Authorize]
public class RecipesController : ControllerBase
{
    private readonly IInventoryService _inventoryService;

    public RecipesController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int? outputIngredientId = null)
    {
        var recipes = await _inventoryService.GetRecipesAsync(outputIngredientId);
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách cấu hình BOM thành công.",
            data = recipes
        });
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var recipe = await _inventoryService.GetRecipeByIdAsync(id);
        if (recipe == null)
            return NotFound(new { success = false, message = "Không tìm thấy cấu hình BOM." });

        return Ok(new
        {
            success = true,
            message = "Lấy chi tiết cấu hình BOM thành công.",
            data = recipe
        });
    }

    [HttpPost]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Create([FromBody] CreateRecipeDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!int.TryParse(userIdString, out int userId))
        {
            return Unauthorized(new { success = false, message = "Không xác định được danh tính người dùng." });
        }

        var created = await _inventoryService.CreateRecipeAsync(userId, dto);
        return CreatedAtAction(nameof(GetById), new { id = created.RecipeId }, new
        {
            success = true,
            message = "Tạo cấu hình BOM thành công.",
            data = created
        });
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateRecipeDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var updated = await _inventoryService.UpdateRecipeAsync(id, dto);
        if (updated == null)
            return NotFound(new { success = false, message = "Không tìm thấy cấu hình BOM để cập nhật." });

        return Ok(new
        {
            success = true,
            message = "Cập nhật cấu hình BOM thành công.",
            data = updated
        });
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "MANAGER,ADMIN")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _inventoryService.DeleteRecipeAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy cấu hình BOM để xóa." });

        return Ok(new { success = true, message = "Xóa cấu hình BOM thành công." });
    }
}
