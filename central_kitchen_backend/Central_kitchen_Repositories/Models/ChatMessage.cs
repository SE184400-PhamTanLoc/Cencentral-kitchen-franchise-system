using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class ChatMessage
{
    public int MessageId { get; set; }

    public int SenderId { get; set; }

    public int? StoreId { get; set; }

    public int? KitchenId { get; set; }

    public string MessageText { get; set; } = null!;

    public DateTime? CreatedAt { get; set; }

    public virtual CentralKitchen? Kitchen { get; set; }

    public virtual User Sender { get; set; } = null!;

    public virtual Store? Store { get; set; }
}
