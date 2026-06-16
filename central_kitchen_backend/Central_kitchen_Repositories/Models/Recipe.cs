using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class Recipe
{
    public int RecipeId { get; set; }

    public int OutputIngredientId { get; set; }

    public string? Description { get; set; }

    public int? CreatedBy { get; set; }

    public virtual User? CreatedByNavigation { get; set; }

    public virtual Ingredient OutputIngredient { get; set; } = null!;

    public virtual ICollection<RecipeDetail> RecipeDetails { get; set; } = new List<RecipeDetail>();
}
