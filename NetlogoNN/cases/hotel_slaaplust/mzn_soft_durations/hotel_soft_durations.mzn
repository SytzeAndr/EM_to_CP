% include "../mzn_nn/nn_ratio_1layer.mzn";
include "../mzn_nn/nn_Sigmoid_4layer.mzn";
include "hotel_soft_durations_o.mzn";

% hotel strategy planning over 4 seasons
% we consider 4 seasons
int: timespan;
set of int: Time = 1..timespan;

% incoming reservations and checkins per minute
array[Time] of float: p_incoming_t1;
array[Time] of float: p_incoming_t3;
array[Time] of float: p_showup;
array[Time] of float: spread_factor;

array[Time] of int: satisfied_max_quetime;
array[Time] of int: checkin_max_quetime;
array[Time] of int: reservation_max_quetime;
array[Time] of int: noshow_max_time;

array[Time] of int: time_between_t1_and_t3;
array[Time] of int: stay_duration;
array[Time] of int: spread_horizon;

% how many receptionists we have (not considered a variable)
array[Time] of int: receptionists_amount;

array[Time] of int: t1_dur_raw;
array[Time] of int: t2_dur_raw;
array[Time] of int: t3_dur_raw;
array[Time] of int: t4_dur_raw;
array[Time] of int: t5_dur_raw;
array[Time] of int: t6_dur_raw;

% durations for the transactions
array[Time] of var 0.0..infinity: t1_duration;
array[Time] of var 0.0..infinity: t2_duration;
array[Time] of var 0.0..infinity: t3_duration;
array[Time] of var 0.0..infinity: t4_duration;
array[Time] of var 0.0..infinity: t5_duration;
array[Time] of var 0.0..infinity: t6_duration;

% soft constraint parameters
float: low_t1_loss_th;
int: low_t1_loss_w;

float: low_t2_loss_th;
int: low_t2_loss_w;

float: low_t3_loss_th;
int: low_t3_loss_w;

float: low_unsatisfied_th;
int: low_unsatisfied_w;

% Change duration of t1 at the cost of t3
var float: t1_change_a;
var int: t1_change_int_a;
var float: t1_change_b;
float: t1_w;
float: t1_max_relative_change;
constraint t1_change_a = t1_change_int_a * 0.1;
constraint t1_change_a >= t1_dur_raw[1] * (1 - t1_max_relative_change);
constraint t1_change_a <= t1_dur_raw[1] * (1 + t1_max_relative_change);
var int: t1_increased = bool2int(t1_change_a > 0);
constraint (t1_change_b = -t1_change_a * (t1_w * t1_increased + (1 / t1_w) * (1 - t1_increased)));

% Change duration of t1 at the cost of t6
var float: t2_change_a;
var int: t2_change_int_a;
var float: t2_change_b;
float: t2_w;
float: t2_max_relative_change;
constraint t2_change_a = t2_change_int_a * 0.1;
constraint t2_change_a >= t1_dur_raw[1] * (1 - t2_max_relative_change);
constraint t2_change_a <= t1_dur_raw[1] * (1 + t2_max_relative_change);
var int: t2_increased = bool2int(t2_change_a > 0);
constraint (t2_change_b = -t2_change_a * (t2_w * t2_increased + (1 / t2_w) * (1 - t2_increased)));

% Change duration of t3 at the cost of t4
var float: t3_change_a;
var int: t3_change_int_a;
var float: t3_change_b;
float: t3_w;
float: t3_max_relative_change;
constraint t3_change_a = t3_change_int_a * 0.1;
constraint t3_change_a >= t3_dur_raw[1] * (1 - t3_max_relative_change);
constraint t3_change_a <= t3_dur_raw[1] * (1 + t3_max_relative_change);
var int: t3_increased = bool2int(t3_change_a > 0);
constraint (t3_change_b = -t3_change_a * (t3_w * t3_increased + (1 / t3_w) * (1 - t3_increased)));


constraint forall(t in Time) (t1_duration[t] = t1_dur_raw[t] + t1_change_a + t2_change_a);
constraint forall(t in Time) (t2_duration[t] = t2_dur_raw[t]);
constraint forall(t in Time) (t3_duration[t] = t3_dur_raw[t] + t1_change_b + t3_change_a);
constraint forall(t in Time) (t4_duration[t] = t4_dur_raw[t] + t3_change_b);
constraint forall(t in Time) (t5_duration[t] = t5_dur_raw[t]);
constraint forall(t in Time) (t6_duration[t] = t6_dur_raw[t] + t2_change_b);

% predicates useful for definining soft constraints
predicate low_ratio_harsh(array[Time] of var 0.0..1.0: value, float: threshold) = forall(t in Time) (value[t] <= threshold);
predicate low_ratio_mean(array[Time] of var 0.0..1.0: value, float: threshold) = sum([value[t] | t in Time]) <= threshold * timespan;

% solve my means of the soft constraint defined in the .mbr file
% random restart is not supported by jacop. Maybe it is by minisearch?
solve minimize topLevelObjective;
