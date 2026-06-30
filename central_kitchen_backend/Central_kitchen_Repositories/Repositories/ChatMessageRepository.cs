using Central_kitchen_Repositories.Data;
using Central_kitchen_Repositories.Interfaces;
using Central_kitchen_Repositories.Models;
using Microsoft.EntityFrameworkCore;

namespace Central_kitchen_Repositories.Repositories;

public class ChatMessageRepository : IChatMessageRepository
{
    private readonly ApplicationDbContext _context;

    public ChatMessageRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ChatMessage> AddAsync(ChatMessage message)
    {
        _context.ChatMessages.Add(message);
        await _context.SaveChangesAsync();
        await _context.Entry(message).Reference(m => m.Sender).LoadAsync();
        return message;
    }

    public async Task<List<ChatMessage>> GetConversationAsync(int? storeId, int? kitchenId)
    {
        var query = _context.ChatMessages
            .Include(m => m.Sender)
            .AsQueryable();

        if (storeId.HasValue)
            query = query.Where(m => m.StoreId == storeId.Value);
        else
            query = query.Where(m => m.StoreId == null);

        if (kitchenId.HasValue)
            query = query.Where(m => m.KitchenId == kitchenId.Value);
        else
            query = query.Where(m => m.KitchenId == null);

        return await query
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();
    }
}
