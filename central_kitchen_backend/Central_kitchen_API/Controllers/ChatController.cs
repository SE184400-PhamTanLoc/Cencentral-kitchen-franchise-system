using Central_kitchen_Services.DTOs.Chat;
using Central_kitchen_Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Central_kitchen_API.Controllers;

[ApiController]
[Route("api/chat")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage([FromBody] CreateChatMessageDto dto)
    {
        try
        {
            var message = await _chatService.SendMessageAsync(dto);
            return Ok(message);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("conversation")]
    public async Task<IActionResult> GetConversation([FromQuery] int? storeId, [FromQuery] int? kitchenId)
    {
        var conversation = await _chatService.GetConversationAsync(storeId, kitchenId);
        return Ok(conversation);
    }

    [HttpGet("stores")]
    public async Task<IActionResult> GetStores([FromServices] IStoreService storeService)
    {
        var stores = await storeService.GetAllStoresAsync();
        return Ok(stores);
    }

    [HttpGet("kitchens")]
    public async Task<IActionResult> GetKitchens([FromServices] ICentralKitchenService kitchenService)
    {
        var kitchens = await kitchenService.GetAllKitchensAsync();
        return Ok(kitchens);
    }
}
