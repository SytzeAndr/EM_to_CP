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
int : mbr_nScs_wght = 9; 
int : mbr_k_wght = 1000; 
array[1..mbr_nScs_wght] of int : mbr_weights_wght = [mean_strength_w, mean_speed_w, mean_intelligence_w, murder_rate_w, age_death_rate_w, starvation_rate_w, mean_reactive_aggression_w, mean_proactive_aggression_w, average_population_w]; 

% Decision variables: 
var int: mbr_overall_wght;
array[1..mbr_nScs_wght] of var bool: mbr_valuations_wght;
int: mbr_top_wght = 0;
constraint mbr_overall_wght = weighted_sum (mbr_valuations_wght,mbr_nScs_wght, mbr_k_wght, mbr_weights_wght);

% Soft constraints: 
constraint mbr_valuations_wght[1] = (low_ratio_harsh(mean_strength, mean_strength_th));
constraint mbr_valuations_wght[2] = (high_ratio_harsh(mean_speed, mean_speed_th));
constraint mbr_valuations_wght[3] = (high_ratio_harsh(mean_intelligence, mean_intelligence_th));
constraint mbr_valuations_wght[4] = (low_ratio_harsh(murder_rate, murder_rate_th));
constraint mbr_valuations_wght[5] = (high_ratio_harsh(age_death_rate, age_death_rate_th));
constraint mbr_valuations_wght[6] = (high_ratio_harsh(starvation_rate, starvation_rate_th));
constraint mbr_valuations_wght[7] = (high_ratio_harsh(mean_reactive_aggression, mean_reactive_aggression_th));
constraint mbr_valuations_wght[8] = (low_ratio_harsh(mean_proactive_aggression, mean_proactive_aggression_th));
constraint mbr_valuations_wght[9] = (high_ratio_harsh(average_population, average_population_th));
output 
["\(collaboration_bonus[1]), \(max_age[1]), "] ++
["\(mean_strength[1]), \(mean_speed[1]), \(mean_intelligence[1]), "] ++
["\(murder_rate[1]), \(age_death_rate[1]), \(starvation_rate[1]), "] ++
["\(mean_reactive_aggression[1]), \(mean_proactive_aggression[1]), "] ++
["\(average_population[1])"]
 ++ [ "\nValuations: mbr_overall_wght = \(mbr_overall_wght)\n"];

