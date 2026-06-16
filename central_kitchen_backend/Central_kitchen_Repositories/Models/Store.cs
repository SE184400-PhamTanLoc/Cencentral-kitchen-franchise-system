using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class Store
{
    public int StoreId { get; set; }

    public string StoreName { get; set; } = null!;

    public string Address { get; set; } = null!;

    public string? PhoneNumber { get; set; }

    public decimal? CreditLimit { get; set; }

    public decimal? CurrentDebt { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();

    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    public virtual ICollection<StoreInventory> StoreInventories { get; set; } = new List<StoreInventory>();

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
