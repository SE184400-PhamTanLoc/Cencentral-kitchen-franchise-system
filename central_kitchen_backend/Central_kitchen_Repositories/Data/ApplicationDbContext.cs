using System;
using System.Collections.Generic;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Data;

public partial class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Batch> Batches { get; set; }

    public virtual DbSet<CentralKitchen> CentralKitchens { get; set; }

    public virtual DbSet<ChatMessage> ChatMessages { get; set; }

    public virtual DbSet<DeliveryLog> DeliveryLogs { get; set; }

    public virtual DbSet<Ingredient> Ingredients { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderDetail> OrderDetails { get; set; }

    public virtual DbSet<Recipe> Recipes { get; set; }

    public virtual DbSet<RecipeDetail> RecipeDetails { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Store> Stores { get; set; }

    public virtual DbSet<StoreInventory> StoreInventories { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Batch>(entity =>
        {
            entity.HasKey(e => e.BatchId).HasName("Batches_pkey");

            entity.HasIndex(e => e.BatchCode, "Batches_BatchCode_key").IsUnique();

            entity.Property(e => e.BatchId).UseIdentityAlwaysColumn();
            entity.Property(e => e.BatchCode).HasMaxLength(50);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.Quantity).HasPrecision(10, 2);
            entity.Property(e => e.RemainingQuantity).HasPrecision(10, 2);

            entity.HasOne(d => d.Ingredient).WithMany(p => p.Batches)
                .HasForeignKey(d => d.IngredientId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Batches_IngredientId_fkey");

            entity.HasOne(d => d.Kitchen).WithMany(p => p.Batches)
                .HasForeignKey(d => d.KitchenId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Batches_KitchenId_fkey");
        });

        modelBuilder.Entity<CentralKitchen>(entity =>
        {
            entity.HasKey(e => e.KitchenId).HasName("CentralKitchens_pkey");

            entity.Property(e => e.KitchenId).UseIdentityAlwaysColumn();
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.KitchenName).HasMaxLength(150);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
        });

        modelBuilder.Entity<ChatMessage>(entity =>
        {
            entity.HasKey(e => e.MessageId).HasName("ChatMessages_pkey");

            entity.Property(e => e.MessageId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");

            entity.HasOne(d => d.Kitchen).WithMany(p => p.ChatMessages)
                .HasForeignKey(d => d.KitchenId)
                .HasConstraintName("ChatMessages_KitchenId_fkey");

            entity.HasOne(d => d.Sender).WithMany(p => p.ChatMessages)
                .HasForeignKey(d => d.SenderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("ChatMessages_SenderId_fkey");

            entity.HasOne(d => d.Store).WithMany(p => p.ChatMessages)
                .HasForeignKey(d => d.StoreId)
                .HasConstraintName("ChatMessages_StoreId_fkey");
        });

        modelBuilder.Entity<DeliveryLog>(entity =>
        {
            entity.HasKey(e => e.LogId).HasName("DeliveryLogs_pkey");

            entity.Property(e => e.LogId).UseIdentityAlwaysColumn();
            entity.Property(e => e.Latitude).HasPrecision(10, 7);
            entity.Property(e => e.Longitude).HasPrecision(10, 7);
            entity.Property(e => e.RecordedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");

            entity.HasOne(d => d.Driver).WithMany(p => p.DeliveryLogs)
                .HasForeignKey(d => d.DriverId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("DeliveryLogs_DriverId_fkey");

            entity.HasOne(d => d.Order).WithMany(p => p.DeliveryLogs)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("DeliveryLogs_OrderId_fkey");
        });

        modelBuilder.Entity<Ingredient>(entity =>
        {
            entity.HasKey(e => e.IngredientId).HasName("Ingredients_pkey");

            entity.HasIndex(e => e.Sku, "Ingredients_SKU_key").IsUnique();

            entity.Property(e => e.IngredientId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.IsRawMaterial).HasDefaultValue(true);
            entity.Property(e => e.MinStockLevel)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("0.00");
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.Sku)
                .HasMaxLength(50)
                .HasColumnName("SKU");
            entity.Property(e => e.Unit).HasMaxLength(20);
            entity.Property(e => e.UnitPrice).HasPrecision(12, 2);
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.NotificationId).HasName("Notifications_pkey");

            entity.Property(e => e.NotificationId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.IsRead).HasDefaultValue(false);
            entity.Property(e => e.Title).HasMaxLength(200);

            entity.HasOne(d => d.User).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Notifications_UserId_fkey");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.OrderId).HasName("Orders_pkey");

            entity.HasIndex(e => e.OrderCode, "Orders_OrderCode_key").IsUnique();

            entity.Property(e => e.OrderId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.OrderCode).HasMaxLength(50);
            entity.Property(e => e.OrderStatus)
                .HasMaxLength(50)
                .HasDefaultValueSql("'PENDING'::character varying");
            entity.Property(e => e.TotalAmount)
                .HasPrecision(15, 2)
                .HasDefaultValueSql("0.00");
            entity.Property(e => e.UpdatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.Orders)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Orders_CreatedBy_fkey");

            entity.HasOne(d => d.Kitchen).WithMany(p => p.Orders)
                .HasForeignKey(d => d.KitchenId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Orders_KitchenId_fkey");

            entity.HasOne(d => d.Store).WithMany(p => p.Orders)
                .HasForeignKey(d => d.StoreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Orders_StoreId_fkey");
        });

        modelBuilder.Entity<OrderDetail>(entity =>
        {
            entity.HasKey(e => e.OrderDetailId).HasName("OrderDetails_pkey");

            entity.Property(e => e.OrderDetailId).UseIdentityAlwaysColumn();
            entity.Property(e => e.QuantityDelivered)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("0.00");
            entity.Property(e => e.QuantityOrdered).HasPrecision(10, 2);
            entity.Property(e => e.UnitPrice).HasPrecision(12, 2);

            entity.HasOne(d => d.Ingredient).WithMany(p => p.OrderDetails)
                .HasForeignKey(d => d.IngredientId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("OrderDetails_IngredientId_fkey");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderDetails)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("OrderDetails_OrderId_fkey");
        });

        modelBuilder.Entity<Recipe>(entity =>
        {
            entity.HasKey(e => e.RecipeId).HasName("Recipes_pkey");

            entity.HasIndex(e => e.OutputIngredientId, "Recipes_OutputIngredientId_key").IsUnique();

            entity.Property(e => e.RecipeId).UseIdentityAlwaysColumn();

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.Recipes)
                .HasForeignKey(d => d.CreatedBy)
                .HasConstraintName("Recipes_CreatedBy_fkey");

            entity.HasOne(d => d.OutputIngredient).WithOne(p => p.Recipe)
                .HasForeignKey<Recipe>(d => d.OutputIngredientId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Recipes_OutputIngredientId_fkey");
        });

        modelBuilder.Entity<RecipeDetail>(entity =>
        {
            entity.HasKey(e => e.RecipeDetailId).HasName("RecipeDetails_pkey");

            entity.Property(e => e.RecipeDetailId).UseIdentityAlwaysColumn();
            entity.Property(e => e.QuantityRequired).HasPrecision(10, 4);

            entity.HasOne(d => d.InputIngredient).WithMany(p => p.RecipeDetails)
                .HasForeignKey(d => d.InputIngredientId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("RecipeDetails_InputIngredientId_fkey");

            entity.HasOne(d => d.Recipe).WithMany(p => p.RecipeDetails)
                .HasForeignKey(d => d.RecipeId)
                .HasConstraintName("RecipeDetails_RecipeId_fkey");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("Roles_pkey");

            entity.HasIndex(e => e.RoleCode, "Roles_RoleCode_key").IsUnique();

            entity.Property(e => e.RoleId).UseIdentityAlwaysColumn();
            entity.Property(e => e.RoleCode).HasMaxLength(50);
            entity.Property(e => e.RoleName).HasMaxLength(100);
        });

        modelBuilder.Entity<Store>(entity =>
        {
            entity.HasKey(e => e.StoreId).HasName("Stores_pkey");

            entity.Property(e => e.StoreId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreditLimit)
                .HasPrecision(15, 2)
                .HasDefaultValueSql("0.00");
            entity.Property(e => e.CurrentDebt)
                .HasPrecision(15, 2)
                .HasDefaultValueSql("0.00");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.StoreName).HasMaxLength(150);
        });

        modelBuilder.Entity<StoreInventory>(entity =>
        {
            entity.HasKey(e => e.StoreInventoryId).HasName("StoreInventory_pkey");

            entity.ToTable("StoreInventory");

            entity.HasIndex(e => new { e.StoreId, e.IngredientId }, "UQ_Store_Ingredient").IsUnique();

            entity.Property(e => e.StoreInventoryId).UseIdentityAlwaysColumn();
            entity.Property(e => e.LastUpdated)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.StockQuantity)
                .HasPrecision(10, 2)
                .HasDefaultValueSql("0.00");

            entity.HasOne(d => d.Ingredient).WithMany(p => p.StoreInventories)
                .HasForeignKey(d => d.IngredientId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StoreInventory_IngredientId_fkey");

            entity.HasOne(d => d.Store).WithMany(p => p.StoreInventories)
                .HasForeignKey(d => d.StoreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StoreInventory_StoreId_fkey");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("Users_pkey");

            entity.HasIndex(e => e.Email, "Users_Email_key").IsUnique();

            entity.HasIndex(e => e.Username, "Users_Username_key").IsUnique();

            entity.Property(e => e.UserId).UseIdentityAlwaysColumn();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            entity.Property(e => e.Username).HasMaxLength(50);

            entity.HasOne(d => d.Kitchen).WithMany(p => p.Users)
                .HasForeignKey(d => d.KitchenId)
                .HasConstraintName("Users_KitchenId_fkey");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Users_RoleId_fkey");

            entity.HasOne(d => d.Store).WithMany(p => p.Users)
                .HasForeignKey(d => d.StoreId)
                .HasConstraintName("Users_StoreId_fkey");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
