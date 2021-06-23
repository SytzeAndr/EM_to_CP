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
constraint topLevelObjective = mbr_overall_ToWeighted_RefTo_cp1_;

% ---------------------------------------------------
%   PVS ToWeighted_RefTo_cp1_
% ---------------------------------------------------
% Parameters: 
int : mbr_nScs_ToWeighted_RefTo_cp1_ = 5; 
array[int, 1..2] of 1..mbr_nScs_ToWeighted_RefTo_cp1_ : mbr_crEdges_ToWeighted_RefTo_cp1_ = [|2, 1 | 3, 1|]; 
bool : mbr_useSPD_ToWeighted_RefTo_cp1_ = false; 
int : mbr_k_ToWeighted_RefTo_cp1_ = mbr_nScs_ToWeighted_RefTo_cp1_ * max(i in 1..mbr_nScs_ToWeighted_RefTo_cp1_) (mbr_weights_ToWeighted_RefTo_cp1_[i]) ; 
array[1..mbr_nScs_ToWeighted_RefTo_cp1_] of int : mbr_weights_ToWeighted_RefTo_cp1_ = calculate_cr_weights(mbr_nScs_ToWeighted_RefTo_cp1_, mbr_crEdges_ToWeighted_RefTo_cp1_, mbr_useSPD_ToWeighted_RefTo_cp1_); 

% Decision variables: 
var int: mbr_overall_ToWeighted_RefTo_cp1_;
array[1..mbr_nScs_ToWeighted_RefTo_cp1_] of var bool: mbr_valuations_ToWeighted_RefTo_cp1_;
int: mbr_top_ToWeighted_RefTo_cp1_ = 0;
constraint mbr_overall_ToWeighted_RefTo_cp1_ = weighted_sum (mbr_valuations_ToWeighted_RefTo_cp1_,mbr_nScs_ToWeighted_RefTo_cp1_, mbr_k_ToWeighted_RefTo_cp1_, mbr_weights_ToWeighted_RefTo_cp1_);

% Soft constraints: 
constraint mbr_valuations_ToWeighted_RefTo_cp1_[1] = (forall(t in Time) (mean_reactive_aggression[t] >= mean_proactive_aggression[t]));
constraint mbr_valuations_ToWeighted_RefTo_cp1_[2] = (forall(t in Time) (starvation_rate[t] >= murder_rate[t]));
constraint mbr_valuations_ToWeighted_RefTo_cp1_[3] = (forall(t in Time) (age_death_rate[t] >= murder_rate[t]));
constraint mbr_valuations_ToWeighted_RefTo_cp1_[4] = (forall(t in Time) (collaboration_bonus[t] <= 3));
constraint mbr_valuations_ToWeighted_RefTo_cp1_[5] = (forall(t in Time) (max_age[t] >= 200));
output ["Collab Bonus: "] ++ ["\(collaboration_bonus[t])," | t in Time ] ++ [ "\nValuations: mbr_overall_ToWeighted_RefTo_cp1_ = \(mbr_overall_ToWeighted_RefTo_cp1_)\n"];

