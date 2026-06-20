using Central_kitchen_Services.DTOs.Chat;

namespace Central_kitchen_Services.Interfaces;

public interface IChatService
{
    Task<ChatMessageDto> SendMessageAsync(CreateChatMessageDto dto);
    Task<List<ChatMessageDto>> GetConversationAsync(int? storeId, int? kitchenId);
}
