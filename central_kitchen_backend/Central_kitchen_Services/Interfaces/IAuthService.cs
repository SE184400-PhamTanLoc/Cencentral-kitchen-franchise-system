using Central_kitchen_Services.DTOs.Auth;

namespace Central_kitchen_Services.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request);
}
