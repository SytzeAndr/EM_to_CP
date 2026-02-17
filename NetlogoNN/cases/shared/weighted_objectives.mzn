% initialize number of objectives
int: num_objectives;
set of int: OBJECTIVE = 1..num_objectives;
array[OBJECTIVE] of var float: objectives;

% initialize weights
array[OBJECTIVE] of float: weights;

% % compose top level objective
var float: top_level_objective;
constraint top_level_objective = sum([weights[o] * objectives[o] | o in OBJECTIVE]);

% solve maximize objective;
solve maximize top_level_objective;
