
include "supply_chain_o.mzn";
% include "../mzn_nn/nn_sigmoid_4layer.mzn";
include "../mzn_nn/nn_outSupply_Chain.mzn";

int: timespan;
set of int: Time = 1..timespan;

% set params
array[Time] of int: Fact;
array[Time] of int: Distr1;
array[Time] of int: Distr2;
array[Time] of int: Clients_N;
array[Time] of int: Demand_W;
array[Time] of int: Lt0;
array[Time] of int: Lt1;
array[Time] of float: SS_;
array[Time] of int: DS_D;
array[Time] of int: K;
array[Time] of float: MA;

% variable params
array[Time] of var 0.01..0.1: HC;
array[Time] of var int: HC_int;
constraint forall(t in Time) (HC_int[t] * 0.0001 = HC[t]);

% inventory and buy strategies
array[Time] of var 0..1: v1_DailyPurchase;
array[Time] of var 0..1: v2_PeriodicallyPurchase;
array[Time] of var 0..1: v3_Random;
array[Time] of var 0..1: v1_s_Q;
array[Time] of var 0..1: v2_s_S;
array[Time] of var 0..1: v3_R_S;
array[Time] of var 0..1: v4_Random;

% only one strategy is allowed
constraint forall(t in Time) (v1_DailyPurchase[t] + v2_PeriodicallyPurchase[t] + v3_Random[t] = 1);
constraint forall(t in Time) (v1_s_Q[t] + v2_s_S[t] + v3_R_S[t] + v4_Random[t] = 1);

% thresholds and weights
float: lost_ratio_sales_ret_th;
int: lost_ratio_sales_ret_w;
float: lost_ratio_sales_dis_th;
int: lost_ratio_sales_dis_w;
float: lost_ratio_sales_fac_th;
int: lost_ratio_sales_fac_w;
float: stock_customer_MA_mean_relative_th;
int: stock_customer_MA_mean_relative_w;
float: stock_distributor_MA_mean_relative_th;
int: stock_distributor_MA_mean_relative_w;
float: stock_retailer_MA_mean_relative_th;
int: stock_retailer_MA_mean_relative_w;
float: stock_factory_MA_mean_relative_th;
int: stock_factory_MA_mean_relative_w;

predicate low_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] <= threshold);
predicate high_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] >= threshold);

solve minimize topLevelObjective;