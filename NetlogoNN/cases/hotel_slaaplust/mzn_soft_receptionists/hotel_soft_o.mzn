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
var set of 1..mbr_nScs_cp1: topLevelObjective;
constraint topLevelObjective = mbr_overall_cp1;

% ---------------------------------------------------
%   PVS cp1
% ---------------------------------------------------
% Parameters: 
int : mbr_nScs_cp1 = 4; 
array[int, 1..2] of 1..mbr_nScs_cp1 : mbr_crEdges_cp1 = [|2, 1|]; 
bool : mbr_useSPD_cp1 = false; 

% Decision variables: 
var set of 1..mbr_nScs_cp1: mbr_overall_cp1;
array[1..mbr_nScs_cp1] of var bool: mbr_valuations_cp1;
set of 1..mbr_nScs_cp1: mbr_top_cp1 = {};
constraint mbr_overall_cp1 = link_invert_booleans (mbr_valuations_cp1,mbr_nScs_cp1, mbr_crEdges_cp1, mbr_useSPD_cp1);

% Soft constraints: 
constraint mbr_valuations_cp1[1] = (unsatisfied_rate[1] <= 0.9);
constraint mbr_valuations_cp1[2] = (t1_loss[1] <= 0.2);
constraint mbr_valuations_cp1[3] = (t2_loss[1] <= 0.2);
constraint mbr_valuations_cp1[4] = (t3_loss[1] <= 0.2);
output ["profit (rounded): \(profit_rounded)"] ++
["\nreceptionists: \(receptionists_amount)"] ++ ["\n"] ++
[if t=1 then "\nt1_loss_x\n" else "" endif ++ "\(t): \(t1_loss[t])\n" | t in Time] ++
[if t=1 then "\nt2_loss_x\n" else "" endif ++ "\(t): \(t2_loss[t])\n" | t in Time] ++
[if t=1 then "\nt3_loss_x\n" else "" endif ++ "\(t): \(t3_loss[t])\n" | t in Time] ++
[if t=1 then "\nunsatisfied_rate\n" else "" endif ++ "\(t): \(unsatisfied_rate[t])\n" | t in Time] ++ [ "\nValuations: mbr_overall_cp1 = \(mbr_overall_cp1)\n"];

