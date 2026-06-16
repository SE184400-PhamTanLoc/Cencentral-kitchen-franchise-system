using Central_kitchen_Services.DTOs.User;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "ADMIN")]
public class AdminUsersController : ControllerBase
{
    private readonly IUserService _userService;

    public AdminUsersController(IUserService userService)
    {
        _userService = userService;
    }

    /// <summary>
    /// Lấy danh sách tất cả tài khoản nhân viên
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users = await _userService.GetAllUsersAsync();
        return Ok(new
        {
            success = true,
            message = "Lấy danh sách người dùng thành công.",
            data = users
        });
    }

    /// <summary>
    /// Lấy thông tin chi tiết một tài khoản theo ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null)
            return NotFound(new { success = false, message = "Không tìm thấy người dùng." });

        return Ok(new
        {
            success = true,
            message = "Lấy thông tin người dùng thành công.",
            data = user
        });
    }

    /// <summary>
    /// Tạo tài khoản nhân viên mới
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto)
    {
        try
        {
            var user = await _userService.CreateUserAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = user.UserId }, new
            {
                success = true,
                message = "Tạo tài khoản thành công.",
                data = user
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Cập nhật thông tin tài khoản nhân viên
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
    {
        try
        {
            var user = await _userService.UpdateUserAsync(id, dto);
            if (user == null)
                return NotFound(new { success = false, message = "Không tìm thấy người dùng." });

            return Ok(new
            {
                success = true,
                message = "Cập nhật tài khoản thành công.",
                data = user
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Xóa tài khoản nhân viên
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _userService.DeleteUserAsync(id);
        if (!result)
            return NotFound(new { success = false, message = "Không tìm thấy người dùng." });

        return Ok(new
        {
            success = true,
            message = "Xóa tài khoản thành công."
        });
    }
}
