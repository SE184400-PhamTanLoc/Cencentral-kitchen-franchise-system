using Central_kitchen_Repositories.Models;

namespace Central_kitchen_Repositories.Interfaces;

public interface IChatMessageRepository
{
    Task<ChatMessage> AddAsync(ChatMessage message);
    Task<List<ChatMessage>> GetConversationAsync(int? storeId, int? kitchenId);
}
