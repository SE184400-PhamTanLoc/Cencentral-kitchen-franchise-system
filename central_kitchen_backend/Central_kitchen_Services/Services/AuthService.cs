using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Services.DTOs.Auth;
using Central_kitchen_Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Central_kitchen_Services.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;

    public AuthService(IUserRepository userRepository, IConfiguration configuration)
    {
        _userRepository = userRepository;
        _configuration = configuration;
    }

    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request)
    {
        // 1. Tìm user theo username
        var user = await _userRepository.GetByUsernameAsync(request.Username);
        if (user == null)
            throw new UnauthorizedAccessException("Tên đăng nhập hoặc mật khẩu không đúng.");

        // 2. Kiểm tra tài khoản đã bị vô hiệu hóa chưa
        if (user.IsActive == false)
            throw new UnauthorizedAccessException("Tài khoản đã bị vô hiệu hóa.");

        // 3. Xác thực mật khẩu bằng BCrypt
        bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
        if (!isPasswordValid)
            throw new UnauthorizedAccessException("Tên đăng nhập hoặc mật khẩu không đúng.");

        // 4. Tạo JWT Token
        var token = GenerateJwtToken(user);
        var expiration = DateTime.UtcNow.AddMinutes(
            double.Parse(_configuration["JwtSettings:ExpirationInMinutes"] ?? "480"));

        // 5. Trả về response
        return new LoginResponseDto
        {
            Token = token,
            Expiration = expiration,
            UserId = user.UserId,
            Username = user.Username,
            FullName = user.FullName,
            RoleCode = user.Role.RoleCode,
            RoleName = user.Role.RoleName,
            KitchenId = user.KitchenId,
            StoreId = user.StoreId
        };
    }

    private string GenerateJwtToken(Central_kitchen_Repositories.Models.User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings["SecretKey"]!));
        var credentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.GivenName, user.FullName),
            new Claim(ClaimTypes.Role, user.Role.RoleCode),
            new Claim("RoleName", user.Role.RoleName)
        };

        // Thêm thông tin KitchenId / StoreId vào claims nếu có
        if (user.KitchenId.HasValue)
            claims.Add(new Claim("KitchenId", user.KitchenId.Value.ToString()));
        if (user.StoreId.HasValue)
            claims.Add(new Claim("StoreId", user.StoreId.Value.ToString()));

        var expirationMinutes = double.Parse(jwtSettings["ExpirationInMinutes"] ?? "480");

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
