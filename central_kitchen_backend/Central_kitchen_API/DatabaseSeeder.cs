using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_API;

/// <summary>
/// Seeder để khởi tạo dữ liệu mặc định: Roles + Admin account
/// Chạy tự động khi khởi động API
/// </summary>
public static class DatabaseSeeder
{
    public static async Task SeedAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

        try
        {
            // Seed Roles nếu chưa có
            if (!await context.Roles.AnyAsync())
            {
                logger.LogInformation("Seeding default roles...");
                context.Roles.AddRange(
                    new Role { RoleCode = "ADMIN", RoleName = "Quản trị viên hệ thống" },
                    new Role { RoleCode = "FRANCHISE_STAFF", RoleName = "Nhân viên cửa hàng nhượng quyền" },
                    new Role { RoleCode = "KITCHEN_STAFF", RoleName = "Nhân viên bếp trung tâm" },
                    new Role { RoleCode = "SUPPLY_COORDINATOR", RoleName = "Điều phối viên cung ứng" }
                );
                await context.SaveChangesAsync();
                logger.LogInformation("Roles seeded successfully.");
            }

            // Seed Admin account nếu chưa có
            var adminRole = await context.Roles.FirstOrDefaultAsync(r => r.RoleCode == "ADMIN");
            if (adminRole != null && !await context.Users.AnyAsync(u => u.RoleId == adminRole.RoleId))
            {
                logger.LogInformation("Seeding default admin account...");
                context.Users.Add(new User
                {
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                    FullName = "System Administrator",
                    Email = "admin@centralkitchen.com",
                    RoleId = adminRole.RoleId,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
                await context.SaveChangesAsync();
                logger.LogInformation("Admin account seeded: admin / Admin@123");
            }
            else
            {
                // Kiểm tra nếu admin user có password chưa được hash bằng BCrypt
                var adminUser = await context.Users
                    .FirstOrDefaultAsync(u => u.Role.RoleCode == "ADMIN");
                if (adminUser != null && !adminUser.PasswordHash.StartsWith("$2"))
                {
                    logger.LogInformation("Re-hashing admin password with BCrypt...");
                    adminUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123");
                    await context.SaveChangesAsync();
                    logger.LogInformation("Admin password re-hashed successfully.");
                }
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Lỗi khi seed dữ liệu mặc định.");
        }
    }
}
