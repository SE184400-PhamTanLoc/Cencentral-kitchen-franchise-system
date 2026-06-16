using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.User;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IRoleRepository _roleRepository;

    public UserService(IUserRepository userRepository, IRoleRepository roleRepository)
    {
        _userRepository = userRepository;
        _roleRepository = roleRepository;
    }

    public async Task<List<UserResponseDto>> GetAllUsersAsync()
    {
        var users = await _userRepository.GetAllAsync();
        return users.Select(MapToResponseDto).ToList();
    }

    public async Task<UserResponseDto?> GetUserByIdAsync(int userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        return user == null ? null : MapToResponseDto(user);
    }

    public async Task<UserResponseDto> CreateUserAsync(CreateUserDto dto)
    {
        // Kiểm tra username đã tồn tại
        if (await _userRepository.UsernameExistsAsync(dto.Username))
            throw new InvalidOperationException("Tên đăng nhập đã tồn tại.");

        // Kiểm tra email đã tồn tại
        if (!string.IsNullOrWhiteSpace(dto.Email) && await _userRepository.EmailExistsAsync(dto.Email))
            throw new InvalidOperationException("Email đã được sử dụng.");

        // Kiểm tra Role hợp lệ
        var role = await _roleRepository.GetByIdAsync(dto.RoleId);
        if (role == null)
            throw new InvalidOperationException("Vai trò không hợp lệ.");

        // Tạo User entity
        var user = new User
        {
            Username = dto.Username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
            FullName = dto.FullName,
            Email = dto.Email,
            PhoneNumber = dto.PhoneNumber,
            RoleId = dto.RoleId,
            KitchenId = dto.KitchenId,
            StoreId = dto.StoreId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var createdUser = await _userRepository.AddAsync(user);
        return MapToResponseDto(createdUser);
    }

    public async Task<UserResponseDto?> UpdateUserAsync(int userId, UpdateUserDto dto)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return null;

        // Kiểm tra email đã tồn tại (trừ user hiện tại)
        if (!string.IsNullOrWhiteSpace(dto.Email) && await _userRepository.EmailExistsAsync(dto.Email, userId))
            throw new InvalidOperationException("Email đã được sử dụng.");

        // Kiểm tra Role hợp lệ
        var role = await _roleRepository.GetByIdAsync(dto.RoleId);
        if (role == null)
            throw new InvalidOperationException("Vai trò không hợp lệ.");

        // Cập nhật thông tin
        user.FullName = dto.FullName;
        user.Email = dto.Email;
        user.PhoneNumber = dto.PhoneNumber;
        user.RoleId = dto.RoleId;
        user.KitchenId = dto.KitchenId;
        user.StoreId = dto.StoreId;
        user.IsActive = dto.IsActive;

        var updatedUser = await _userRepository.UpdateAsync(user);
        return MapToResponseDto(updatedUser);
    }

    public async Task<bool> DeleteUserAsync(int userId)
    {
        return await _userRepository.DeleteAsync(userId);
    }

    private static UserResponseDto MapToResponseDto(User user)
    {
        return new UserResponseDto
        {
            UserId = user.UserId,
            Username = user.Username,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            RoleId = user.RoleId,
            RoleCode = user.Role?.RoleCode ?? "",
            RoleName = user.Role?.RoleName ?? "",
            KitchenId = user.KitchenId,
            KitchenName = user.Kitchen?.KitchenName,
            StoreId = user.StoreId,
            StoreName = user.Store?.StoreName,
            IsActive = user.IsActive ?? true,
            CreatedAt = user.CreatedAt
        };
    }
}
