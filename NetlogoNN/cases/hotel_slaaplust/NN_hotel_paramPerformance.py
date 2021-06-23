import sys
sys.path.append("../..")

from NetLogoSimulator import NetLogoSimulator
from NetLogoDataFitterNN import NetLogoDataFitterNN, DatasetCSV
from LinearNet import LinearNet, LinearNetTanh, LinearNetSoftmax, LinearNetRelu, LinearNetSigmoid
import torch
from matplotlib import pyplot as plt


def main():
    parametersOut = ["t1_loss", "t2_loss", "t3_loss", "unsatisfied_rate"]

    parametersInRange = {
            "receptionists_amount": [1, 500],
            "p_incoming_t1": [0.0, 1.0],
            "p_incoming_t3": [0.0, 1.0],
            "p_showup": [0.0, 1.0],
            "spread_factor": [0.1, 0.9],
            "satisfied_max_quetime": [1, 30],
            "checkin_max_quetime": [1, 30],
            "reservation_max_quetime": [1, 30],
            "noshow_max_time": [1, 10000],
            "t1_duration": [1, 100],
            "t2_duration": [1, 100],
            "t3_duration": [1, 100],
            "t4_duration": [1, 100],
            "t5_duration": [1, 100],
            "t6_duration": [1, 100],
            "spread_horizon": [1, 3600],
            "stay_duration": [1, 1000],
            "time_between_t1_and_t3": [1, 1000],
        }

    parametersIn = list(parametersInRange.keys())

    modelDefaultParameters = {
            "room_price": 10,
            "no_show_fine": 5,
        }

    folder = "data_out/3losses_merged/"

    testData = folder + "test.csv"

    def eval_MSE(lr, batch_size, max_iters, max_seconds):
        return NetLogoDataFitterNN(
            folder,
            parametersIn,
            parametersOut,
            LinearNetSigmoid(len(parametersIn), len(parametersOut)),
            tag="_ratio"
        ).fit(
            max_iters=max_iters,
            max_seconds=max_seconds,
            datasetTest=DatasetCSV(testData, parametersIn, parametersOut, cuda=False),
            lr=lr,
            batch_size=batch_size,
            printTestLabels=False)

    max_iters=10e7
    max_seconds=120
    plt.title("Various batch sizes and lr vs MSE, {} seconds".format(max_seconds))
    batch_sizes = [16, 32, 64, 128, 264]
    lr_arr = [0.1, 0.01, 0.001, 0.0001, 0.00001]
    filename = folder+"last_results.csv"

    with open(filename, "w") as file:
        file.write("lr, batch_size, MSE\n")
        for lr in lr_arr:
            y = []
            for b in batch_sizes:
                print("lr={}, b={}".format(lr, b))
                mse = eval_MSE(lr=lr, batch_size=b, max_iters=max_iters, max_seconds=max_seconds)
                y.append(mse)
                file.write("{},{},{}\n".format(lr, b, mse))
            plt.plot(batch_sizes, y, label="lr={}".format(lr))

    plt.xlabel("batch size")
    plt.ylabel("MSE")
    plt.grid()
    plt.legend(bbox_to_anchor=(1.0, -0.15), ncol=4)
    plt.subplots_adjust(bottom=0.3)
    plt.show()


if __name__ == "__main__":
    main()
