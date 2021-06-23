% auto generated file, representing a neural network
% features in: ['initial_fruit_bushes', 'initial_foragers', 'ticks_to_flee', 'collaboration_bonus', 'bush_growth_chance', 'max_age', 'rate_of_mutation']
% features out: ['mean_strength', 'mean_speed', 'mean_intelligence']
% layerCount: 2
% layerWidth: 5

% use these to access output parameters
array[Time] of var float: mean_strength;
array[Time] of var float: mean_speed;
array[Time] of var float: mean_intelligence;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_traits;
constraint forall(t in Time) (n_0_0_traits[t] = max((-0.023041989654302597 * initial_fruit_bushes[t] + -0.0191025547683239 * initial_foragers[t] + 0.04348013550043106 * ticks_to_flee[t] + -0.3078368306159973 * collaboration_bonus[t] + 0.07440108060836792 * bush_growth_chance[t] + -0.021759964525699615 * max_age[t] + 1.8443989753723145 * rate_of_mutation[t] + -0.7424294352531433), 0));
array[Time] of var float: n_0_1_traits;
constraint forall(t in Time) (n_0_1_traits[t] = max((0.018245497718453407 * initial_fruit_bushes[t] + -0.0037107954267412424 * initial_foragers[t] + 0.08691808581352234 * ticks_to_flee[t] + 0.01152743399143219 * collaboration_bonus[t] + 0.052127234637737274 * bush_growth_chance[t] + -0.0766870528459549 * max_age[t] + 1.4688539505004883 * rate_of_mutation[t] + 3.8573925495147705), 0));
array[Time] of var float: n_0_2_traits;
constraint forall(t in Time) (n_0_2_traits[t] = max((-0.01599491946399212 * initial_fruit_bushes[t] + -0.006085285451263189 * initial_foragers[t] + -0.9235700964927673 * ticks_to_flee[t] + -0.6474246382713318 * collaboration_bonus[t] + 0.12079907953739166 * bush_growth_chance[t] + -0.0025492897257208824 * max_age[t] + 1.5600868463516235 * rate_of_mutation[t] + -0.8784382343292236), 0));
array[Time] of var float: n_0_3_traits;
constraint forall(t in Time) (n_0_3_traits[t] = max((-0.018432144075632095 * initial_fruit_bushes[t] + -0.026732495054602623 * initial_foragers[t] + 0.03563201427459717 * ticks_to_flee[t] + -0.37235528230667114 * collaboration_bonus[t] + 0.07652020454406738 * bush_growth_chance[t] + -0.011685019358992577 * max_age[t] + 1.8781942129135132 * rate_of_mutation[t] + -1.4563230276107788), 0));
array[Time] of var float: n_0_4_traits;
constraint forall(t in Time) (n_0_4_traits[t] = max((0.015231862664222717 * initial_fruit_bushes[t] + -0.008272837847471237 * initial_foragers[t] + 0.043945103883743286 * ticks_to_flee[t] + 0.11642686277627945 * collaboration_bonus[t] + 0.004217012785375118 * bush_growth_chance[t] + -0.06286416202783585 * max_age[t] + 0.5873394012451172 * rate_of_mutation[t] + 5.545897483825684), 0));
% Layer 1
array[Time] of var float: n_1_0_traits;
constraint forall(t in Time) (n_1_0_traits[t] = max((0.22205835580825806 * n_0_0_traits[t] + 0.42087018489837646 * n_0_1_traits[t] + 0.25290536880493164 * n_0_2_traits[t] + -0.17249108850955963 * n_0_3_traits[t] + 0.5016680955886841 * n_0_4_traits[t] + 0.02363189123570919), 0));
array[Time] of var float: n_1_1_traits;
constraint forall(t in Time) (n_1_1_traits[t] = max((0.1097525879740715 * n_0_0_traits[t] + 0.26517319679260254 * n_0_1_traits[t] + 0.3444349467754364 * n_0_2_traits[t] + 0.3416935205459595 * n_0_3_traits[t] + 0.3325451612472534 * n_0_4_traits[t] + 0.011491849087178707), 0));
array[Time] of var float: n_1_2_traits;
constraint forall(t in Time) (n_1_2_traits[t] = max((-0.022237982600927353 * n_0_0_traits[t] + -0.2425929605960846 * n_0_1_traits[t] + 0.08572901785373688 * n_0_2_traits[t] + 0.09901341050863266 * n_0_3_traits[t] + 0.5796951651573181 * n_0_4_traits[t] + -0.3822377324104309), 0));
array[Time] of var float: n_1_3_traits;
constraint forall(t in Time) (n_1_3_traits[t] = max((0.1299801468849182 * n_0_0_traits[t] + 0.22550496459007263 * n_0_1_traits[t] + 0.2062922865152359 * n_0_2_traits[t] + 0.06550828367471695 * n_0_3_traits[t] + 0.3396640121936798 * n_0_4_traits[t] + -3.1505093574523926), 0));
array[Time] of var float: n_1_4_traits;
constraint forall(t in Time) (n_1_4_traits[t] = max((-0.08421788364648819 * n_0_0_traits[t] + -0.08936433494091034 * n_0_1_traits[t] + -0.07834170758724213 * n_0_2_traits[t] + -0.024065140634775162 * n_0_3_traits[t] + -0.06473588198423386 * n_0_4_traits[t] + -0.024185452610254288), 0));
% Layer 2
array[Time] of var float: n_2_0_traits;
constraint forall(t in Time) (n_2_0_traits[t] = (0.37657126784324646 * n_1_0_traits[t] + 0.33008623123168945 * n_1_1_traits[t] + 0.1522684097290039 * n_1_2_traits[t] + -0.9516803026199341 * n_1_3_traits[t] + -0.06604530662298203 * n_1_4_traits[t] + 0.055762700736522675));
array[Time] of var float: n_2_1_traits;
constraint forall(t in Time) (n_2_1_traits[t] = (-0.9779716730117798 * n_1_0_traits[t] + -0.31911131739616394 * n_1_1_traits[t] + -1.3531227111816406 * n_1_2_traits[t] + -8.842740058898926 * n_1_3_traits[t] + 0.031228702515363693 * n_1_4_traits[t] + 0.08575939387083054));
array[Time] of var float: n_2_2_traits;
constraint forall(t in Time) (n_2_2_traits[t] = (0.35403311252593994 * n_1_0_traits[t] + 0.2955421507358551 * n_1_1_traits[t] + 0.13531960546970367 * n_1_2_traits[t] + -0.8802540898323059 * n_1_3_traits[t] + 0.012487956322729588 * n_1_4_traits[t] + -0.09155620634555817));
% Add activation function
array[Time] of var 0.0..infinity: expsum_traits;
constraint forall(t in Time) (mean_strength[t] * expsum_traits[t] = exp(n_2_0_traits[t]));
constraint forall(t in Time) (mean_speed[t] * expsum_traits[t] = exp(n_2_1_traits[t]));
constraint forall(t in Time) (mean_intelligence[t] * expsum_traits[t] = exp(n_2_2_traits[t]));
constraint forall(t in Time) (expsum_traits[t] = mean_strength[t] + mean_speed[t] + mean_intelligence[t]);
