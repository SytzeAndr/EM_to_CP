% auto generated file, representing a neural network
% features in: ['Fact', 'Distr1', 'Distr2', 'Clients_N', 'Demand_W', 'HC', 'Lt0', 'Lt1', 'SS_', 'DS_D', 'K', 'MA', 'v1_DailyPurchase', 'v2_PeriodicallyPurchase', 'v3_Random', 'v1_s_Q', 'v2_s_S', 'v3_R_S', 'v4_Random']
% features out: ['lost_ratio_sales_ret', 'lost_ratio_sales_dis', 'lost_ratio_sales_fac']
% layerCount: 3
% layerWidth: 4

% use these to access output parameters
var float: lost_ratio_sales_ret;
var float: lost_ratio_sales_dis;
var float: lost_ratio_sales_fac;


% Node constraints
% Layer 0
var float: n_0_0Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_0_0Supply_Chain_Supply_Chain_halton_pow2 = max((0.5440942049026489 * Fact + -0.1244458556175232 * Distr1 + -0.03719976171851158 * Distr2 + 0.040463030338287354 * Clients_N + 0.2348431795835495 * Demand_W + -2.6794252395629883 * HC + 0.02239912748336792 * Lt0 + 0.015194923616945744 * Lt1 + 0.026965133845806122 * SS_ + -0.24496647715568542 * DS_D + 0.029808543622493744 * K + 0.00039641596958972514 * MA + -0.2171456515789032 * v1_DailyPurchase + -0.20341970026493073 * v2_PeriodicallyPurchase + 1.4368607997894287 * v3_Random + 2.549088716506958 * v1_s_Q + -0.3518247604370117 * v2_s_S + 1.609129548072815 * v3_R_S + -0.28875067830085754 * v4_Random + -0.005840766709297895), 0));
var float: n_0_1Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_0_1Supply_Chain_Supply_Chain_halton_pow2 = max((-0.12047147750854492 * Fact + -0.0590110719203949 * Distr1 + -0.02493353933095932 * Distr2 + 0.0014834895264357328 * Clients_N + 0.1951734721660614 * Demand_W + 7.7581329345703125 * HC + 0.004726405255496502 * Lt0 + 0.01684591919183731 * Lt1 + 0.011600726284086704 * SS_ + -0.09061981737613678 * DS_D + 0.007376779802143574 * K + -0.0034363996237516403 * MA + 0.9428499341011047 * v1_DailyPurchase + -0.32683345675468445 * v2_PeriodicallyPurchase + 0.20504975318908691 * v3_Random + 0.15390148758888245 * v1_s_Q + -0.23683544993400574 * v2_s_S + -0.45188868045806885 * v3_R_S + 0.3067812919616699 * v4_Random + 0.024481330066919327), 0));
var float: n_0_2Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_0_2Supply_Chain_Supply_Chain_halton_pow2 = max((0.3991253077983856 * Fact + 0.00964047759771347 * Distr1 + -0.05329335480928421 * Distr2 + 0.010007352568209171 * Clients_N + 0.2500174343585968 * Demand_W + 8.493030548095703 * HC + -0.01755618117749691 * Lt0 + -0.005889327265322208 * Lt1 + -0.03146914392709732 * SS_ + -0.1533893495798111 * DS_D + 0.012568325735628605 * K + -0.0060224090702831745 * MA + 0.7210345268249512 * v1_DailyPurchase + -0.10156731307506561 * v2_PeriodicallyPurchase + 0.024923404678702354 * v3_Random + 0.7800416350364685 * v1_s_Q + -0.26118889451026917 * v2_s_S + 0.3034745156764984 * v3_R_S + -0.3780035972595215 * v4_Random + -0.006294785998761654), 0));
var float: n_0_3Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_0_3Supply_Chain_Supply_Chain_halton_pow2 = max((0.025188978761434555 * Fact + -0.018067028373479843 * Distr1 + 0.005558554548770189 * Distr2 + -0.02150636725127697 * Clients_N + 0.01589636690914631 * Demand_W + -0.020766660571098328 * HC + 0.017481038346886635 * Lt0 + 0.027788499370217323 * Lt1 + 0.017370164394378662 * SS_ + 0.02746897004544735 * DS_D + -0.020450789481401443 * K + -0.0055205742828547955 * MA + 0.024115387350320816 * v1_DailyPurchase + 0.018213847652077675 * v2_PeriodicallyPurchase + 0.0011270677205175161 * v3_Random + 0.007774176076054573 * v1_s_Q + 0.003213293384760618 * v2_s_S + 0.016918161883950233 * v3_R_S + -0.01563812792301178 * v4_Random + -0.028848623856902122), 0));
% Layer 1
var float: n_1_0Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_1_0Supply_Chain_Supply_Chain_halton_pow2 = max((0.07631132751703262 * n_0_0Supply_Chain_Supply_Chain_halton_pow2 + 2.0955963134765625 * n_0_1Supply_Chain_Supply_Chain_halton_pow2 + -1.7872610092163086 * n_0_2Supply_Chain_Supply_Chain_halton_pow2 + -0.022754624485969543 * n_0_3Supply_Chain_Supply_Chain_halton_pow2 + -0.3666957914829254), 0));
var float: n_1_1Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_1_1Supply_Chain_Supply_Chain_halton_pow2 = max((0.36178919672966003 * n_0_0Supply_Chain_Supply_Chain_halton_pow2 + -1.5816490650177002 * n_0_1Supply_Chain_Supply_Chain_halton_pow2 + 0.4493744969367981 * n_0_2Supply_Chain_Supply_Chain_halton_pow2 + 0.007621584925800562 * n_0_3Supply_Chain_Supply_Chain_halton_pow2 + -1.7306077480316162), 0));
var float: n_1_2Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_1_2Supply_Chain_Supply_Chain_halton_pow2 = max((-0.07633882015943527 * n_0_0Supply_Chain_Supply_Chain_halton_pow2 + 0.9550679922103882 * n_0_1Supply_Chain_Supply_Chain_halton_pow2 + 0.6400346159934998 * n_0_2Supply_Chain_Supply_Chain_halton_pow2 + -0.0214804969727993 * n_0_3Supply_Chain_Supply_Chain_halton_pow2 + 0.3710382282733917), 0));
var float: n_1_3Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_1_3Supply_Chain_Supply_Chain_halton_pow2 = max((-0.05735159292817116 * n_0_0Supply_Chain_Supply_Chain_halton_pow2 + -0.05480390787124634 * n_0_1Supply_Chain_Supply_Chain_halton_pow2 + -0.04061358794569969 * n_0_2Supply_Chain_Supply_Chain_halton_pow2 + -0.02949315868318081 * n_0_3Supply_Chain_Supply_Chain_halton_pow2 + -0.019553618505597115), 0));
% Layer 2
var float: n_2_0Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_2_0Supply_Chain_Supply_Chain_halton_pow2 = max((0.5989176630973816 * n_1_0Supply_Chain_Supply_Chain_halton_pow2 + 0.38431668281555176 * n_1_1Supply_Chain_Supply_Chain_halton_pow2 + 0.46726131439208984 * n_1_2Supply_Chain_Supply_Chain_halton_pow2 + -0.054965272545814514 * n_1_3Supply_Chain_Supply_Chain_halton_pow2 + 0.5559635758399963), 0));
var float: n_2_1Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_2_1Supply_Chain_Supply_Chain_halton_pow2 = max((-0.3173876404762268 * n_1_0Supply_Chain_Supply_Chain_halton_pow2 + 0.30716392397880554 * n_1_1Supply_Chain_Supply_Chain_halton_pow2 + -0.9562735557556152 * n_1_2Supply_Chain_Supply_Chain_halton_pow2 + -0.04885637387633324 * n_1_3Supply_Chain_Supply_Chain_halton_pow2 + 0.3546934127807617), 0));
var float: n_2_2Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_2_2Supply_Chain_Supply_Chain_halton_pow2 = max((2.0248453617095947 * n_1_0Supply_Chain_Supply_Chain_halton_pow2 + 0.7089792490005493 * n_1_1Supply_Chain_Supply_Chain_halton_pow2 + 1.259479284286499 * n_1_2Supply_Chain_Supply_Chain_halton_pow2 + 0.007769887801259756 * n_1_3Supply_Chain_Supply_Chain_halton_pow2 + -0.06384807080030441), 0));
var float: n_2_3Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_2_3Supply_Chain_Supply_Chain_halton_pow2 = max((0.5065627694129944 * n_1_0Supply_Chain_Supply_Chain_halton_pow2 + 0.2402118593454361 * n_1_1Supply_Chain_Supply_Chain_halton_pow2 + 0.3665074408054352 * n_1_2Supply_Chain_Supply_Chain_halton_pow2 + 0.01508941501379013 * n_1_3Supply_Chain_Supply_Chain_halton_pow2 + -1.55474054813385), 0));
% Layer 3
var float: n_3_0Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_3_0Supply_Chain_Supply_Chain_halton_pow2 = (0.4332108795642853 * n_2_0Supply_Chain_Supply_Chain_halton_pow2 + -0.17894293367862701 * n_2_1Supply_Chain_Supply_Chain_halton_pow2 + 8.031689643859863 * n_2_2Supply_Chain_Supply_Chain_halton_pow2 + -15.61497974395752 * n_2_3Supply_Chain_Supply_Chain_halton_pow2 + -0.34938257932662964));
var float: n_3_1Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_3_1Supply_Chain_Supply_Chain_halton_pow2 = (-0.5081174373626709 * n_2_0Supply_Chain_Supply_Chain_halton_pow2 + 0.12117163091897964 * n_2_1Supply_Chain_Supply_Chain_halton_pow2 + -0.19428512454032898 * n_2_2Supply_Chain_Supply_Chain_halton_pow2 + 1.3649752140045166 * n_2_3Supply_Chain_Supply_Chain_halton_pow2 + -0.9034901857376099));
var float: n_3_2Supply_Chain_Supply_Chain_halton_pow2;
constraint (n_3_2Supply_Chain_Supply_Chain_halton_pow2 = (0.3744771182537079 * n_2_0Supply_Chain_Supply_Chain_halton_pow2 + -0.85221266746521 * n_2_1Supply_Chain_Supply_Chain_halton_pow2 + 0.33222025632858276 * n_2_2Supply_Chain_Supply_Chain_halton_pow2 + -0.9835948348045349 * n_2_3Supply_Chain_Supply_Chain_halton_pow2 + 0.47186148166656494));
% Add activation function
constraint (lost_ratio_sales_ret * (1 + n_3_0Supply_Chain_Supply_Chain_halton_pow2 * n_3_0Supply_Chain_Supply_Chain_halton_pow2) = 1);
constraint (lost_ratio_sales_dis * (1 + n_3_1Supply_Chain_Supply_Chain_halton_pow2 * n_3_1Supply_Chain_Supply_Chain_halton_pow2) = 1);
constraint (lost_ratio_sales_fac * (1 + n_3_2Supply_Chain_Supply_Chain_halton_pow2 * n_3_2Supply_Chain_Supply_Chain_halton_pow2) = 1);
