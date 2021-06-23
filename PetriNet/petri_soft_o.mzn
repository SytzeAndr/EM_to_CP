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
function ann:  postGetBetter() = mbr_postGetBetter_ToWeighted_RefTo_cp1_();
function ann:  postNotGetWorse() = mbr_postNotGetWorse_ToWeighted_RefTo_cp1_();
var int: topLevelObjective;
constraint topLevelObjective = mbr_overall_ToWeighted_RefTo_cp1_;

% ---------------------------------------------------
%   PVS ToWeighted_RefTo_cp1_
% ---------------------------------------------------
% Parameters: 
int : mbr_nScs_ToWeighted_RefTo_cp1_ = 3; 
array[int, 1..2] of 1..mbr_nScs_ToWeighted_RefTo_cp1_ : mbr_crEdges_ToWeighted_RefTo_cp1_ = [|2, 1 | 3, 1|]; 
bool : mbr_useSPD_ToWeighted_RefTo_cp1_ = true; 
int : mbr_k_ToWeighted_RefTo_cp1_ = mbr_nScs_ToWeighted_RefTo_cp1_ * max(i in 1..mbr_nScs_ToWeighted_RefTo_cp1_) (mbr_weights_ToWeighted_RefTo_cp1_[i]) ; 
array[1..mbr_nScs_ToWeighted_RefTo_cp1_] of int : mbr_weights_ToWeighted_RefTo_cp1_ = calculate_cr_weights(mbr_nScs_ToWeighted_RefTo_cp1_, mbr_crEdges_ToWeighted_RefTo_cp1_, mbr_useSPD_ToWeighted_RefTo_cp1_); 

% Decision variables: 
var int: mbr_overall_ToWeighted_RefTo_cp1_;
array[1..mbr_nScs_ToWeighted_RefTo_cp1_] of var bool: mbr_valuations_ToWeighted_RefTo_cp1_;
int: mbr_top_ToWeighted_RefTo_cp1_ = 0;
constraint mbr_overall_ToWeighted_RefTo_cp1_ = weighted_sum (mbr_valuations_ToWeighted_RefTo_cp1_,mbr_nScs_ToWeighted_RefTo_cp1_, mbr_k_ToWeighted_RefTo_cp1_, mbr_weights_ToWeighted_RefTo_cp1_);

% MiniSearch predicates: 

% Soft constraints: 
constraint mbr_valuations_ToWeighted_RefTo_cp1_[1] = (forall(ti in 1..TimeMax-1 where T_executed[ti] = {})
(T_executed[ti+1] = {}));
constraint mbr_valuations_ToWeighted_RefTo_cp1_[2] = (P_value[P_objective_1, TimeMax] >= P_objective_1_min);
constraint mbr_valuations_ToWeighted_RefTo_cp1_[3] = (P_value[P_objective_2, TimeMax] >= P_objective_2_min);

function ann: mbr_postGetBetter_ToWeighted_RefTo_cp1_() = post(is_worse_weighted(sol(mbr_overall_ToWeighted_RefTo_cp1_), mbr_overall_ToWeighted_RefTo_cp1_, mbr_nScs_ToWeighted_RefTo_cp1_, mbr_k_ToWeighted_RefTo_cp1_, mbr_weights_ToWeighted_RefTo_cp1_));

function ann: mbr_postNotGetWorse_ToWeighted_RefTo_cp1_() = post(not ( (sol(mbr_overall_ToWeighted_RefTo_cp1_) = mbr_overall_ToWeighted_RefTo_cp1_) \/ (is_worse_weighted(mbr_overall_ToWeighted_RefTo_cp1_, sol(mbr_overall_ToWeighted_RefTo_cp1_), mbr_nScs_ToWeighted_RefTo_cp1_, mbr_k_ToWeighted_RefTo_cp1_, mbr_weights_ToWeighted_RefTo_cp1_))));
output ["executed transactions:\n"] ++ ["\(ti): \(T_executed[ti])\n" | ti in Time] ++ ["\n"] ++
["t:\t"] ++ ["\(t)\t" | t in Time] ++
[if t=1 then "\n\(p):\t" else "" endif ++ "\(P_value[p, t])\t" | p in P, t in Time] ++ [ "\nValuations: mbr_overall_ToWeighted_RefTo_cp1_ = \(mbr_overall_ToWeighted_RefTo_cp1_)\n"];

