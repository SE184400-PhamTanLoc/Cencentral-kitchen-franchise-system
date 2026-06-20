using System.ComponentModel.DataAnnotations;

namespace Central_kitchen_Services.DTOs.Chat;

public class CreateChatMessageDto
{
    [Required]
    public int SenderId { get; set; }

    public int? StoreId { get; set; }

    public int? KitchenId { get; set; }

    [Required]
    [MinLength(1)]
    public string MessageText { get; set; } = null!;
}
