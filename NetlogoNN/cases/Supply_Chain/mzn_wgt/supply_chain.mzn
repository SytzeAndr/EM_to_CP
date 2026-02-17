include "../mzn_nn/Supply_Chain_a-sigmoid_l-4_s-300_o-3_d-halton.mzn";
include "../../shared/weighted_objectives.mzn";

% set params
int: Clients_N = 1300;
int: Demand_W = 10;
int: Lt0 = 4;
int: Lt1 = 4;
float: SS_ = 0.85;
int: DS_D = 7;
int: K = 200;
float: MA = 500;
float: HC = 0.05;

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

% custom constraints
constraint (Distr1 <= Fact * 6);
constraint (Distr2 <= Distr1 * 4);
constraint (Clients_N <= Distr2 * 50);

% define top level objective
num_objectives = 3;

constraint objectives = [
  -lost_ratio_sales_fac, 
  -lost_ratio_sales_dis, 
  -lost_ratio_sales_ret
];

% % define top level objective
% num_objectives = 7;

% constraint objectives = [
%   -lost_ratio_sales_fac, 
%   -lost_ratio_sales_dis, 
%   -lost_ratio_sales_ret,
%   stock_customer_MA_mean_relative,
%   stock_distributor_MA_mean_relative,
%   stock_retailer_MA_mean_relative,
%   -stock_factory_MA_mean_relative
% ];

% output in json format
output ["{\"Fact\": \(Fact), \"Distr1\": \(Distr1), \"Distr2\": \(Distr2), \"lost_ratio_sales_fac\": \(lost_ratio_sales_fac), \"lost_ratio_sales_dis\": \(lost_ratio_sales_dis), \"v1_DailyPurchase\": \(v1_DailyPurchase), \"v2_PeriodicallyPurchase\": \(v2_PeriodicallyPurchase), \"v3_Random\": \(v3_Random), \"v1_s_Q\": \(v1_s_Q), \"v2_s_S\": \(v2_s_S), \"v3_R_S\": \(v3_R_S), \"v4_Random\": \(v4_Random), \"lost_ratio_sales_ret\": \(lost_ratio_sales_ret)}"]
% + [" ,\"stock_customer_MA_mean_relative\": \(stock_customer_MA_mean_relative), \"stock_distributor_MA_mean_relative\": \(stock_distributor_MA_mean_relative), \"stock_retailer_MA_mean_relative\": \(stock_retailer_MA_mean_relative), \"stock_factory_MA_mean_relative\": \(stock_factory_MA_mean_relative)"
;
