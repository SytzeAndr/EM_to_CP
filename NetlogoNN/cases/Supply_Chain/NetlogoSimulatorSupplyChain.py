

# from NetlogoNN import NetlogoSimulatorQmcSobol

# import EM_to_CP.NetlogoNN.ParameterSampler as ParameterSampler
# from EM_to_CP.NetlogoNN.NetLogoSimulator import NetLogoSimulator

# from ...ParameterSampler import ParameterSampler
# from ...NetLogoSimulator import NetLogoSimulator

import sys
import os
sys.path.append(
    os.path.join(
        os.path.dirname(__file__),
        "../../../../"
    )
)

from EM_to_CP.NetlogoNN import ParameterSamplerSobol, ParameterSamplerHalton, ParameterSamplerUniform, NetLogoSimulator


class NetlogoSimulatorSupplyChain(NetLogoSimulator):
    def __init__(self, parameter_sampler_constructor, tag):
        model_filename = "Supply_Chain.nlogo"

        parameters_out = [
            "lost_ratio_sales_ret",
            "lost_ratio_sales_dis",
            "lost_ratio_sales_fac",
            "stock_customer_MA_mean_relative",
            "stock_distributor_MA_mean_relative",
            "stock_retailer_MA_mean_relative",
            "stock_factory_MA_mean_relative"
        ]

        parameters_in_range = {
            "Fact": [1, 3],
            "Distr1": [1, 10],  # need scaling
            "Distr2": [1, 40],  # need scaling
            "Clients_N": [1, 1500],  # need scaling
            "Demand_W": [1, 15],
            "HC": [0.01, 0.1],
            "Lt0": [4],  # [0, 7], # fix?
            "Lt1": [4],  # [0, 7], # fix?
            "SS_%": [0.85],  # [0.5, 0.95], # fix?
            "DS_D": [0, 15],
            "K": [200],  # fix?
            "MA": [500],
            "Customers_Strategy": ["1-DailyPurchase", "2-PeriodicallyPurchase", "3-Random"],
            "Inventory_Policy": ["1-(s,Q)", "2-(s,S)", "3-(R,S)", "4-Random"],
        }

        parameters_default = {}

        super(NetlogoSimulatorSupplyChain, self).__init__(
            simulationParameterInRange=parameters_in_range,
            simulationParameterOut=parameters_out,
            modelDefaultParameters=parameters_default,
            modelFilename=model_filename,
            parameter_sampler_constructor=parameter_sampler_constructor,
            tag=tag
        )


def run(amount, sampler, log_folder=None):
    netlogo_simulator = NetlogoSimulatorSupplyChain(
        parameter_sampler_constructor=sampler,
        tag="supply_chain_sobol"
    )
    netlogo_simulator.run(
        randomParametersCount=amount,
        simulationTicks=3000,
        log_folder=log_folder,
        timeoutRestartTime=600,
        num_workers=None
    )


if __name__=="__main__":
    # run_qmd_sobol(10)
    run(1000, ParameterSamplerHalton, log_folder="data_out/supply_chain_halton_v3")
    run(1000, ParameterSamplerUniform, log_folder="data_out/supply_chain_uniform_v3")
    run(1000, ParameterSamplerSobol, log_folder="data_out/supply_chain_sobol_v3")
