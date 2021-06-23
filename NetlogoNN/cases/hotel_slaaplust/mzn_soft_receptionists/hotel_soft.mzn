include "nn_ratio_1layer.mzn";
include "hotel_soft_o.mzn";

include "soft_constraints/cost_functions.mzn";

% hotel strategy planning over 4 seasons
% we consider 4 seasons
int: timespan;
set of int: Time = 1..timespan;

int: ticks_per_timeblock;

% price of room and no show fine
float: RoomPrice;
float: NoShowFine;

array[Time] of float: ReservationAverageStay;

% incoming reservations and checkins per minute
array[Time] of float: p_incoming_t1;
array[Time] of float: p_incoming_t3;
array[Time] of float: p_showup;
array[Time] of float: spread_factor;

array[Time] of int: satisfied_max_quetime;
array[Time] of int: checkin_max_quetime;
array[Time] of int: reservation_max_quetime;
array[Time] of int: noshow_max_time;
array[Time] of int: t1_duration;
array[Time] of int: t2_duration;
array[Time] of int: t3_duration;
array[Time] of int: t4_duration;
array[Time] of int: t5_duration;
array[Time] of int: t6_duration;
array[Time] of int: time_between_t1_and_t3;
array[Time] of int: stay_duration;
array[Time] of int: spread_horizon;

% how many receptionists we have is a decision variable
array[Time] of var 0..infinity: receptionists_amount;

% decision variable, indicating for transaction how often it occured
array[Time] of var 0.0..infinity: T1_successes;
array[Time] of var 0.0..infinity: T2_successes;
array[Time] of var 0.0..infinity: T3_successes;
array[Time] of var 0.0..infinity: T5_successes;

% for each T define what causes it to happen
constraint forall(t in Time) (T1_successes[t] = p_incoming_t1[t] * ticks_per_timeblock * (1-t1_loss[t]));
constraint forall(t in Time) (T2_successes[t] = (1-p_showup[t]) * T1_successes[t]);
constraint forall(t in Time) (T3_successes[t] = (p_incoming_t3[t] * ticks_per_timeblock + T1_successes[t] * p_showup[t]) * (1-t3_loss[t]));
constraint forall(t in Time) (T5_successes[t] = T3_successes[t]);


% define our profit
float: ReceptionistWage;

function var float: receptionistCosts() = sum([receptionists_amount[t] | t in Time]) * ReceptionistWage;
function var float: profitNoShowFines() = sum([T2_successes[t] * NoShowFine | t in Time]);
function var float: profitRoomsRented() = sum([T5_successes[t] * RoomPrice * ReservationAverageStay[t] | t in Time]);
function var float: profit() = profitNoShowFines() + profitRoomsRented() - receptionistCosts();

function var float: average(array[Time] of var float: array_in) = sum(array_in) / timespan;

var float: profit = profit();
constraint profit = profit;
var int: profit_rounded;
constraint profit_rounded <= profit + 0.5;
constraint profit_rounded >= profit - 0.5;

% solve my means of the soft constraint defined in hotel_soft.mbr
solve minimize topLevelObjective;
