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
int : mbr_nScs_wght = 4; 
int : mbr_k_wght = 1000; 
array[1..mbr_nScs_wght] of int : mbr_weights_wght = [low_t1_loss_w, low_t2_loss_w, low_t3_loss_w, low_unsatisfied_w]; 

% Decision variables: 
var int: mbr_overall_wght;
array[1..mbr_nScs_wght] of var bool: mbr_valuations_wght;
int: mbr_top_wght = 0;
constraint mbr_overall_wght = weighted_sum (mbr_valuations_wght,mbr_nScs_wght, mbr_k_wght, mbr_weights_wght);

% Soft constraints: 
constraint mbr_valuations_wght[1] = (low_ratio_harsh(t1_loss, low_t1_loss_th));
constraint mbr_valuations_wght[2] = (low_ratio_harsh(t2_loss, low_t2_loss_th));
constraint mbr_valuations_wght[3] = (low_ratio_harsh(t3_loss, low_t3_loss_th));
constraint mbr_valuations_wght[4] = (low_ratio_harsh(unsatisfied_rate, low_unsatisfied_th));
output 
["\(low_t1_loss_th), \(low_t1_loss_w), \(low_t2_loss_th), \(low_t2_loss_w), \(low_t3_loss_th), \(low_t3_loss_w), \(low_unsatisfied_th), \(low_unsatisfied_w)"] ++ [", \(t1_change_a), \(t2_change_a), \(t3_change_a)"] ++ [", \(t1_loss[1]), \(t2_loss[1]), \(t3_loss[1]), \(unsatisfied_rate[1])"]
 ++ [ "\nValuations: mbr_overall_wght = \(mbr_overall_wght)\n"];

