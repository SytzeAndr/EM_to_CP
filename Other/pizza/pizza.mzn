% The kitchen of a pizza restaurant modelled as a supply chain
% We have machines, resources, inventories, processes and orders.
% If the deadline of the order is not met, the client gets angry and will walk away, thus no profit

%%%% data parameters %%%

% inventory and capacity. Each resource hold up one slot
enum Inventory;
Inventory: InventoryOut;
array[Inventory] of int: InventoryCapacity;

enum Machine;
enum Process;

% resources and where they are stored
enum Resource;
array[Resource] of Inventory: ResourceInventory;

% what resources are necessary and what comes out
array[Process] of set of Resource: ProcessResourceIn;
array[Process] of set of Resource: ProcessResourceOut;

% what machine is necessary for each process
array[Process] of Machine: ProcessMachine;

% how long each process takes
array[Process] of int: ProcessDuration;

% inventory levels for each resource at t=0
array[Inventory, Resource] of int: InventoryInit;

enum Order;

array[Order] of Resource: OrderContent;
array[Order] of int: OrderQuantity;
array[Order] of int: OrderDeadline;
array[Order] of int: OrderProfit;

int: timespan;
set of int: Time = 0..timespan;

%%% decision variables
% at each time what actions are performed
array[Time] of var set of Process: processesExecuted;

constraint processesExecuted[timespan] = {};

% at each time what inventory levels we have for each resource
array[Time, Inventory, Resource] of var 0..infinity: inventoryLevel;

%%% constraints %%%

% we cannot exceed inventory capacity
constraint forall(t in Time, inv in Inventory) (sum([inventoryLevel[t, inv, r] | r in Resource]) <= InventoryCapacity[inv]);

% for each timestep, indicate for which process each machine is reserved
% constraints that each machine can only be used for one process at the time
array[Machine, Time] of var Process: MachineReservedForProcess;

predicate processIsBeingExecuted(Process: p, int: t) = 
  exists(tt in Time where tt < t) (p in processesExecuted[tt] /\ t < tt + ProcessDuration[p]);

% a process that is executed requires the corresponding machine to be reserved for it
constraint forall(t in Time, p in Process where processIsBeingExecuted(p, t)) (
    MachineReservedForProcess[ProcessMachine[p] ,t] = p
);

% we cannot execute a process that requires a machine which is in a process
constraint forall(t in Time, p in processesExecuted[t]) (
  not(exists(pp in Process where ProcessMachine[pp] = ProcessMachine[p]) (processIsBeingExecuted(pp, t)))
);

% define which processes end at each time, based on what processes are executed
array[Time] of var set of Process: endingProcesses;

constraint forall(t in Time) 
  (endingProcesses[t] = {p | p in Process, tt in Time where tt + ProcessDuration[p] = t /\ p in processesExecuted[tt]});

% adjust inventory levels based on processes performed
constraint forall(i in Inventory, r in Resource) (
  inventoryLevel[0, i, r] = InventoryInit[i,r]
);

% set level to zero if resource inventory does not match
constraint forall(t in Time where t > 0, i in Inventory, r in Resource where i != ResourceInventory[r]) (
  inventoryLevel[t, i, r] = 0
);

constraint forall(t in Time where t > 0, i in Inventory where i != InventoryOut, r in Resource where i = ResourceInventory[r]) (
  inventoryLevel[t, i, r] = inventoryLevel[t-1, i, r] 
  - sum([ 1 | p in processesExecuted[t-1] where r in ProcessResourceIn[p]])
  + sum([ 1 | p in endingProcesses[t-1] where r in ProcessResourceOut[p]])
);

% process orders with the InventoryOut
array[Order] of var bool: OrderIsSuccesful;

constraint forall(t in Time where t > 0, r in Resource where InventoryOut = ResourceInventory[r]) (
  inventoryLevel[t, InventoryOut, r] = inventoryLevel[t-1, InventoryOut, r] 
  + sum([ 1 | p in endingProcesses[t-1] where r in ProcessResourceOut[p]])
  - sum([ OrderQuantity[o] | o in Order where OrderDeadline[o] = t-1 /\ OrderIsSuccesful[o] /\ r = OrderContent[o]])
);

function var int: profit() = sum([OrderProfit[o] | o in Order where OrderIsSuccesful[o]]);

% todo: execute as many actions (as early) as possible
array[Time] of var 0..length(Process):  AmountOfActionsNormalized;
constraint forall(t in Time) (AmountOfActionsNormalized[t] = sum([1 | p in processesExecuted[t]]));

% good solutions consume many order resources
array[Time, Resource] of var 0..infinity: OrderResourcesConsumed;

constraint forall(t in Time, r in Resource where InventoryOut != ResourceInventory[r]) 
  (OrderResourcesConsumed[t,r] = 0);

constraint forall(t in Time, r in Resource where InventoryOut = ResourceInventory[r]) 
  (OrderResourcesConsumed[t,r] = sum([ OrderQuantity[o] | o in Order where OrderIsSuccesful[o] /\ OrderDeadline[o] = t-1 /\ r = OrderContent[o]]));


solve :: seq_search([
  bool_search(OrderIsSuccesful, dom_w_deg, indomain_max),
  int_search(OrderResourcesConsumed, occurrence, indomain_max),
%   int_search(AmountOfActionsNormalized, input_order, indomain_min),
])
  maximize profit();

output 
["profit: \(sum([OrderProfit[o] | o in Order where OrderIsSuccesful[o]]))\n"] ++
["\norders:\n"] ++ ["\(o): deadline:\(OrderDeadline[o]), \(OrderQuantity[o])x \(OrderContent[o]), \(OrderIsSuccesful[o])\n" | o in Order] ++
["\nprocesses executed:\n"] ++ [if "\(processesExecuted[t])" != "{}" then "\n\(t):\(processesExecuted[t])" else "" endif | t in Time]; 
% ["\n\ninventory:\n"] ++ [if "\(inventoryLevel[t,i,r])" != "0" then "\(i), t: \(t), r: \(r)=\(inventoryLevel[t,i,r])\n" else "" endif | i in Inventory, t in Time, r in Resource] ;
% [if processesExecuted[t] = {} then "\n \(t): \(processesExecuted[t])" else "" endif | t in Time];