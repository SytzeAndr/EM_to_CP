% auto generated file, representing a neural network
% features in: ['initial_fruit_bushes', 'initial_foragers', 'ticks_to_flee', 'collaboration_bonus', 'bush_growth_chance', 'max_age', 'rate_of_mutation']
% features out: ['murder_rate', 'age_death_rate', 'starvation_rate']
% layerCount: 2
% layerWidth: 5

% use these to access output parameters
array[Time] of var float: murder_rate;
array[Time] of var float: age_death_rate;
array[Time] of var float: starvation_rate;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_deaths;
constraint forall(t in Time) (n_0_0_deaths[t] = max((0.06230994686484337 * initial_fruit_bushes[t] + 0.011029423214495182 * initial_foragers[t] + -0.0070611778646707535 * ticks_to_flee[t] + 0.21802441775798798 * collaboration_bonus[t] + 0.002960721729323268 * bush_growth_chance[t] + 0.10386977344751358 * max_age[t] + 0.032777030020952225 * rate_of_mutation[t] + -0.9724190831184387), 0));
array[Time] of var float: n_0_1_deaths;
constraint forall(t in Time) (n_0_1_deaths[t] = max((0.03748504817485809 * initial_fruit_bushes[t] + -0.07015931606292725 * initial_foragers[t] + -0.0011457536602392793 * ticks_to_flee[t] + -0.02791704796254635 * collaboration_bonus[t] + -0.0470568872988224 * bush_growth_chance[t] + -0.016394298523664474 * max_age[t] + -0.07897424697875977 * rate_of_mutation[t] + -0.0984525978565216), 0));
array[Time] of var float: n_0_2_deaths;
constraint forall(t in Time) (n_0_2_deaths[t] = max((0.0063718282617628574 * initial_fruit_bushes[t] + 0.007052022498100996 * initial_foragers[t] + 0.018576718866825104 * ticks_to_flee[t] + 0.21272660791873932 * collaboration_bonus[t] + 0.01656929962337017 * bush_growth_chance[t] + -0.07685352861881256 * max_age[t] + 0.11841968446969986 * rate_of_mutation[t] + 3.5483670234680176), 0));
array[Time] of var float: n_0_3_deaths;
constraint forall(t in Time) (n_0_3_deaths[t] = max((-0.1051781177520752 * initial_fruit_bushes[t] + 0.0026185510214418173 * initial_foragers[t] + 0.028810760006308556 * ticks_to_flee[t] + 0.8291184902191162 * collaboration_bonus[t] + -0.8444756269454956 * bush_growth_chance[t] + 0.07516263425350189 * max_age[t] + 0.37178072333335876 * rate_of_mutation[t] + -0.16648462414741516), 0));
array[Time] of var float: n_0_4_deaths;
constraint forall(t in Time) (n_0_4_deaths[t] = max((-0.0011867922730743885 * initial_fruit_bushes[t] + 0.009266778826713562 * initial_foragers[t] + -0.3680635988712311 * ticks_to_flee[t] + -0.3592754900455475 * collaboration_bonus[t] + 0.2286427915096283 * bush_growth_chance[t] + 0.04473195970058441 * max_age[t] + -0.9256336092948914 * rate_of_mutation[t] + 0.4602247178554535), 0));
% Layer 1
array[Time] of var float: n_1_0_deaths;
constraint forall(t in Time) (n_1_0_deaths[t] = max((-3.9866936206817627 * n_0_0_deaths[t] + -0.03560618311166763 * n_0_1_deaths[t] + -0.5687716007232666 * n_0_2_deaths[t] + 0.10844703763723373 * n_0_3_deaths[t] + 0.046078480780124664 * n_0_4_deaths[t] + 1.5269887447357178), 0));
array[Time] of var float: n_1_1_deaths;
constraint forall(t in Time) (n_1_1_deaths[t] = max((0.10076203942298889 * n_0_0_deaths[t] + -0.010491764172911644 * n_0_1_deaths[t] + -0.052274368703365326 * n_0_2_deaths[t] + 0.6714368462562561 * n_0_3_deaths[t] + -0.0645400658249855 * n_0_4_deaths[t] + -1.457440733909607), 0));
array[Time] of var float: n_1_2_deaths;
constraint forall(t in Time) (n_1_2_deaths[t] = max((-0.009214555844664574 * n_0_0_deaths[t] + 0.26553472876548767 * n_0_1_deaths[t] + 1.4099888801574707 * n_0_2_deaths[t] + -0.12525373697280884 * n_0_3_deaths[t] + -0.09156177937984467 * n_0_4_deaths[t] + 2.111574411392212), 0));
array[Time] of var float: n_1_3_deaths;
constraint forall(t in Time) (n_1_3_deaths[t] = max((0.19113312661647797 * n_0_0_deaths[t] + 0.049033600836992264 * n_0_1_deaths[t] + -0.07543101161718369 * n_0_2_deaths[t] + -0.020681709051132202 * n_0_3_deaths[t] + 0.024657925590872765 * n_0_4_deaths[t] + -1.9451041221618652), 0));
array[Time] of var float: n_1_4_deaths;
constraint forall(t in Time) (n_1_4_deaths[t] = max((-0.012332075275480747 * n_0_0_deaths[t] + 0.07617319375276566 * n_0_1_deaths[t] + -1.0685248374938965 * n_0_2_deaths[t] + -0.16273118555545807 * n_0_3_deaths[t] + 0.2250492125749588 * n_0_4_deaths[t] + 1.7046939134597778), 0));
% Layer 2
array[Time] of var float: n_2_0_deaths;
constraint forall(t in Time) (n_2_0_deaths[t] = (0.20871543884277344 * n_1_0_deaths[t] + -0.7091352343559265 * n_1_1_deaths[t] + -3.2370779514312744 * n_1_2_deaths[t] + 0.21077775955200195 * n_1_3_deaths[t] + 0.16449108719825745 * n_1_4_deaths[t] + -0.0771377682685852));
array[Time] of var float: n_2_1_deaths;
constraint forall(t in Time) (n_2_1_deaths[t] = (-5.260964393615723 * n_1_0_deaths[t] + 0.032940447330474854 * n_1_1_deaths[t] + 0.026291046291589737 * n_1_2_deaths[t] + -5.391178607940674 * n_1_3_deaths[t] + 0.10415077954530716 * n_1_4_deaths[t] + 0.0369362011551857));
array[Time] of var float: n_2_2_deaths;
constraint forall(t in Time) (n_2_2_deaths[t] = (-0.23219460248947144 * n_1_0_deaths[t] + 0.1144905760884285 * n_1_1_deaths[t] + -3.0936665534973145 * n_1_2_deaths[t] + -0.24859493970870972 * n_1_3_deaths[t] + -1.0710879564285278 * n_1_4_deaths[t] + -0.057475656270980835));
% Add activation function
array[Time] of var 0.0..infinity: expsum_deaths;
constraint forall(t in Time) (murder_rate[t] * expsum_deaths[t] = exp(n_2_0_deaths[t]));
constraint forall(t in Time) (age_death_rate[t] * expsum_deaths[t] = exp(n_2_1_deaths[t]));
constraint forall(t in Time) (starvation_rate[t] * expsum_deaths[t] = exp(n_2_2_deaths[t]));
constraint forall(t in Time) (expsum_deaths[t] = murder_rate[t] + age_death_rate[t] + starvation_rate[t]);
