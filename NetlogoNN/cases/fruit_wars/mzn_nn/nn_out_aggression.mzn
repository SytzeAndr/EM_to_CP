% auto generated file, representing a neural network
% features in: ['initial_fruit_bushes', 'initial_foragers', 'ticks_to_flee', 'collaboration_bonus', 'bush_growth_chance', 'max_age', 'rate_of_mutation']
% features out: ['mean_reactive_aggression', 'mean_proactive_aggression']
% layerCount: 2
% layerWidth: 4

% use these to access output parameters
array[Time] of var float: mean_reactive_aggression;
array[Time] of var float: mean_proactive_aggression;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_aggression;
constraint forall(t in Time) (n_0_0_aggression[t] = max((0.022302716970443726 * initial_fruit_bushes[t] + 0.006926007568836212 * initial_foragers[t] + 0.01634007878601551 * ticks_to_flee[t] + -3.600017786026001 * collaboration_bonus[t] + -0.009816618636250496 * bush_growth_chance[t] + 0.00506232026964426 * max_age[t] + 0.17920394241809845 * rate_of_mutation[t] + 2.9818758964538574), 0));
array[Time] of var float: n_0_1_aggression;
constraint forall(t in Time) (n_0_1_aggression[t] = max((-0.006770499516278505 * initial_fruit_bushes[t] + 0.0027311653830111027 * initial_foragers[t] + 0.0023707777727395296 * ticks_to_flee[t] + 0.3689826726913452 * collaboration_bonus[t] + 0.004329552873969078 * bush_growth_chance[t] + -0.04156823083758354 * max_age[t] + 0.125937819480896 * rate_of_mutation[t] + 4.03821325302124), 0));
array[Time] of var float: n_0_2_aggression;
constraint forall(t in Time) (n_0_2_aggression[t] = max((0.02418670803308487 * initial_fruit_bushes[t] + 0.0038743847981095314 * initial_foragers[t] + -0.10887853056192398 * ticks_to_flee[t] + 1.0263456106185913 * collaboration_bonus[t] + 0.15091080963611603 * bush_growth_chance[t] + 0.030812619253993034 * max_age[t] + -1.7114375829696655 * rate_of_mutation[t] + -1.2537587881088257), 0));
array[Time] of var float: n_0_3_aggression;
constraint forall(t in Time) (n_0_3_aggression[t] = max((-0.008699677884578705 * initial_fruit_bushes[t] + -0.011402777396142483 * initial_foragers[t] + -0.009501158259809017 * ticks_to_flee[t] + -1.248796820640564 * collaboration_bonus[t] + 0.0004901798092760146 * bush_growth_chance[t] + -0.003110845573246479 * max_age[t] + -0.0646977499127388 * rate_of_mutation[t] + 0.7141453623771667), 0));
% Layer 1
array[Time] of var float: n_1_0_aggression;
constraint forall(t in Time) (n_1_0_aggression[t] = max((0.21661294996738434 * n_0_0_aggression[t] + -0.7124648690223694 * n_0_1_aggression[t] + 0.19236105680465698 * n_0_2_aggression[t] + 0.21104492247104645 * n_0_3_aggression[t] + -0.7073332667350769), 0));
array[Time] of var float: n_1_1_aggression;
constraint forall(t in Time) (n_1_1_aggression[t] = max((-0.7738505601882935 * n_0_0_aggression[t] + -0.5597899556159973 * n_0_1_aggression[t] + 0.23413053154945374 * n_0_2_aggression[t] + -0.22065579891204834 * n_0_3_aggression[t] + -0.16467025876045227), 0));
array[Time] of var float: n_1_2_aggression;
constraint forall(t in Time) (n_1_2_aggression[t] = max((0.29986265301704407 * n_0_0_aggression[t] + 0.4131550192832947 * n_0_1_aggression[t] + -0.020711831748485565 * n_0_2_aggression[t] + 0.10593730956315994 * n_0_3_aggression[t] + 1.421572208404541), 0));
array[Time] of var float: n_1_3_aggression;
constraint forall(t in Time) (n_1_3_aggression[t] = max((-0.09739323705434799 * n_0_0_aggression[t] + -0.0448346808552742 * n_0_1_aggression[t] + -0.09831797331571579 * n_0_2_aggression[t] + -0.027233745902776718 * n_0_3_aggression[t] + -0.029872817918658257), 0));
% Layer 2
array[Time] of var float: n_2_0_aggression;
constraint forall(t in Time) (n_2_0_aggression[t] = (0.05763325095176697 * n_1_0_aggression[t] + -1.9877479076385498 * n_1_1_aggression[t] + 0.38223472237586975 * n_1_2_aggression[t] + -0.007204373367130756 * n_1_3_aggression[t] + -0.062201082706451416));
array[Time] of var float: n_2_1_aggression;
constraint forall(t in Time) (n_2_1_aggression[t] = (-0.9095463156700134 * n_1_0_aggression[t] + 0.15233637392520905 * n_1_1_aggression[t] + 0.16380202770233154 * n_1_2_aggression[t] + 0.09194409102201462 * n_1_3_aggression[t] + 0.0290740504860878));
% Add activation function
array[Time] of var 0.0..infinity: expsum_aggression;
constraint forall(t in Time) (mean_reactive_aggression[t] * expsum_aggression[t] = exp(n_2_0_aggression[t]));
constraint forall(t in Time) (mean_proactive_aggression[t] * expsum_aggression[t] = exp(n_2_1_aggression[t]));
constraint forall(t in Time) (expsum_aggression[t] = mean_reactive_aggression[t] + mean_proactive_aggression[t]);
