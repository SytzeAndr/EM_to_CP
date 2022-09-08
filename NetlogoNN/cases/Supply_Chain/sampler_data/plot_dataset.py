
import pandas as pd
import matplotlib.pyplot as plt

if __name__ == "__main__":
    def plot_by_sampler_tag(sampler, limit=None):
        df_path = f"{sampler}/data_out.csv"
        columns = ["Distr2", "Clients_N"]
        df = pd.read_csv(df_path)
        if limit is not None:
            df = df[:limit]
        df.plot.scatter(x=columns[0], y=columns[1])
        plt.title(f"{sampler}\nn={len(df)}")
        plt.savefig(f"../plots/{sampler}_{len(df)}.png")
        plt.show()

    limit = 200
    plot_by_sampler_tag("halton", limit=limit)
    plot_by_sampler_tag("sobol", limit=limit)
    plot_by_sampler_tag("uniform", limit=limit)

    limit = 500
    plot_by_sampler_tag("halton", limit=limit)
    plot_by_sampler_tag("sobol", limit=limit)
    plot_by_sampler_tag("uniform", limit=limit)

    limit = 1000
    plot_by_sampler_tag("halton", limit=limit)
    plot_by_sampler_tag("sobol", limit=limit)
    plot_by_sampler_tag("uniform", limit=limit)

    limit = 2000
    plot_by_sampler_tag("halton", limit=limit)
    plot_by_sampler_tag("sobol", limit=limit)
    plot_by_sampler_tag("uniform", limit=limit)
