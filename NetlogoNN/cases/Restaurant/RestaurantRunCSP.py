import sys

sys.path.append("../../")
from CreateDzn import main as create_dzn
from AnalyzeSolutions import main as analyze
import restaurant_generate_simdata


def sample_restaurant(input):
    success_rate, spoil_rate = restaurant_generate_simdata.run_single_def(input, periods=400)
    return {
        "success_ratio": success_rate,
        "spoil_ratio": spoil_rate
    }


if __name__ == "__main__":
    experiment_path = "dzn_solutions/test1"
    parameters_in=["buy1","buy2"]
    objectives=["success_ratio","spoil_ratio"]

    create_dzn(
        num_composites=30,
        experiment_path=experiment_path,
        mzn_path="mzn_wgt/restaurant.mzn",
        params_in=parameters_in,
        objectives=objectives
    )
    analyze(
        experiment_path=experiment_path,
        params_in=parameters_in,
        params_out=objectives,
        sample_function=sample_restaurant
    )
