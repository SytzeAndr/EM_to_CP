% auto generated file, representing a neural network
% features in: ['initial_fruit_bushes', 'initial_foragers', 'ticks_to_flee', 'collaboration_bonus', 'bush_growth_chance', 'max_age', 'rate_of_mutation']
% features out: ['average_population']
% layerCount: 2
% layerWidth: 3

% use these to access output parameters
array[Time] of var float: average_population;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_pop;
constraint forall(t in Time) (n_0_0_pop[t] = max((0.005865849554538727 * initial_fruit_bushes[t] + 4.520817310549319e-05 * initial_foragers[t] + 0.01350779552012682 * ticks_to_flee[t] + 1.0594470500946045 * collaboration_bonus[t] + 0.0727844312787056 * bush_growth_chance[t] + 0.011811994016170502 * max_age[t] + -0.020497897639870644 * rate_of_mutation[t] + -8.58912181854248), 0));
array[Time] of var float: n_0_1_pop;
constraint forall(t in Time) (n_0_1_pop[t] = max((-0.07112791389226913 * initial_fruit_bushes[t] + -0.03027910180389881 * initial_foragers[t] + -0.06387750804424286 * ticks_to_flee[t] + -0.001149857183918357 * collaboration_bonus[t] + 0.006912213284522295 * bush_growth_chance[t] + -0.05601846054196358 * max_age[t] + -0.0723053440451622 * rate_of_mutation[t] + 0.04953848943114281), 0));
array[Time] of var float: n_0_2_pop;
constraint forall(t in Time) (n_0_2_pop[t] = max((-0.00035712297540158033 * initial_fruit_bushes[t] + -0.000828608637675643 * initial_foragers[t] + 0.0168876014649868 * ticks_to_flee[t] + 1.0417263507843018 * collaboration_bonus[t] + 0.05522609502077103 * bush_growth_chance[t] + 0.008198412135243416 * max_age[t] + -0.05657520890235901 * rate_of_mutation[t] + -8.901826858520508), 0));
% Layer 1
array[Time] of var float: n_1_0_pop;
constraint forall(t in Time) (n_1_0_pop[t] = max((5.253890514373779 * n_0_0_pop[t] + -0.017077665776014328 * n_0_1_pop[t] + 10.354695320129395 * n_0_2_pop[t] + 10.770817756652832), 0));
array[Time] of var float: n_1_1_pop;
constraint forall(t in Time) (n_1_1_pop[t] = max((-0.0827210322022438 * n_0_0_pop[t] + -0.11482284963130951 * n_0_1_pop[t] + -0.07813134789466858 * n_0_2_pop[t] + -0.1002083569765091), 0));
array[Time] of var float: n_1_2_pop;
constraint forall(t in Time) (n_1_2_pop[t] = max((5.146371364593506 * n_0_0_pop[t] + -0.045497287064790726 * n_0_1_pop[t] + 10.37926959991455 * n_0_2_pop[t] + 10.811758041381836), 0));
% Layer 2
array[Time] of var float: n_2_0_pop;
constraint forall(t in Time) (n_2_0_pop[t] = (9.162249565124512 * n_1_0_pop[t] + 0.0815046951174736 * n_1_1_pop[t] + 9.213335037231445 * n_1_2_pop[t] + 10.572744369506836));
% Add activation function
constraint forall(t in Time) (average_population[t] = max(n_2_0_pop[t], 0));
