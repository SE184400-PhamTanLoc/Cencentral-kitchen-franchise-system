using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace Central_kitchen_API;

/// <summary>
/// Seeder để khởi tạo dữ liệu mặc định và dữ liệu thử nghiệm
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
            logger.LogInformation("Ensuring database and tables exist...");
            try 
            {
                var databaseCreator = context.Database.GetService<Microsoft.EntityFrameworkCore.Storage.IRelationalDatabaseCreator>();
                await databaseCreator.CreateTablesAsync();
                logger.LogInformation("Tables created successfully.");
            }
            catch
            {
                logger.LogWarning("Tables might already exist, skipping CreateTablesAsync.");
            }

            // Kiểm tra nếu DB đã có dữ liệu (ví dụ đã có Roles) thì bỏ qua Seed
            if (await context.Roles.AnyAsync())
            {
                logger.LogInformation("Database already has data. Skipping truncate and seed.");
                return;
            }

            // Clear existing data in correct order to prevent FK violations
            try
            {
                logger.LogInformation("Attempting to truncate tables using Raw SQL...");
                await context.Database.ExecuteSqlRawAsync(@"
                    TRUNCATE TABLE 
                        ""DeliveryLogs"", 
                        ""ChatMessages"", 
                        ""Notifications"", 
                        ""OrderDetails"", 
                        ""Orders"", 
                        ""StoreInventory"", 
                        ""Batches"", 
                        ""RecipeDetails"", 
                        ""Recipes"", 
                        ""Users"", 
                        ""Stores"", 
                        ""CentralKitchens"", 
                        ""Ingredients"", 
                        ""Roles"" 
                    RESTART IDENTITY CASCADE;");
                logger.LogInformation("Tables truncated successfully.");
            }
            catch (Exception sqlEx)
            {
                logger.LogWarning(sqlEx, "Raw SQL truncate failed. Falling back to EF Core RemoveRange...");
                
                context.DeliveryLogs.RemoveRange(context.DeliveryLogs);
                context.ChatMessages.RemoveRange(context.ChatMessages);
                context.Notifications.RemoveRange(context.Notifications);
                context.OrderDetails.RemoveRange(context.OrderDetails);
                context.Orders.RemoveRange(context.Orders);
                context.StoreInventories.RemoveRange(context.StoreInventories);
                context.Batches.RemoveRange(context.Batches);
                context.RecipeDetails.RemoveRange(context.RecipeDetails);
                context.Recipes.RemoveRange(context.Recipes);
                context.Users.RemoveRange(context.Users);
                context.Stores.RemoveRange(context.Stores);
                context.CentralKitchens.RemoveRange(context.CentralKitchens);
                context.Ingredients.RemoveRange(context.Ingredients);
                context.Roles.RemoveRange(context.Roles);
                
                await context.SaveChangesAsync();
                logger.LogInformation("Database cleared via EF Core RemoveRange.");
            }

            // 1. Seed Roles
            logger.LogInformation("Seeding default roles...");
            var roles = new List<Role>
            {
                new Role { RoleCode = "ADMIN", RoleName = "Quản trị viên hệ thống" },
                new Role { RoleCode = "MANAGER", RoleName = "Quản lý chuỗi" },
                new Role { RoleCode = "FRANCHISE_STAFF", RoleName = "Nhân viên cửa hàng nhượng quyền" },
                new Role { RoleCode = "KITCHEN_STAFF", RoleName = "Nhân viên bếp trung tâm" },
                new Role { RoleCode = "SUPPLY_COORDINATOR", RoleName = "Điều phối viên cung ứng" }
            };
            context.Roles.AddRange(roles);
            await context.SaveChangesAsync();
            logger.LogInformation("Roles seeded successfully.");

            // 2. Seed Central Kitchens
            logger.LogInformation("Seeding central kitchens...");
            var kitchens = new List<CentralKitchen>
            {
                new CentralKitchen { KitchenName = "Bếp Trung Tâm Quận 1", Address = "123 Nguyễn Huệ, Quận 1, TP. HCM", PhoneNumber = "02811112222", IsActive = true },
                new CentralKitchen { KitchenName = "Bếp Trung Tâm Quận 7", Address = "456 Nguyễn Thị Thập, Quận 7, TP. HCM", PhoneNumber = "02833334444", IsActive = true }
            };
            context.CentralKitchens.AddRange(kitchens);
            await context.SaveChangesAsync();
            logger.LogInformation("Central kitchens seeded successfully.");

            // 3. Seed Stores
            logger.LogInformation("Seeding stores...");
            var stores = new List<Store>
            {
                new Store { StoreName = "Cửa hàng Nhượng Quyền Bình Thạnh", Address = "789 Điện Biên Phủ, Bình Thạnh, TP. HCM", PhoneNumber = "0901234567", CreditLimit = 50000000m, CurrentDebt = 10000000m, IsActive = true },
                new Store { StoreName = "Cửa hàng Nhượng Quyền Thủ Đức", Address = "101 Võ Văn Ngân, Thủ Đức, TP. HCM", PhoneNumber = "0907654321", CreditLimit = 30000000m, CurrentDebt = 0m, IsActive = true }
            };
            context.Stores.AddRange(stores);
            await context.SaveChangesAsync();
            logger.LogInformation("Stores seeded successfully.");

            // 4. Seed Users
            logger.LogInformation("Seeding default users...");
            var adminRole = roles.First(r => r.RoleCode == "ADMIN");
            var managerRole = roles.First(r => r.RoleCode == "MANAGER");
            var kitchenRole = roles.First(r => r.RoleCode == "KITCHEN_STAFF");
            var franchiseRole = roles.First(r => r.RoleCode == "FRANCHISE_STAFF");
            var supplyRole = roles.First(r => r.RoleCode == "SUPPLY_COORDINATOR");

            var users = new List<User>
            {
                new User { Username = "admin", PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"), FullName = "System Administrator", Email = "admin@centralkitchen.com", RoleId = adminRole.RoleId, IsActive = true, CreatedAt = DateTime.UtcNow },
                new User { Username = "manager1", PasswordHash = BCrypt.Net.BCrypt.HashPassword("Manager@123"), FullName = "Nguyễn Quản Lý", Email = "manager1@centralkitchen.com", RoleId = managerRole.RoleId, IsActive = true, CreatedAt = DateTime.UtcNow },
                new User { Username = "kitchen1", PasswordHash = BCrypt.Net.BCrypt.HashPassword("Kitchen@123"), FullName = "Trần Đầu Bếp", Email = "kitchen1@centralkitchen.com", RoleId = kitchenRole.RoleId, KitchenId = kitchens[0].KitchenId, IsActive = true, CreatedAt = DateTime.UtcNow },
                new User { Username = "franchise1", PasswordHash = BCrypt.Net.BCrypt.HashPassword("Franchise@123"), FullName = "Lê Cửa Hàng", Email = "franchise1@centralkitchen.com", RoleId = franchiseRole.RoleId, StoreId = stores[0].StoreId, IsActive = true, CreatedAt = DateTime.UtcNow },
                new User { Username = "delivery1", PasswordHash = BCrypt.Net.BCrypt.HashPassword("Delivery@123"), FullName = "Phạm Tài Xế", Email = "delivery1@centralkitchen.com", RoleId = supplyRole.RoleId, KitchenId = kitchens[0].KitchenId, IsActive = true, CreatedAt = DateTime.UtcNow }
            };
            context.Users.AddRange(users);
            await context.SaveChangesAsync();
            logger.LogInformation("Users seeded successfully.");

            // 5. Seed Ingredients (Raw materials and finished products)
            logger.LogInformation("Seeding ingredients...");
            var ingredients = new List<Ingredient>
            {
                // Raw materials
                new Ingredient { Name = "Bột mì", Sku = "RAW-FLOUR", Unit = "kg", UnitPrice = 15000m, IsRawMaterial = true, MinStockLevel = 50m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Đường", Sku = "RAW-SUGAR", Unit = "kg", UnitPrice = 20000m, IsRawMaterial = true, MinStockLevel = 20m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Bơ", Sku = "RAW-BUTTER", Unit = "kg", UnitPrice = 120000m, IsRawMaterial = true, MinStockLevel = 10m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Thịt heo", Sku = "RAW-PORK", Unit = "kg", UnitPrice = 90000m, IsRawMaterial = true, MinStockLevel = 30m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Hành tây", Sku = "RAW-ONION", Unit = "kg", UnitPrice = 18000m, IsRawMaterial = true, MinStockLevel = 15m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Pate", Sku = "RAW-PATE", Unit = "kg", UnitPrice = 80000m, IsRawMaterial = true, MinStockLevel = 20m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Chả lụa", Sku = "RAW-HAM", Unit = "kg", UnitPrice = 110000m, IsRawMaterial = true, MinStockLevel = 15m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Chà bông", Sku = "RAW-FLOSS", Unit = "kg", UnitPrice = 150000m, IsRawMaterial = true, MinStockLevel = 10m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Trứng", Sku = "RAW-EGG", Unit = "quả", UnitPrice = 3000m, IsRawMaterial = true, MinStockLevel = 50m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Thịt bò", Sku = "RAW-BEEF", Unit = "kg", UnitPrice = 220000m, IsRawMaterial = true, MinStockLevel = 20m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Dưa leo & rau thơm", Sku = "RAW-VEG", Unit = "kg", UnitPrice = 12000m, IsRawMaterial = true, MinStockLevel = 20m, CreatedAt = DateTime.UtcNow },
                
                // Finished products
                new Ingredient { Name = "Vỏ bánh mì", Sku = "FIN-BREAD", Unit = "cái", UnitPrice = 3000m, IsRawMaterial = false, MinStockLevel = 100m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Xíu mại", Sku = "FIN-MEATBALL", Unit = "viên", UnitPrice = 5000m, IsRawMaterial = false, MinStockLevel = 200m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Bánh mì xíu mại hoàn chỉnh", Sku = "FIN-BMXM", Unit = "cái", UnitPrice = 15000m, IsRawMaterial = false, MinStockLevel = 50m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Bánh mì pate chả lụa", Sku = "FIN-BMPC", Unit = "cái", UnitPrice = 18000m, IsRawMaterial = false, MinStockLevel = 50m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Bánh mì bò né hoàn chỉnh", Sku = "FIN-BMBN", Unit = "cái", UnitPrice = 25000m, IsRawMaterial = false, MinStockLevel = 30m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Bánh mì chà bông", Sku = "FIN-BMCB", Unit = "cái", UnitPrice = 14000m, IsRawMaterial = false, MinStockLevel = 40m, CreatedAt = DateTime.UtcNow },
                new Ingredient { Name = "Sốt bơ trứng", Sku = "FIN-SAUCE", Unit = "kg", UnitPrice = 50000m, IsRawMaterial = false, MinStockLevel = 10m, CreatedAt = DateTime.UtcNow }
            };
            context.Ingredients.AddRange(ingredients);
            await context.SaveChangesAsync();
            logger.LogInformation("Ingredients seeded successfully.");

            // 6. Seed Recipes & RecipeDetails (BOM)
            logger.LogInformation("Seeding recipes (BOM)...");
            var kitchenUserId = users.First(u => u.Username == "kitchen1").UserId;

            // Recipe for Vỏ bánh mì (FIN-BREAD)
            var recipeBread = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, 
                Description = "Công thức làm vỏ bánh mì tiêu chuẩn",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeBread);
            await context.SaveChangesAsync();

            var recipeDetailsBread = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeBread.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-FLOUR").IngredientId, QuantityRequired = 0.1000m },
                new RecipeDetail { RecipeId = recipeBread.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-SUGAR").IngredientId, QuantityRequired = 0.0100m },
                new RecipeDetail { RecipeId = recipeBread.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-BUTTER").IngredientId, QuantityRequired = 0.0050m }
            };
            context.RecipeDetails.AddRange(recipeDetailsBread);

            // Recipe for Xíu mại (FIN-MEATBALL)
            var recipeMeatball = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, 
                Description = "Công thức làm xíu mại thơm ngon",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeMeatball);
            await context.SaveChangesAsync();

            var recipeDetailsMeatball = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeMeatball.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-PORK").IngredientId, QuantityRequired = 0.0500m },
                new RecipeDetail { RecipeId = recipeMeatball.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-ONION").IngredientId, QuantityRequired = 0.0100m }
            };
            context.RecipeDetails.AddRange(recipeDetailsMeatball);
            await context.SaveChangesAsync();

            // Recipe for Bánh mì xíu mại hoàn chỉnh (FIN-BMXM)
            var recipeBMXM = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-BMXM").IngredientId, 
                Description = "Công thức lắp ráp Bánh mì xíu mại hoàn chỉnh",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeBMXM);
            await context.SaveChangesAsync();

            var recipeDetailsBMXM = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeBMXM.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityRequired = 1.0000m },
                new RecipeDetail { RecipeId = recipeBMXM.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, QuantityRequired = 1.0000m }
            };
            context.RecipeDetails.AddRange(recipeDetailsBMXM);
            await context.SaveChangesAsync();

            // Recipe for Bánh mì pate chả lụa (FIN-BMPC)
            var recipeBMPC = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-BMPC").IngredientId, 
                Description = "Công thức lắp ráp Bánh mì pate chả lụa",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeBMPC);
            await context.SaveChangesAsync();

            var recipeDetailsBMPC = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeBMPC.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityRequired = 1.0000m },
                new RecipeDetail { RecipeId = recipeBMPC.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-PATE").IngredientId, QuantityRequired = 0.0300m },
                new RecipeDetail { RecipeId = recipeBMPC.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-HAM").IngredientId, QuantityRequired = 0.0500m },
                new RecipeDetail { RecipeId = recipeBMPC.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-SAUCE").IngredientId, QuantityRequired = 0.0200m },
                new RecipeDetail { RecipeId = recipeBMPC.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-VEG").IngredientId, QuantityRequired = 0.0200m }
            };
            context.RecipeDetails.AddRange(recipeDetailsBMPC);
            await context.SaveChangesAsync();

            // Recipe for Bánh mì bò né hoàn chỉnh (FIN-BMBN)
            var recipeBMBN = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-BMBN").IngredientId, 
                Description = "Công thức lắp ráp Bánh mì bò né",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeBMBN);
            await context.SaveChangesAsync();

            var recipeDetailsBMBN = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeBMBN.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityRequired = 1.0000m },
                new RecipeDetail { RecipeId = recipeBMBN.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-BEEF").IngredientId, QuantityRequired = 0.0800m },
                new RecipeDetail { RecipeId = recipeBMBN.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-SAUCE").IngredientId, QuantityRequired = 0.0200m },
                new RecipeDetail { RecipeId = recipeBMBN.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-VEG").IngredientId, QuantityRequired = 0.0200m }
            };
            context.RecipeDetails.AddRange(recipeDetailsBMBN);
            await context.SaveChangesAsync();

            // Recipe for Bánh mì chà bông (FIN-BMCB)
            var recipeBMCB = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-BMCB").IngredientId, 
                Description = "Công thức lắp ráp Bánh mì chà bông",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeBMCB);
            await context.SaveChangesAsync();

            var recipeDetailsBMCB = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeBMCB.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityRequired = 1.0000m },
                new RecipeDetail { RecipeId = recipeBMCB.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-FLOSS").IngredientId, QuantityRequired = 0.0300m },
                new RecipeDetail { RecipeId = recipeBMCB.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "FIN-SAUCE").IngredientId, QuantityRequired = 0.0300m }
            };
            context.RecipeDetails.AddRange(recipeDetailsBMCB);
            await context.SaveChangesAsync();

            // Recipe for Sốt bơ trứng (FIN-SAUCE)
            var recipeSauce = new Recipe 
            { 
                OutputIngredientId = ingredients.First(i => i.Sku == "FIN-SAUCE").IngredientId, 
                Description = "Công thức làm sốt bơ trứng",
                CreatedBy = kitchenUserId
            };
            context.Recipes.Add(recipeSauce);
            await context.SaveChangesAsync();

            var recipeDetailsSauce = new List<RecipeDetail>
            {
                new RecipeDetail { RecipeId = recipeSauce.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-BUTTER").IngredientId, QuantityRequired = 0.5000m },
                new RecipeDetail { RecipeId = recipeSauce.RecipeId, InputIngredientId = ingredients.First(i => i.Sku == "RAW-EGG").IngredientId, QuantityRequired = 10.0000m }
            };
            context.RecipeDetails.AddRange(recipeDetailsSauce);
            await context.SaveChangesAsync();

            logger.LogInformation("Recipes (BOM) seeded successfully.");

            // 7. Seed Batches (Kitchen Inventory)
            logger.LogInformation("Seeding inventory batches...");
            var batchDate = DateOnly.FromDateTime(DateTime.UtcNow);
            var batches = new List<Batch>
            {
                new Batch { BatchCode = "BAT-FLOUR-01", IngredientId = ingredients.First(i => i.Sku == "RAW-FLOUR").IngredientId, Quantity = 500m, RemainingQuantity = 500m, ManufactureDate = batchDate.AddDays(-5), ExpiryDate = batchDate.AddDays(180), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-SUGAR-01", IngredientId = ingredients.First(i => i.Sku == "RAW-SUGAR").IngredientId, Quantity = 200m, RemainingQuantity = 200m, ManufactureDate = batchDate.AddDays(-10), ExpiryDate = batchDate.AddDays(365), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-BUTTER-01", IngredientId = ingredients.First(i => i.Sku == "RAW-BUTTER").IngredientId, Quantity = 100m, RemainingQuantity = 100m, ManufactureDate = batchDate.AddDays(-2), ExpiryDate = batchDate.AddDays(90), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-PORK-01", IngredientId = ingredients.First(i => i.Sku == "RAW-PORK").IngredientId, Quantity = 300m, RemainingQuantity = 300m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(3), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-ONION-01", IngredientId = ingredients.First(i => i.Sku == "RAW-ONION").IngredientId, Quantity = 150m, RemainingQuantity = 150m, ManufactureDate = batchDate.AddDays(-1), ExpiryDate = batchDate.AddDays(14), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-PATE-01", IngredientId = ingredients.First(i => i.Sku == "RAW-PATE").IngredientId, Quantity = 100m, RemainingQuantity = 100m, ManufactureDate = batchDate.AddDays(-3), ExpiryDate = batchDate.AddDays(30), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-HAM-01", IngredientId = ingredients.First(i => i.Sku == "RAW-HAM").IngredientId, Quantity = 80m, RemainingQuantity = 80m, ManufactureDate = batchDate.AddDays(-2), ExpiryDate = batchDate.AddDays(45), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-FLOSS-01", IngredientId = ingredients.First(i => i.Sku == "RAW-FLOSS").IngredientId, Quantity = 50m, RemainingQuantity = 50m, ManufactureDate = batchDate.AddDays(-10), ExpiryDate = batchDate.AddDays(180), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-SAUCE-01", IngredientId = ingredients.First(i => i.Sku == "FIN-SAUCE").IngredientId, Quantity = 50m, RemainingQuantity = 50m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(7), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-EGG-01", IngredientId = ingredients.First(i => i.Sku == "RAW-EGG").IngredientId, Quantity = 1000m, RemainingQuantity = 1000m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(15), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-BEEF-01", IngredientId = ingredients.First(i => i.Sku == "RAW-BEEF").IngredientId, Quantity = 120m, RemainingQuantity = 120m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(4), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-VEG-01", IngredientId = ingredients.First(i => i.Sku == "RAW-VEG").IngredientId, Quantity = 80m, RemainingQuantity = 80m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(3), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                
                // Finished product batches
                new Batch { BatchCode = "BAT-BREAD-01", IngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, Quantity = 1000m, RemainingQuantity = 800m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(2), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow },
                new Batch { BatchCode = "BAT-MEATBALL-01", IngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, Quantity = 2000m, RemainingQuantity = 1500m, ManufactureDate = batchDate, ExpiryDate = batchDate.AddDays(4), KitchenId = kitchens[0].KitchenId, CreatedAt = DateTime.UtcNow }
            };
            context.Batches.AddRange(batches);
            await context.SaveChangesAsync();
            logger.LogInformation("Inventory batches seeded successfully.");

            // 8. Seed Store Inventories (Franchise Stock)
            logger.LogInformation("Seeding store inventories...");
            var storeInventories = new List<StoreInventory>
            {
                new StoreInventory { StoreId = stores[0].StoreId, IngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, StockQuantity = 50m, LastUpdated = DateTime.UtcNow },
                new StoreInventory { StoreId = stores[0].StoreId, IngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, StockQuantity = 100m, LastUpdated = DateTime.UtcNow }
            };
            context.StoreInventories.AddRange(storeInventories);
            await context.SaveChangesAsync();
            logger.LogInformation("Store inventories seeded successfully.");

            // 9. Seed Orders & OrderDetails
            logger.LogInformation("Seeding orders and order details...");
            var franchiseUser = users.First(u => u.Username == "franchise1");
            
            // Order 1: Completed
            var order1 = new Order
            {
                OrderCode = "ORD-001",
                StoreId = stores[0].StoreId,
                KitchenId = kitchens[0].KitchenId,
                TotalAmount = 450000m, // 100 Bread @ 3000 + 30 Meatballs @ 5000
                OrderStatus = "COMPLETED",
                Notes = "Đơn hàng mẫu đã hoàn thành nhận hàng",
                CreatedBy = franchiseUser.UserId,
                CreatedAt = DateTime.UtcNow.AddDays(-3),
                UpdatedAt = DateTime.UtcNow.AddDays(-3)
            };
            context.Orders.Add(order1);
            await context.SaveChangesAsync();

            var orderDetails1 = new List<OrderDetail>
            {
                new OrderDetail { OrderId = order1.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityOrdered = 100m, QuantityDelivered = 100m, UnitPrice = 3000m },
                new OrderDetail { OrderId = order1.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, QuantityOrdered = 30m, QuantityDelivered = 30m, UnitPrice = 5000m }
            };
            context.OrderDetails.AddRange(orderDetails1);

            // Order 2: Pending
            var order2 = new Order
            {
                OrderCode = "ORD-002",
                StoreId = stores[0].StoreId,
                KitchenId = kitchens[0].KitchenId,
                TotalAmount = 250000m, // 50 Bread @ 3000 + 20 Meatballs @ 5000
                OrderStatus = "PENDING",
                Notes = "Đơn hàng đang chờ duyệt sản xuất",
                CreatedBy = franchiseUser.UserId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            context.Orders.Add(order2);
            await context.SaveChangesAsync();

            var orderDetails2 = new List<OrderDetail>
            {
                new OrderDetail { OrderId = order2.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityOrdered = 50m, QuantityDelivered = 0m, UnitPrice = 3000m },
                new OrderDetail { OrderId = order2.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, QuantityOrdered = 20m, QuantityDelivered = 0m, UnitPrice = 5000m }
            };
            context.OrderDetails.AddRange(orderDetails2);

            // Order 3: Shipping
            var order3 = new Order
            {
                OrderCode = "ORD-003",
                StoreId = stores[0].StoreId,
                KitchenId = kitchens[0].KitchenId,
                TotalAmount = 800000m, // 200 Bread @ 3000 + 40 Meatballs @ 5000
                OrderStatus = "SHIPPING",
                Notes = "Đơn hàng đang vận chuyển đến cửa hàng",
                CreatedBy = franchiseUser.UserId,
                CreatedAt = DateTime.UtcNow.AddDays(-1),
                UpdatedAt = DateTime.UtcNow.AddDays(-1)
            };
            context.Orders.Add(order3);
            await context.SaveChangesAsync();

            var orderDetails3 = new List<OrderDetail>
            {
                new OrderDetail { OrderId = order3.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-BREAD").IngredientId, QuantityOrdered = 200m, QuantityDelivered = 0m, UnitPrice = 3000m },
                new OrderDetail { OrderId = order3.OrderId, IngredientId = ingredients.First(i => i.Sku == "FIN-MEATBALL").IngredientId, QuantityOrdered = 40m, QuantityDelivered = 0m, UnitPrice = 5000m }
            };
            context.OrderDetails.AddRange(orderDetails3);
            await context.SaveChangesAsync();
            logger.LogInformation("Orders and order details seeded successfully.");

            // 10. Seed Delivery Logs
            logger.LogInformation("Seeding delivery logs...");
            var driverUser = users.First(u => u.Username == "delivery1");
            var deliveryLogs = new List<DeliveryLog>
            {
                new DeliveryLog { OrderId = order3.OrderId, DriverId = driverUser.UserId, Latitude = 10.776900m, Longitude = 106.700900m, RecordedAt = DateTime.UtcNow.AddMinutes(-60) },
                new DeliveryLog { OrderId = order3.OrderId, DriverId = driverUser.UserId, Latitude = 10.782000m, Longitude = 106.695000m, RecordedAt = DateTime.UtcNow.AddMinutes(-30) },
                new DeliveryLog { OrderId = order3.OrderId, DriverId = driverUser.UserId, Latitude = 10.795000m, Longitude = 106.715000m, RecordedAt = DateTime.UtcNow.AddMinutes(-5) }
            };
            context.DeliveryLogs.AddRange(deliveryLogs);
            await context.SaveChangesAsync();
            logger.LogInformation("Delivery logs seeded successfully.");

            // 11. Seed Chat Messages
            logger.LogInformation("Seeding chat messages...");
            var kitchenUser = users.First(u => u.Username == "kitchen1");
            var chatMessages = new List<ChatMessage>
            {
                new ChatMessage { SenderId = franchiseUser.UserId, StoreId = stores[0].StoreId, KitchenId = kitchens[0].KitchenId, MessageText = "Bếp ơi, đơn hàng ORD-003 bao giờ giao tới thế ạ?", CreatedAt = DateTime.UtcNow.AddMinutes(-10) },
                new ChatMessage { SenderId = kitchenUser.UserId, StoreId = stores[0].StoreId, KitchenId = kitchens[0].KitchenId, MessageText = "Tài xế bên mình đang đi rồi nhé, dự kiến 15 phút nữa tới nơi nha bạn!", CreatedAt = DateTime.UtcNow.AddMinutes(-8) }
            };
            context.ChatMessages.AddRange(chatMessages);
            await context.SaveChangesAsync();
            logger.LogInformation("Chat messages seeded successfully.");

            // 12. Seed Notifications
            logger.LogInformation("Seeding notifications...");
            var notifications = new List<Notification>
            {
                new Notification { UserId = franchiseUser.UserId, Title = "Đơn hàng ORD-001 hoàn thành", Message = "Đơn hàng ORD-001 đã được giao và xác nhận thành công.", IsRead = true, CreatedAt = DateTime.UtcNow.AddDays(-3) },
                new Notification { UserId = franchiseUser.UserId, Title = "Đơn hàng ORD-003 đang giao", Message = "Đơn hàng ORD-003 đã được bàn giao cho tài xế và đang trên đường tới.", IsRead = false, CreatedAt = DateTime.UtcNow.AddMinutes(-30) },
                new Notification { UserId = kitchenUser.UserId, Title = "Yêu cầu đặt hàng mới", Message = "Cửa hàng Bình Thạnh vừa gửi yêu cầu đặt hàng ORD-002.", IsRead = false, CreatedAt = DateTime.UtcNow }
            };
            context.Notifications.AddRange(notifications);
            await context.SaveChangesAsync();
            logger.LogInformation("Notifications seeded successfully.");

            logger.LogInformation("All database tables seeded successfully!");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Lỗi nghiêm trọng khi dọn dẹp hoặc seed dữ liệu mặc định.");
        }
    }
}
