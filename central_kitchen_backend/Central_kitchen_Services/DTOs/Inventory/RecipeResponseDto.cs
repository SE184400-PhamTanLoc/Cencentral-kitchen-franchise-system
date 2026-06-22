namespace Central_kitchen_Services.DTOs.Inventory;

public class RecipeResponseDto
{
    public int RecipeId { get; set; }
    public int OutputIngredientId { get; set; }
    public string OutputIngredientName { get; set; } = null!;
    public string? Description { get; set; }
    public string? CreatedByName { get; set; }

    public List<RecipeInputDto> Details { get; set; } = new();
}
