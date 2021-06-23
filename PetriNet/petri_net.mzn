% simulation of firing a petri net

%%%% parameters %%%%

% places
enum P;
P: P_objective;

% transitions
enum T;

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
array[P] of int: P_init;

int: TimeMax;
set of int: Time = 1..TimeMax;

%%%% decision variables %%%%
% value for each place at each time
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

% init P
constraint forall(p in P) (P_value[p, 1] = P_init[p]);

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
constraint forall(ti in 1..TimeMax-1 where T_executed[ti] = {}) (T_executed[ti+1] = {});

% define which flows coming from transactions are executed
constraint forall(ti in Time) 
  (F_from_executed[ti] = {f | f in F_from where F_from_in[f] in T_executed[ti]});

% Update P_value according to executed flows
constraint forall(
  ti in Time where ti < TimeMax,
  p in P,
) (
  P_value[p, ti+1] = P_value[p, ti] 
  + sum([F_from_value[f] | f in F_from_executed[ti] where F_from_out[f] = p])
  - sum([F_to_value[f] | f in F_to_executed[ti] where F_to_in[f] = p])
);

%%%% output %%%%
solve maximize P_value[P_objective, TimeMax];

output
%   ["T_F_to:\n"] ++ ["\(t): \(T_F_to[t])" | t in T] ++ ["\n"] ++
%   ["allowed F_to:\n"] ++ ["\(ti): \(F_to_allowed[ti])\n" | ti in Time] ++ ["\n"] ++
%   ["allowed transactions:\n"] ++ ["\(ti): \(T_allowed[ti])\n" | ti in Time] ++ ["\n"] ++
  ["executed transactions:\n"] ++ ["\(ti): \(T_executed[ti])\n" | ti in Time] ++ ["\n"] ++
%   ["F_to_executed:\n"] ++ ["\(ti): \(F_to_executed[ti])\n" | ti in Time] ++ ["\n"] ++
%   ["F_from_executed:\n"] ++ ["\(ti): \(F_from_executed[ti])\n" | ti in Time] ++ ["\n"] ++
  ["t:\t"] ++ ["\(t)\t" | t in Time] ++
  [if t=1 then "\n\(p):\t" else "" endif ++ "\(P_value[p, t])\t" | p in P, t in Time] ++
  ["\n\nP objective: \(P_objective)"]
  ;

