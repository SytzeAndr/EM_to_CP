% include "nn/nn_2layer_Supply_Chain_halton_pow2.mzn";
include "../data_out/supply_chain_halton_v3/nn_2layer_Supply_Chain_halton_pow2.mzn";
include "pareto_mo.mzn";

% include "supply_chain_output_discretize.mzn";

% include "globals.mzn";

% set params
int: Clients_N;
int: Demand_W;
int: Lt0;
int: Lt1;
float: SS_;
int: DS_D;
int: K;
float: MA;
float: HC;

% variable params
var 1..3: Fact;
var 1..10: Distr1;
var 1..40: Distr2;

% inventory and buy strategies
var 0..1: v1_DailyPurchase;
var 0..1: v2_PeriodicallyPurchase;
var 0..1: v3_Random;
var 0..1: v1_s_Q;
var 0..1: v2_s_S;
var 0..1: v3_R_S;
var 0..1: v4_Random;

% only one strategy is allowed
constraint (v1_DailyPurchase + v2_PeriodicallyPurchase + v3_Random = 1);
constraint (v1_s_Q + v2_s_S + v3_R_S + v4_Random = 1);

% max values
constraint (Distr1 <= Fact * 6);
constraint (Distr2 <= Distr1 * 4);
% constraint (Clients_N <= Distr2 * 50);

% solve satisfy;
% solve :: goals_p([minimize_p(lost_ratio_sales_ret), minimize_p(lost_ratio_sales_dis), minimize_p(lost_ratio_sales_fac), maximize_p(stock_customer_MA_mean_relative), maximize_p(stock_distributor_MA_mean_relative), maximize_p(stock_retailer_MA_mean_relative), minimize_p(stock_factory_MA_mean_relative)]) satisfy;

% 3 objectives
solve :: goals_p([minimize_p(lost_ratio_sales_ret), minimize_p(lost_ratio_sales_dis), minimize_p(lost_ratio_sales_fac)]) satisfy;

% 2 objectives
% solve :: goals_p([minimize_p(lost_ratio_sales_ret), minimize_p(lost_ratio_sales_dis)]) satisfy;

% 1 objective
% solve :: goals_p([minimize_p(lost_ratio_sales_ret)]) satisfy;

% stress test
% solve minimize lost_ratio_sales_ret;

output
["\(Fact), \(Distr1), \(Distr2)"] ++
[", \(v1_DailyPurchase), \(v2_PeriodicallyPurchase), \(v3_Random)"] ++
[", \(v1_s_Q), \(v2_s_S), \(v3_R_S), \(v4_Random)"] ++
[", \(lost_ratio_sales_ret), \(lost_ratio_sales_dis), \(lost_ratio_sales_fac)"]
;
