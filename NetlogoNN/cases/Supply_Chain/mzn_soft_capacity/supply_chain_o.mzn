% ===============================================
% Generated code from MiniBrass, do not modify!
include "soft_constraints/mbr_types/probabilistic_type.mzn";
include "soft_constraints/mbr_types/fuzzy_type.mzn";
include "soft_constraints/mbr_types/relation-type.mzn";
include "soft_constraints/mbr_types/bool-type.mzn";
include "soft_constraints/mbr_types/cfn_type.mzn";
include "soft_constraints/mbr_types/weighted_type.mzn";
include "soft_constraints/mbr_types/cr_type.mzn";
include "soft_constraints/mbr_types/free-pvs-type.mzn";

% ---------------------------------------------------
% Overall exported predicate (and objective in case of atomic top-level PVS) : 

% ---------------------------------------------------
var int: topLevelObjective;
constraint topLevelObjective = mbr_overall_wght;

% ---------------------------------------------------
%   PVS wght
% ---------------------------------------------------
% Parameters: 
int : mbr_nScs_wght = 7; 
int : mbr_k_wght = 1000; 
array[1..mbr_nScs_wght] of int : mbr_weights_wght = [lost_ratio_sales_ret_w, lost_ratio_sales_dis_w, lost_ratio_sales_fac_w, stock_customer_MA_mean_relative_w, stock_distributor_MA_mean_relative_w, stock_retailer_MA_mean_relative_w, stock_factory_MA_mean_relative_w]; 

% Decision variables: 
var int: mbr_overall_wght;
array[1..mbr_nScs_wght] of var bool: mbr_valuations_wght;
int: mbr_top_wght = 0;
constraint mbr_overall_wght = weighted_sum (mbr_valuations_wght,mbr_nScs_wght, mbr_k_wght, mbr_weights_wght);

% Soft constraints: 
constraint mbr_valuations_wght[1] = (low_ratio_harsh(lost_ratio_sales_ret, lost_ratio_sales_ret_th));
constraint mbr_valuations_wght[2] = (low_ratio_harsh(lost_ratio_sales_dis, lost_ratio_sales_dis_th));
constraint mbr_valuations_wght[3] = (low_ratio_harsh(lost_ratio_sales_fac, lost_ratio_sales_fac_th));
constraint mbr_valuations_wght[4] = (high_ratio_harsh(stock_customer_MA_mean_relative, stock_customer_MA_mean_relative_th));
constraint mbr_valuations_wght[5] = (high_ratio_harsh(stock_distributor_MA_mean_relative, stock_distributor_MA_mean_relative_th));
constraint mbr_valuations_wght[6] = (high_ratio_harsh(stock_retailer_MA_mean_relative, stock_retailer_MA_mean_relative_th));
constraint mbr_valuations_wght[7] = (low_ratio_harsh(stock_factory_MA_mean_relative, stock_factory_MA_mean_relative_th));
output 
["\(Fact[1]), \(Distr1[1]), \(Distr2[1])"] ++
[", \(v1_DailyPurchase[1]), \(v2_PeriodicallyPurchase[1]), \(v3_Random[1])"] ++
[", \(v1_s_Q[1]), \(v2_s_S[1]), \(v3_R_S[1]), \(v4_Random[1])"] ++
[", \(lost_ratio_sales_ret[1]), \(lost_ratio_sales_dis[1]), \(lost_ratio_sales_fac[1])"] ++
[", \(stock_customer_MA_mean_relative[1]), \(stock_distributor_MA_mean_relative[1]), \(stock_retailer_MA_mean_relative[1]), \(stock_factory_MA_mean_relative[1])"]
 ++ [ "\nValuations: mbr_overall_wght = \(mbr_overall_wght)\n"];

