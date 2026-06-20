using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Central_kitchen_Services.DTOs.Chat;
using Central_kitchen_Services.Interfaces;

namespace Central_kitchen_Services.Services;

public class ChatService : IChatService
{
    private readonly IChatMessageRepository _chatMessageRepository;
    private readonly IUserRepository _userRepository;

    public ChatService(IChatMessageRepository chatMessageRepository, IUserRepository userRepository)
    {
        _chatMessageRepository = chatMessageRepository;
        _userRepository = userRepository;
    }

    public async Task<ChatMessageDto> SendMessageAsync(CreateChatMessageDto dto)
    {
        var sender = await _userRepository.GetByIdAsync(dto.SenderId);
        if (sender == null)
            throw new InvalidOperationException("Người gửi không tồn tại.");

        var message = new ChatMessage
        {
            SenderId = dto.SenderId,
            StoreId = dto.StoreId,
            KitchenId = dto.KitchenId,
            MessageText = dto.MessageText,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _chatMessageRepository.AddAsync(message);
        created.Sender = sender;
        return MapToDto(created);
    }

    public async Task<List<ChatMessageDto>> GetConversationAsync(int? storeId, int? kitchenId)
    {
        var messages = await _chatMessageRepository.GetConversationAsync(storeId, kitchenId);
        return messages.Select(MapToDto).ToList();
    }

    private static ChatMessageDto MapToDto(ChatMessage msg)
    {
        return new ChatMessageDto
        {
            MessageId = msg.MessageId,
            SenderId = msg.SenderId,
            SenderName = msg.Sender?.FullName ?? $"User {msg.SenderId}",
            SenderRole = msg.Sender?.Role?.RoleCode ?? "",
            StoreId = msg.StoreId,
            KitchenId = msg.KitchenId,
            MessageText = msg.MessageText,
            CreatedAt = msg.CreatedAt
        };
    }
}
