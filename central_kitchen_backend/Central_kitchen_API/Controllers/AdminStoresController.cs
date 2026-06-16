using Central_kitchen_Services.DTOs.Store;
using Central_kitchen_Services.DTOs.Kitchen;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/admin/stores")]
[Authorize(Roles = "ADMIN")]
public class AdminStoresController : ControllerBase
{
    private readonly IStoreService _storeService;
    private readonly ICentralKitchenService _kitchenService;

    public AdminStoresController(IStoreService storeService, ICentralKitchenService kitchenService)
    {
        _storeService = storeService;
        _kitchenService = kitchenService;
    }

    // ======================== FRANCHISE STORES ========================

    /// <summary>
    /// Lấy danh sách tất cả cửa hàng Franchise
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAllStores()
    {
        var stores = await _storeService.GetAllStoresAsync();
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách cửa hàng thành công.",
            data = stores
        });
    }

    /// <summary>
    /// Lấy thông tin chi tiết một cửa hàng Franchise theo ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetStoreById(int id)
    {
        var store = await _storeService.GetStoreByIdAsync(id);
        if (store == null)
            return NotFound(new { success = false, message = "Không tìm thấy cửa hàng." });

        return Ok(new
        {
            success = true,
            message = "Lấy thông tin cửa hàng thành công.",
            data = store
        });
    }

    /// <summary>
    /// Tạo cửa hàng Franchise mới
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateStore([FromBody] CreateStoreDto dto)
    {
        var store = await _storeService.CreateStoreAsync(dto);
        return CreatedAtAction(nameof(GetStoreById), new { id = store.StoreId }, new
        {
            success = true,
            message = "Tạo cửa hàng thành công.",
            data = store
        });
    }

    /// <summary>
    /// Cập nhật thông tin cửa hàng Franchise
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateStore(int id, [FromBody] UpdateStoreDto dto)
    {
        var store = await _storeService.UpdateStoreAsync(id, dto);
        if (store == null)
            return NotFound(new { success = false, message = "Không tìm thấy cửa hàng." });

        return Ok(new
        {
            success = true,
            message = "Cập nhật cửa hàng thành công.",
            data = store
        });
    }

    /// <summary>
    /// Xóa cửa hàng Franchise
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteStore(int id)
    {
        var result = await _storeService.DeleteStoreAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy cửa hàng." });

        return Ok(new
        {
            success = true,
            message = "Xóa cửa hàng thành công."
        });
    }

    // ======================== CENTRAL KITCHENS ========================

    /// <summary>
    /// Lấy danh sách tất cả Bếp Trung Tâm
    /// </summary>
    [HttpGet("kitchens")]
    public async Task<IActionResult> GetAllKitchens()
    {
        var kitchens = await _kitchenService.GetAllKitchensAsync();
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách bếp trung tâm thành công.",
            data = kitchens
        });
    }

    /// <summary>
    /// Lấy thông tin chi tiết một Bếp Trung Tâm theo ID
    /// </summary>
    [HttpGet("kitchens/{id}")]
    public async Task<IActionResult> GetKitchenById(int id)
    {
        var kitchen = await _kitchenService.GetKitchenByIdAsync(id);
        if (kitchen == null)
            return NotFound(new { success = false, message = "Không tìm thấy bếp trung tâm." });

        return Ok(new
        {
            success = true,
            message = "Lấy thông tin bếp trung tâm thành công.",
            data = kitchen
        });
    }

    /// <summary>
    /// Tạo Bếp Trung Tâm mới
    /// </summary>
    [HttpPost("kitchens")]
    public async Task<IActionResult> CreateKitchen([FromBody] CreateKitchenDto dto)
    {
        var kitchen = await _kitchenService.CreateKitchenAsync(dto);
        return CreatedAtAction(nameof(GetKitchenById), new { id = kitchen.KitchenId }, new
        {
            success = true,
            message = "Tạo bếp trung tâm thành công.",
            data = kitchen
        });
    }

    /// <summary>
    /// Cập nhật thông tin Bếp Trung Tâm
    /// </summary>
    [HttpPut("kitchens/{id}")]
    public async Task<IActionResult> UpdateKitchen(int id, [FromBody] UpdateKitchenDto dto)
    {
        var kitchen = await _kitchenService.UpdateKitchenAsync(id, dto);
        if (kitchen == null)
            return NotFound(new { success = false, message = "Không tìm thấy bếp trung tâm." });

        return Ok(new
        {
            success = true,
            message = "Cập nhật bếp trung tâm thành công.",
            data = kitchen
        });
    }

    /// <summary>
    /// Xóa Bếp Trung Tâm
    /// </summary>
    [HttpDelete("kitchens/{id}")]
    public async Task<IActionResult> DeleteKitchen(int id)
    {
        var result = await _kitchenService.DeleteKitchenAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy bếp trung tâm." });

        return Ok(new
        {
            success = true,
            message = "Xóa bếp trung tâm thành công."
        });
    }
}
