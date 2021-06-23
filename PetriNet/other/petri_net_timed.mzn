% simple timed petri net

%%%% parameters %%%%

% places
enum P;

% transactions and their duration
enum T;
array[T] of int: T_duration;

% arcs n (flow relations)

% F_to ~ flow is going TO a transaction (from a place)
enum F_to;
array[F_to] of P: F_to_in;
array[F_to] of T: F_to_out;

% F_from ~ flow is coming FROM a transaction (to a place)
enum F_from;
array[F_from] of T: F_from_in;
array[F_from] of P: F_from_out;

% initial configuration
array[F_to] of int: F_to_value;
array[F_from] of int: F_from_value;

int: TimeMax;
set of int: Time = 1..TimeMax;

%%%% decision variables %%%%
% amount of tokens for each place at each time
array[P, Time] of var int: P_value;

%%%% utility decision variables %%%%s

% define which flows are allowed, i.e. have input P with sufficient tokens
array[Time] of var set of F_to: F_to_allowed;
array[Time] of var set of T: T_allowed;
array[Time] of var set of T: T_executed;
array[Time] of var set of F_to: F_to_executed;
array[Time] of var set of F_from: F_from_executed;

% define all flows that go into a transaction
array[T] of var set of F_to: T_F_to;
constraint forall(t in T) (
  T_F_to[t] = {f | f in F_to where F_to_out[f] = t}
);

%%%% constraints %%%%

% initialize tokens 
enum init;
array[init] of P: init_P;
array[init] of int: init_T;
array[init] of int: init_V;

% utility variable that helps us define how many tokens are generated at each (place, time)
array[Time, P] of var int: tokensGenerated;

% set values equal to the ones found in init
constraint forall(i in init, t in Time where init_T[i] = t, p in P where init_P[i] = p) (tokensGenerated[t,p] = init_V[i]);
% not initialized generated should be zero
constraint forall(t in Time, p in P where not(exists([p = init_P[i]| i in init where t = init_T[i]]))) (tokensGenerated[t,p] = 0);

% define allowed flows and transactions
constraint forall(ti in Time) (
  F_to_allowed[ti] = {f | f in F_to where F_to_value[f] <= P_value[F_to_in[f], ti]}
);

constraint forall(ti in Time) (
  T_allowed[ti] = {t | t in T where T_F_to[t] subset F_to_allowed[ti]}
);

% transactions to be executed
constraint forall(ti in Time) (T_executed[ti] subset T_allowed[ti]);

% flows to be executed
constraint forall(ti in Time) (
  F_to_executed[ti] = {f | t in T_executed[ti], f in T_F_to[t]}
);

% the sum of all executed flows should not exceed the current value in p
constraint forall(
  ti in Time, 
  p in P) 
(
  P_value[p, ti] >= sum([F_to_value[f] | f in F_to_executed[ti] where p = F_to_in[f]])
);

% there should be no allowed transaction that is not executed that is still allowed after execution
% constraint forall(ti in Time where ti < TimeMax, t in T_allowed[ti] where not(t in T_executed[ti]))
%   (not(t in T_allowed[ti+1]));

% only empty transactions after the first empty transaction

% define which flows coming from transactions are executed
% from transactions are executed with a delay, based on the duration of the transaction

% this line generates a warning. However, we are fine with evaluating to FALSE for cases where (ti - T_duration[F_from_in[f] < 1

array[Time] of var set of F_from: fromWithinBounds;
constraint forall(ti in Time) (fromWithinBounds[ti] = {f | f in F_from where ti - T_duration[F_from_in[f]] > 0});

constraint forall(ti in Time) 
  (F_from_executed[ti] = {f | f in fromWithinBounds[ti] where F_from_in[f] in T_executed[ti - T_duration[F_from_in[f]]]});



% Update P_value according to executed flows and tokens generated

% t = 1 is before any transactions have been performed
constraint forall(p in P) (P_value[p, 1] = tokensGenerated[1, p]);

% t > 1 is with transactions taken into account and based on flows
constraint forall(
  ti in Time where ti < TimeMax,
  p in P,
) (
  P_value[p, ti+1] = P_value[p, ti] 
  + sum([F_from_value[f] | f in F_from_executed[ti] where F_from_out[f] = p])
  - sum([F_to_value[f] | f in F_to_executed[ti] where F_to_in[f] = p])
  + tokensGenerated[ti+1, p]
);

%%%% objective solving %%%%
enum Objectives;
array[Objectives] of P: P_objective_name;
array[Objectives] of int: P_objective_value;

array[Objectives] of var 0..1: obj_achieved;
constraint forall(O in Objectives where P_value[P_objective_name[O], TimeMax] >= P_objective_value[O]) (obj_achieved[O] = 1);
constraint forall(O in Objectives where P_value[P_objective_name[O], TimeMax] < P_objective_value[O]) (obj_achieved[O] = 0);

% define makespan
array[Time] of var set of 0..TimeMax: makespanTimes;
constraint forall(ti in Time) ({T_duration[task] + ti | task in T_executed[ti]} subset makespanTimes[ti]);

constraint forall(ti in Time, times in makespanTimes[ti]) (times in {T_duration[task] + ti | task in T_executed[ti]} union {0});

var 0..TimeMax: makespan;
constraint makespan = max({max(makespanTimes[ti])| ti in Time});


% % normalized with TimeMax such that we can do some kind of objective hierarchy
var 0.0..1.0: normalizedMakespan;
constraint normalizedMakespan = makespan/TimeMax;

%%%% todo: adding normalizedMakespan results in ">Error: Float::linear: Number out of limits"

solve maximize(sum(obj_achieved) - normalizedMakespan );

%%%% output %%%%
output
%   ["T_F_to:\n"] ++ ["\(t): \(T_F_to[t])" | t in T] ++ ["\n"] ++
%   ["allowed F_to:\n"] ++ ["\(ti): \(F_to_allowed[ti])\n" | ti in Time] ++ ["\n"] ++
  ["executed transactions:\n"] ++ ["\(ti): \(T_executed[ti])\n" | ti in Time] ++ ["\n"] ++
  ["makespanTimes:\n"] ++ ["\(ti): \(makespanTimes[ti])\n" | ti in Time] ++ ["\n"] ++
  ["\nnormalized makespan: \(normalizedMakespan)\n"] ++
%   ["F_to_executed:\n"] ++ ["\(ti): \(F_to_executed[ti])\n" | ti in Time] ++ ["\n"] ++
%   ["F_from_executed:\n"] ++ ["\(ti): \(F_from_executed[ti])\n" | ti in Time] ++ ["\n"] ++
  ["t:\t"] ++ ["\(t)\t" | t in Time] ++
  [if t=1 then "\n\(p):\t" else "" endif ++ "\(P_value[p, t])\t" | p in P, t in Time] ++
  ["\n\n achieved \(sum(obj_achieved)) of the \(length(Objectives)) objectives"];

