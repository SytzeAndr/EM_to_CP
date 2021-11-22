import restaurant_sim as rs
import os
import numpy as np

# 2 ingredients
# 3 recipes


def get_recipe_book():
    return {
        0: {1: 2, 0: 2},
        1: {1: 1},
        2: {1: 1, 0: 2}
    }


def run_single_def(
        buying_strategy,
        periods=100,
        order_per_period_max=10
):
    return rs.run_sim(
        buying_strategy=buying_strategy,
        recipe_book=get_recipe_book(),
        order_max_per_period=order_per_period_max,
        periods=periods
    )


def main(
        repetitions=1000,
        csv_out="train.csv",
        periods=100,
        buy_per_ingredient_max=10,
        order_per_period_max=10,
):

    ingredients_count = 2

    # same for each simulation
    recipe_book = get_recipe_book()

    # create file if non-existent
    if not os.path.isfile(csv_out):
        with open(csv_out, "w") as file:
            # write header
            file.write("buy1,buy2,succes_ratio,spoil_ratio\n")

    for i in range(repetitions):
        buying_strategy = rs.create_random_buying_strategy(ingredients_count, max_per_ingredient=buy_per_ingredient_max)
        succes_ratio, spoil_ratio = rs.run_sim(
            buying_strategy=buying_strategy,
            recipe_book=recipe_book,
            order_max_per_period=order_per_period_max,
            periods=periods
        )
        with open(csv_out, "a") as file:
            # append results
            file.write("{},{},{},{}\n".format(
                buying_strategy[0], buying_strategy[1], succes_ratio, spoil_ratio)
            )
        if np.mod(i, 500) == 0:
            print("{} out of {}".format(i, repetitions))


if __name__ == "__main__":
    main(repetitions=100000, csv_out="simdata/train.csv")



