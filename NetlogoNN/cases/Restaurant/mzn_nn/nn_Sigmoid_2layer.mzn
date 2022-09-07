% auto generated file, representing a neural network
% features in: ['buy1', 'buy2']
% features out: ['succes_ratio', 'spoil_ratio']
% layerCount: 3
% layerWidth: 6

% use these to access output parameters
var float: succes_ratio;
var float: spoil_ratio;


% Node constraints
% Layer 0
var float: n_0_0_2layer;
constraint (n_0_0_2layer = max((1.2684845924377441 * buy1 + -0.11880819499492645 * buy2 + -0.23536694049835205), 0));
var float: n_0_1_2layer;
constraint (n_0_1_2layer = max((-0.12294458597898483 * buy1 + 0.9293071031570435 * buy2 + 0.1879625767469406), 0));
var float: n_0_2_2layer;
constraint (n_0_2_2layer = max((-0.7208927273750305 * buy1 + 0.22409433126449585 * buy2 + 0.6986677050590515), 0));
var float: n_0_3_2layer;
constraint (n_0_3_2layer = max((-0.4179134666919708 * buy1 + 0.46246710419654846 * buy2 + -0.4755569398403168), 0));
var float: n_0_4_2layer;
constraint (n_0_4_2layer = max((-0.3756007254123688 * buy1 + 0.3455480635166168 * buy2 + -0.2843681871891022), 0));
var float: n_0_5_2layer;
constraint (n_0_5_2layer = max((0.2515687942504883 * buy1 + 0.6511248350143433 * buy2 + -0.687221884727478), 0));
% Layer 1
var float: n_1_0_2layer;
constraint (n_1_0_2layer = max((-0.039985254406929016 * n_0_0_2layer + -0.4777132272720337 * n_0_1_2layer + 0.5548160076141357 * n_0_2_2layer + -0.08243560045957565 * n_0_3_2layer + 0.09791359305381775 * n_0_4_2layer + 0.3197384476661682 * n_0_5_2layer + 0.03452504053711891), 0));
var float: n_1_1_2layer;
constraint (n_1_1_2layer = max((0.05545647442340851 * n_0_0_2layer + 0.46015191078186035 * n_0_1_2layer + -0.5080711245536804 * n_0_2_2layer + -0.6356803774833679 * n_0_3_2layer + -0.7561185359954834 * n_0_4_2layer + -0.49391189217567444 * n_0_5_2layer + -0.040175747126340866), 0));
var float: n_1_2_2layer;
constraint (n_1_2_2layer = max((0.3389221429824829 * n_0_0_2layer + -0.17949728667736053 * n_0_1_2layer + -0.011312572285532951 * n_0_2_2layer + -0.08641347289085388 * n_0_3_2layer + 0.4148087799549103 * n_0_4_2layer + -0.031486429274082184 * n_0_5_2layer + 0.6612830758094788), 0));
var float: n_1_3_2layer;
constraint (n_1_3_2layer = max((-0.527433454990387 * n_0_0_2layer + -0.24893201887607574 * n_0_1_2layer + -0.16928699612617493 * n_0_2_2layer + 0.14418530464172363 * n_0_3_2layer + 0.3683360815048218 * n_0_4_2layer + 0.6939964890480042 * n_0_5_2layer + 0.18342900276184082), 0));
var float: n_1_4_2layer;
constraint (n_1_4_2layer = max((-0.030327655375003815 * n_0_0_2layer + 0.3747934103012085 * n_0_1_2layer + 0.44696635007858276 * n_0_2_2layer + 0.826103925704956 * n_0_3_2layer + 0.6851407289505005 * n_0_4_2layer + -0.21632011234760284 * n_0_5_2layer + -0.4919511377811432), 0));
var float: n_1_5_2layer;
constraint (n_1_5_2layer = max((0.28528904914855957 * n_0_0_2layer + 0.3173474967479706 * n_0_1_2layer + -0.3519384264945984 * n_0_2_2layer + 0.13842393457889557 * n_0_3_2layer + -0.02575266733765602 * n_0_4_2layer + 0.5324846506118774 * n_0_5_2layer + 0.102070651948452), 0));
% Layer 2
var float: n_2_0_2layer;
constraint (n_2_0_2layer = max((0.7254809737205505 * n_1_0_2layer + -0.158151775598526 * n_1_1_2layer + 0.06627116352319717 * n_1_2_2layer + -0.7017694711685181 * n_1_3_2layer + -0.23097220063209534 * n_1_4_2layer + -0.3383421301841736 * n_1_5_2layer + 0.4634270966053009), 0));
var float: n_2_1_2layer;
constraint (n_2_1_2layer = max((-0.36265724897384644 * n_1_0_2layer + -0.09769564867019653 * n_1_1_2layer + 0.25739938020706177 * n_1_2_2layer + -0.00030003144638612866 * n_1_3_2layer + -0.23512785136699677 * n_1_4_2layer + -0.39333856105804443 * n_1_5_2layer + -0.2690373361110687), 0));
var float: n_2_2_2layer;
constraint (n_2_2_2layer = max((0.5846797227859497 * n_1_0_2layer + 0.7438527345657349 * n_1_1_2layer + -0.04278697073459625 * n_1_2_2layer + 0.14833809435367584 * n_1_3_2layer + 0.44110041856765747 * n_1_4_2layer + 0.532889187335968 * n_1_5_2layer + -0.2959105670452118), 0));
var float: n_2_3_2layer;
constraint (n_2_3_2layer = max((-0.3927273154258728 * n_1_0_2layer + -0.3861335217952728 * n_1_1_2layer + 0.7808426022529602 * n_1_2_2layer + 0.8757143020629883 * n_1_3_2layer + 0.6327165365219116 * n_1_4_2layer + 0.1735365092754364 * n_1_5_2layer + 0.28875818848609924), 0));
var float: n_2_4_2layer;
constraint (n_2_4_2layer = max((0.06222039833664894 * n_1_0_2layer + 0.17534734308719635 * n_1_1_2layer + -0.1851634979248047 * n_1_2_2layer + 0.43594762682914734 * n_1_3_2layer + -0.6868249773979187 * n_1_4_2layer + 0.32748398184776306 * n_1_5_2layer + -0.326729953289032), 0));
var float: n_2_5_2layer;
constraint (n_2_5_2layer = max((0.4558408558368683 * n_1_0_2layer + 0.5500897765159607 * n_1_1_2layer + -0.1384185403585434 * n_1_2_2layer + 0.10279779136180878 * n_1_3_2layer + 0.007728760130703449 * n_1_4_2layer + 0.5846500992774963 * n_1_5_2layer + -0.3540263772010803), 0));
% Layer 3
var float: n_3_0_2layer;
constraint (n_3_0_2layer = (-0.53623366355896 * n_2_0_2layer + -0.2525121867656708 * n_2_1_2layer + 0.2939530909061432 * n_2_2_2layer + -0.44607388973236084 * n_2_3_2layer + 0.637131929397583 * n_2_4_2layer + 0.6305244565010071 * n_2_5_2layer + -0.9348931312561035));
var float: n_3_1_2layer;
constraint (n_3_1_2layer = (-0.6732467412948608 * n_2_0_2layer + -0.02724045142531395 * n_2_1_2layer + 0.023887593299150467 * n_2_2_2layer + 0.7484855651855469 * n_2_3_2layer + -0.22188539803028107 * n_2_4_2layer + -0.28570088744163513 * n_2_5_2layer + -0.3948432505130768));
% Add activation function
constraint (succes_ratio * (1 + exp(-n_3_0_2layer)) = 1.0);
constraint (spoil_ratio * (1 + exp(-n_3_1_2layer)) = 1.0);
