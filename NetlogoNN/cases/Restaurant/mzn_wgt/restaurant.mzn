
include "../mzn_nn/nn_Sigmoid_5layer.mzn";
include "../../shared/weighted_objectives.mzn";

% buying strategy
var 1..9: buy1;
var 1..9: buy2;

% define objective. Use minus sign for minimization objectives
% we want each objective to be in range 0..1
num_objectives = 2;
constraint objectives = [success_ratio, -spoil_ratio];

% define what to print in json format
output ["{\"buy1\": \(buy1), \"buy2\": \(buy2), \"spoil_ratio\": \(spoil_ratio), \"success_ratio\": \(success_ratio)}"];
