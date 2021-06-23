% choose from a few calendars
enum Calendar;
Calendar: calendarUsed;

%%% decision Variables ~ input of our NN

% 1. how many academics of each catagory we hire is a strategic decision
% these three should sum to 1
var 0.0..1.0: teachingAcademicRatio;
var 0.0..1.0: researchAcademicRatio;
var 0.0..1.0: hybridAcademicRatio;

% 2. work priority for each category of academics is also a strategic decision
enum workPriorityTeachingOptions;
enum workPriorityHybridOptions;
enum workPriorityResearchOptions;

var workPriorityTeachingOptions: workPriorityTeaching;
var workPriorityHybridOptions: workPriorityHybrid;
var workPriorityResearchOptions: workPriorityResearch;

%%% observables ~ output of the NN, which we use to define goals
% using ratios instead of integers has better performance, as it is easier to learn for the NN
var 0.0..1.0: papers_acceptance_ratio;
var 0.0..1.0: class_not_taken_ratio;
var 0.0..1.0: class_adequate_preparation_ratio;
var 0.0..1.0: complaints_per_module;
var 0.0..1.0: queries_per_module;

% papers submitted is difficult to scale to a number between 0 and 1
var 0..infinity: papers_submitted;

% some other observables that does not necessarily match the goal, but we want to keep intact
var 0.0..1.0: free_time_student;
var 0.0..1.0: free_time_academic;

% we could take a soft constraint approach
solve minimize topLevelObjective;
