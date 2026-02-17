import os
import sys

sys.path.append("../../")
from CreateDzn import main as create_dzn
from AnalyzeSolutions import main as analyze
from parameters import load_parameter
from NetlogoSimulatorSupplyChain import NetlogoSimulatorSupplyChain
from Timer import Timer

import pyNetLogo


def get_parameters_in():
    return [
        "Fact",
        "Distr1",
        "Distr2",
        "v1_DailyPurchase",
        "v2_PeriodicallyPurchase",
        "v3_Random",
        "v1_s_Q",
        "v2_s_S",
        "v3_R_S",
        "v4_Random"
    ]


def get_parameters_out():
    return [
        "lost_ratio_sales_fac",
        "lost_ratio_sales_dis",
        "lost_ratio_sales_ret"
        # "stock_customer_MA_mean_relative",
        # "stock_distributor_MA_mean_relative",
        # "stock_retailer_MA_mean_relative",
        # "stock_factory_MA_mean_relative"
    ]


def get_static_parameters():
    return {
        "Clients_N": 1300,
        "Demand_W": 10,
        "Lt0": 4,
        "Lt1": 4,
        "SS_%": 0.85,
        "DS_D": 7,
        "K": 200,
        "MA": 500,
        "HC": 0.05
    }


def sample_supply_chain(input):
    netlogo_model_path = "Supply_Chain.nlogo"
    simulationTicks = 1000

    print("\rloading netlogo model...", end="")
    if sys.platform == "win32":
        # windows
        netlogo = pyNetLogo.NetLogoLink(
            gui=False
        )
    else:
        # linux
        netlogo = pyNetLogo.NetLogoLink(
            gui=False,
            netlogo_home=load_parameter("netlogo_home"),
            netlogo_version=load_parameter("netlogo_version"),
            jvm_home=load_parameter("jvm_home")
        )

    netlogo.load_model(netlogo_model_path)

    # set static parameters
    for key, value in get_static_parameters().items():
        cmd = f"set {key} {value}"
        netlogo.command(cmd)

    # map discrete parameters
    Customers_Strategy = \
        "1-DailyPurchase" if input[4] == "1" else (
            "2-PeriodicallyPurchase" if input[5] == "1"
            else "3-Random")
    Customers_Strategy = f"\"{Customers_Strategy}\""

    Inventory_Policy = \
        "1-(s,Q)" if input[6] == "1" else (
            "2-(s,S)" if input[7] == "1" else (
                "3-(R,S)" if input[8] == "1" else
                "4-Random"))
    Inventory_Policy = f"\"{Inventory_Policy}\""

    # define parameters to set
    mapped_dynamic_parameters = {
        "Fact": input[0],
        "Distr1": input[1],
        "Distr2": input[2],
        "Customers_Strategy": Customers_Strategy,
        "Inventory_Policy": Inventory_Policy
    }

    netlogo.command('setup')
    netlogo.command('setup')

    # set them to the model
    for key, value in mapped_dynamic_parameters.items():
        cmd = f"set {key} {value}"
        netlogo.command(cmd)

    # run the simulation
    netlogo.command('setup')
    netlogo.repeat_command('go', simulationTicks)

    # get results
    objective_keys = get_parameters_out()
    output = {}

    for key in objective_keys:
        observed = netlogo.report(key)
        output[key] = observed

    netlogo.kill_workspace()

    return output


if __name__ == "__main__":
    experiment_path = "dzn_solutions/test4"
    parameters_in = get_parameters_in()
    objectives = get_parameters_out()

    # with Timer():
    create_dzn(
        num_composites=15,
        experiment_path=experiment_path,
        mzn_path="mzn_wgt/supply_chain.mzn",
        params_in=parameters_in,
        objectives=objectives
    )

    # with Timer():
    analyze(
        experiment_path=experiment_path,
        params_in=parameters_in,
        params_out=objectives,
        sample_function=sample_supply_chain
    )

