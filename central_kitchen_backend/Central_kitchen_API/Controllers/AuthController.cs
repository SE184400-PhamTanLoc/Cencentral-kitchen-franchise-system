using Central_kitchen_Services.DTOs.Auth;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Đăng nhập hệ thống - Trả về JWT Token chứa thông tin Role
    /// </summary>
    /// <remarks>
    /// Tất cả nhân viên (Admin, Franchise Store Staff, Central Kitchen Staff, Supply Coordinator)
    /// đều sử dụng endpoint này để đăng nhập.
    /// Flutter sẽ đọc RoleCode trong response để điều hướng giao diện phù hợp.
    /// </remarks>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            var result = await _authService.LoginAsync(request);
            return Ok(new
            {
                success = true,
                message = "Đăng nhập thành công.",
                data = result
            });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new
            {
                success = false,
                message = ex.Message
            });
        }
    }
}
