using System;
using System.Collections.Generic;

namespace Central_kitchen_Repositories.Models;

public partial class RecipeDetail
{
    public int RecipeDetailId { get; set; }

    public int RecipeId { get; set; }

    public int InputIngredientId { get; set; }

    public decimal QuantityRequired { get; set; }

    public virtual Ingredient InputIngredient { get; set; } = null!;

    public virtual Recipe Recipe { get; set; } = null!;
}
