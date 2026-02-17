
% number between 0.0 and 1.0 that indicates how much possible float outcomes we allow
% considering the corresponding value is constrained between 0.0 and 1.0
% int: discrete_values = 50;
% var float: discretize_step;
% constraint (discretize_step * discrete_values = 1) ;

float: discretize_step = 0.01;

% example usage for variable x:
% var int: x_int;
% constraint (x = x_int * discretize_step);

% lost_ratio_sales_ret
var 0..infinity: lost_ratio_sales_ret_int;
constraint (lost_ratio_sales_ret = lost_ratio_sales_ret_int * discretize_step);

% lost_ratio_sales_fac;
% var int: lost_ratio_sales_fac_int;
% constraint (lost_ratio_sales_fac = lost_ratio_sales_fac_int * discretize_step);

% stock_customer_MA_mean_relative;
% var int: stock_customer_MA_mean_relative_int;
% constraint (stock_customer_MA_mean_relative = stock_customer_MA_mean_relative_int * discretize_step);

% % stock_distributor_MA_mean_relative;
% var int: stock_distributor_MA_mean_relative_int;
% constraint (stock_distributor_MA_mean_relative = stock_distributor_MA_mean_relative_int * discretize_step);

% % stock_retailer_MA_mean_relative;
% var int: stock_retailer_MA_mean_relative_int;
% constraint (stock_retailer_MA_mean_relative = stock_retailer_MA_mean_relative_int * discretize_step);

% % stock_factory_MA_mean_relative;
% var int: stock_factory_MA_mean_relative_int;
% constraint (stock_factory_MA_mean_relative = stock_factory_MA_mean_relative_int * discretize_step);