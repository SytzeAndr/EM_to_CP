import numpy as np
from numpy import random


def create_random_recipes(recipes_count=3, ingredients_count=3, max_distinct_ingr_per_recipe=2, max_ingr_stack_per_recipe=2):
    res = {}
    ingredients = range(ingredients_count)

    for i in range(recipes_count):
        # generate random recipes
        number_ingredients_distinct = random.randint(1, max_distinct_ingr_per_recipe+1)
        corresponding_ingredients = random.permutation(ingredients)[:number_ingredients_distinct]
        recipe = {ingredient_id: random.randint(1, max_ingr_stack_per_recipe+1) for ingredient_id in corresponding_ingredients}
        res[i] = recipe
    return res


def create_random_buying_strategy(ingredient_count, max_per_ingredient):
    return [random.randint(0, max_per_ingredient) for _ in range(ingredient_count)]


def run_sim(buying_strategy, recipe_book, order_max_per_period, periods=10):
    num_ingredients = len(buying_strategy)
    num_dishes = len(recipe_book)
    inventory = [0 for _ in range(num_ingredients)]

    # metrics
    unsuccesful = 0
    succes = 0

    bought = 0
    spoiled = 0

    for i in range(periods):
        # resouces spoil at random for simplicity
        new_inventory = [int(np.round(
            random.uniform(0, 1) * x
        )) for x in inventory]

        # difference is the amount of spoil
        spoiled += np.sum(np.subtract(inventory, new_inventory))

        # buy in ingredients
        inventory = np.add(inventory, buying_strategy)
        bought += np.sum(buying_strategy)

        # pick a random dish per order
        orders = [random.randint(0, num_dishes) for _ in range(random.randint(0, order_max_per_period+1))]

        for order in orders:
            # can the dish be made?
            corresponding_recipe = recipe_book[order]
            can_be_made = True
            for ingredient_index, ingredient_value in corresponding_recipe.items():
                if inventory[ingredient_index] < ingredient_value:
                    can_be_made = False
            if not can_be_made:
                unsuccesful += 1
            else:
                succes += 1
                # consume resources
                for ingredient_index, ingredient_value in corresponding_recipe.items():
                    inventory[ingredient_index] -= ingredient_value


    succes_rate = succes / (unsuccesful + succes) if unsuccesful + succes != 0 else 0.0
    spoil_rate = spoiled / (bought + spoiled + sum(inventory)) if bought + spoiled + sum(inventory) != 0 else 0.0
    return succes_rate, spoil_rate


if __name__ == "__main__":
    recipes_count = 3
    ingredients_count = 2
    recipe_book = create_random_recipes(recipes_count, ingredients_count)
    # recipe_book = {0: {3: 2, 4: 3}, 1: {2: 1, 4: 1}, 2: {4: 2, 2: 3}, 3: {1: 3, 3: 3}, 4: {4: 3, 3: 3}}

    buying_strategy = create_random_buying_strategy(ingredients_count, max_per_ingredient=10)
    succes_ratio, spoil_ratio = run_sim(
        buying_strategy=buying_strategy,
        recipe_book=recipe_book,
        order_max_per_period=10,
        periods=100
    )
    print(recipe_book)
    print(buying_strategy)
    print("spoil rate: {}".format(spoil_ratio))
    print("succes rate: {}".format(succes_ratio))
