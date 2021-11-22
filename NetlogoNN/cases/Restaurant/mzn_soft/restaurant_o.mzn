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
int : mbr_nScs_wght = 2; 
int : mbr_k_wght = 1000; 
array[1..mbr_nScs_wght] of int : mbr_weights_wght = [spoil_ratio_w, succes_ratio_w]; 

% Decision variables: 
var int: mbr_overall_wght;
array[1..mbr_nScs_wght] of var bool: mbr_valuations_wght;
int: mbr_top_wght = 0;
constraint mbr_overall_wght = weighted_sum (mbr_valuations_wght,mbr_nScs_wght, mbr_k_wght, mbr_weights_wght);

% Soft constraints: 
constraint mbr_valuations_wght[1] = (low_ratio_harsh(spoil_ratio, spoil_ratio_th));
constraint mbr_valuations_wght[2] = (high_ratio_harsh(succes_ratio, succes_ratio_th));
output 
["\(buy1[1]), \(buy2[1]), "] ++
["\(spoil_ratio[1]), \(succes_ratio[1])"]
 ++ [ "\nValuations: mbr_overall_wght = \(mbr_overall_wght)\n"];

