using System;

namespace Central_kitchen_Services.DTOs.Chat;

public class ChatMessageDto
{
    public int MessageId { get; set; }
    public int SenderId { get; set; }
    public string SenderName { get; set; } = null!;
    public string SenderRole { get; set; } = null!;
    public int? StoreId { get; set; }
    public int? KitchenId { get; set; }
    public string MessageText { get; set; } = null!;
    public DateTime? CreatedAt { get; set; }
}
