include "../mzn_nn/nn_Sigmoid_3layer.mzn";
include "restaurant_o.mzn";


set of int: Time = 1..1;

% buying strategy
array[Time] of var 1..10: buy1;
array[Time] of var 1..10: buy2;

% buying constraints
constraint forall(t in Time) (buy1[t] <= 8);
constraint forall(t in Time) (buy2[t] <= 9);

% soft constraint parameters
float: spoil_ratio_th;
float: succes_ratio_th;
int: spoil_ratio_w;
int: succes_ratio_w;

% predicates useful for definining soft constraints
predicate low_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] <= threshold);
predicate high_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] >= threshold);

% solve my means of the soft constraint defined in the .mbr file
solve minimize topLevelObjective;
