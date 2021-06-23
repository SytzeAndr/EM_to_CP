%%%%% parameters %%%%%

enum Belief;  
enum Agent;
enum Task;
int: TimeMax;
set of int: Time = 1..TimeMax;

% initial knowledge base of each agent
array[Agent] of set of Belief: KnowledgeInit;

% define tasks
array[Task] of Agent: TaskAnnouncer;
array[Task] of Agent: TaskRecipient;

array[Task] of set of Belief: TaskInput;
array[Task] of set of Belief: TaskOutput;

%%%%% decision variables %%%%%

% knowledge base for each agent at each time
array[Time, Agent] of var set of Belief: Knowledge;

%%%%% utility decision variables %%%%%

% define init knowledge for t=1
constraint forall (a in Agent) (Knowledge[1, a] = KnowledgeInit[a]); 

% allowed tasks
array[Time] of var set of Task: AllowedTasks;

constraint forall(
  ti in Time,
  ta in Task where TaskInput[ta] subset Knowledge[ti, TaskAnnouncer[ta]])
(ta in AllowedTasks[ti]);

constraint forall(
  ti in Time,
  ta in Task where not(TaskInput[ta] subset Knowledge[ti, TaskAnnouncer[ta]]))
(not(ta in AllowedTasks[ti]));

% all announcing and recipient agents at time t
array[Time] of var set of Agent: announcingAgents;
array[Time] of var set of Agent: recipientAgents;
array[Time] of var set of Agent: nonInvolvedAgents;

constraint forall (ti in Time where ti <= TimeMax, a in announcingAgents[ti]) 
                  (exists(allowedTask in AllowedTasks[ti]) (TaskAnnouncer[allowedTask] = a));

constraint forall (ti in Time where ti <= TimeMax, a in (Agent diff announcingAgents[ti])) 
                  (not(exists(allowedTask in AllowedTasks[ti]) (TaskAnnouncer[allowedTask] = a)));

constraint forall (ti in Time where ti <= TimeMax, a in recipientAgents[ti]) 
                  (exists(allowedTask in AllowedTasks[ti]) (TaskRecipient[allowedTask] = a));

constraint forall (ti in Time where ti <= TimeMax, a in (Agent diff recipientAgents[ti])) 
                  (not(exists(allowedTask in AllowedTasks[ti]) (TaskRecipient[allowedTask] = a)));

constraint forall (ti in Time where ti <= TimeMax) 
                  (nonInvolvedAgents[ti] = (Agent diff announcingAgents[ti]) diff recipientAgents[ti]);

%%%%% constraints %%%%%

% each tick, execute all possible tasks
% knowledge of agent that is no announcer or recipient (stays intact)
constraint forall (
      ti in Time where ti < TimeMax,      
      a in nonInvolvedAgents[ti]     
    ) 
    (
      Knowledge[ti + 1, a] = Knowledge[ti, a] 
    );
    
% no agent can be involved in two different tasks at the same time
constraint forall (ti in Time where ti < TimeMax, task_this in AllowedTasks[ti])
  (not(exists
    (task_other in AllowedTasks[ti] where task_other != task_this) 
    ({TaskRecipient[task_this], TaskAnnouncer[task_this]} intersect {TaskRecipient[task_other], TaskAnnouncer[task_other]} != {})
  ));

% knowledge of agent that is announcer but no recipient (discards input belief)
constraint forall (
      ti in Time where ti < TimeMax,      
      a in Agent where not(a in recipientAgents[ti]),
      allowedTask in AllowedTasks[ti] where TaskAnnouncer[allowedTask] = a,
    ) 
    (
      Knowledge[ti + 1, a] = Knowledge[ti, a] diff TaskInput[allowedTask]
    );
    
% knowledge of agent that is recipient but no announcer (adds output belief)
constraint forall (
      ti in Time where ti < TimeMax,      
      a in Agent where not(a in announcingAgents[ti]),
      allowedTask in AllowedTasks[ti] where TaskRecipient[allowedTask] = a
    ) 
    (
      Knowledge[ti + 1, a] = Knowledge[ti, a] union TaskOutput[allowedTask]
    );

% knowledge of agent that is both announcer and recipient (discard input and adds output)
constraint forall (
      ti in Time where ti < TimeMax,      
      a in Agent where a in (recipientAgents[ti] intersect announcingAgents[ti]),
      allowedTask in AllowedTasks[ti] where TaskAnnouncer[allowedTask] = a      
    ) 
    (
      Knowledge[ti + 1, a] = (Knowledge[ti, a] union TaskOutput[allowedTask]) diff TaskInput[allowedTask] 
    );
    

solve satisfy;

output
  ["allowed tasks:\n"] ++ ["\(t): \(AllowedTasks[t])\n" | t in Time] ++
  ["\nKnowledge:"] ++
  [if t = 1 then "\n\(agent):" else "" endif ++ "\n\(t): \(Knowledge[t, agent])" | agent in Agent, t in Time]; %++
%   ["\nannouncer_agents:\n"] ++
%   ["t: \(announcingAgents[t])\n" | t in Time] ++
%   ["\nrecipient_agents:\n"] ++
%   ["t: \(recipientAgents[t])\n" | t in Time] ++
%   ["\nnon_involved_agents:\n"] ++
%   ["t: \(nonInvolvedAgents[t])\n" | t in Time];
   
%   ["\n\nKnowledge after removal:"] ++
%   [if t = 1 then "\n\(agent):" else " " endif ++ "\(KnowledgeAfterRemoval[t, agent])" | agent in Agent, t in Time];
