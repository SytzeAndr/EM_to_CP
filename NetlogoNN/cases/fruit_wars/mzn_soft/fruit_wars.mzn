% Use this editor as a MiniZinc scratch book

% include "nn_out_aggression.mzn";
% include "nn_out_deaths.mzn";
% include "nn_out_pop.mzn";
% include "nn_out_traits.mzn";
% include "fruit_wars_weighted_o.mzn";
include "fruit_wars_o.mzn";
include "../mzn_nn/nn_sigmoid_4layer.mzn";
include "../mzn_nn/nn_relu_4layer.mzn";
% include "mzn_nn/nn_relu_3layer.mzn";

int: timespan;
set of int: Time = 1..timespan;

% we simulate a social system and are interested how to make it more peaceful

% suppose we are able to set a collaboration bonus
array[Time] of var 0.1..5.0: collaboration_bonus;
array[Time] of var int: collaboration_bonus_int;
constraint forall(t in Time) (collaboration_bonus[t] = collaboration_bonus_int[t] * 0.1);

% and also have some influence on the max age, f.e. based on healthcare we provide
array[Time] of var 50..300: max_age;
% array[Time] of int: max_age;

% the amount of food is limited though
array[Time] of int: initial_fruit_bushes;
array[Time] of int: initial_foragers;
array[Time] of int: ticks_to_flee;
array[Time] of int: bush_growth_chance;
array[Time] of float: rate_of_mutation;

% soft constraint parameters
float: mean_strength_th;
int: mean_strength_w;
float: mean_speed_th;
int: mean_speed_w;
float: mean_intelligence_th;
int: mean_intelligence_w;
float: murder_rate_th;
int: murder_rate_w;
float: age_death_rate_th;
int: age_death_rate_w;
float: starvation_rate_th;
int: starvation_rate_w;
float: mean_reactive_aggression_th;
int: mean_reactive_aggression_w;
float: mean_proactive_aggression_th;
int: mean_proactive_aggression_w;
int: average_population_th;
int: average_population_w;

predicate low_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] <= threshold);
predicate high_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] >= threshold);

solve minimize topLevelObjective;
% solve minimize sum(collaboration_bonus);
