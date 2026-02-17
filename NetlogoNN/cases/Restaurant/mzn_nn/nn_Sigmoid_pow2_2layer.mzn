% auto generated file, representing a neural network
% features in: ['buy1', 'buy2']
% features out: ['succes_ratio', 'spoil_ratio']
% layerCount: 2
% layerWidth: 6

% use these to access output parameters
var float: succes_ratio;
var float: spoil_ratio;


% Node constraints
% Layer 0
var float: n_0_0_pow2_2layer;
constraint (n_0_0_pow2_2layer = max((0.34992852807044983 * buy1 + -0.6859040260314941 * buy2 + 0.1536545306444168), 0));
var float: n_0_1_pow2_2layer;
constraint (n_0_1_pow2_2layer = max((0.03820507973432541 * buy1 + -0.6628877520561218 * buy2 + -0.3443681299686432), 0));
var float: n_0_2_pow2_2layer;
constraint (n_0_2_pow2_2layer = max((-0.5320314764976501 * buy1 + 0.37246590852737427 * buy2 + -0.00023741448239888996), 0));
var float: n_0_3_pow2_2layer;
constraint (n_0_3_pow2_2layer = max((0.1796044111251831 * buy1 + -0.5206766724586487 * buy2 + -0.05427337437868118), 0));
var float: n_0_4_pow2_2layer;
constraint (n_0_4_pow2_2layer = max((0.5870641469955444 * buy1 + 0.38226234912872314 * buy2 + 0.020060159265995026), 0));
var float: n_0_5_pow2_2layer;
constraint (n_0_5_pow2_2layer = max((0.44683489203453064 * buy1 + -0.5452951788902283 * buy2 + 0.09841245412826538), 0));
% Layer 1
var float: n_1_0_pow2_2layer;
constraint (n_1_0_pow2_2layer = max((0.3798191249370575 * n_0_0_pow2_2layer + 0.12573948502540588 * n_0_1_pow2_2layer + 0.10418843477964401 * n_0_2_pow2_2layer + -0.2900325357913971 * n_0_3_pow2_2layer + -0.05718468874692917 * n_0_4_pow2_2layer + -0.1974772959947586 * n_0_5_pow2_2layer + 0.41819995641708374), 0));
var float: n_1_1_pow2_2layer;
constraint (n_1_1_pow2_2layer = max((-0.33730974793434143 * n_0_0_pow2_2layer + -0.33076879382133484 * n_0_1_pow2_2layer + 0.21897387504577637 * n_0_2_pow2_2layer + -0.05158598721027374 * n_0_3_pow2_2layer + -0.44320034980773926 * n_0_4_pow2_2layer + 0.35210275650024414 * n_0_5_pow2_2layer + 0.034914739429950714), 0));
var float: n_1_2_pow2_2layer;
constraint (n_1_2_pow2_2layer = max((0.2797694504261017 * n_0_0_pow2_2layer + -0.12537825107574463 * n_0_1_pow2_2layer + 0.4957161545753479 * n_0_2_pow2_2layer + 0.4711128771305084 * n_0_3_pow2_2layer + -0.020158302038908005 * n_0_4_pow2_2layer + 0.35891714692115784 * n_0_5_pow2_2layer + 0.20994815230369568), 0));
var float: n_1_3_pow2_2layer;
constraint (n_1_3_pow2_2layer = max((-0.30122441053390503 * n_0_0_pow2_2layer + -0.06502552330493927 * n_0_1_pow2_2layer + 0.23271703720092773 * n_0_2_pow2_2layer + 0.14709021151065826 * n_0_3_pow2_2layer + -0.18342897295951843 * n_0_4_pow2_2layer + 0.10886471718549728 * n_0_5_pow2_2layer + -0.25870564579963684), 0));
var float: n_1_4_pow2_2layer;
constraint (n_1_4_pow2_2layer = max((0.11769969016313553 * n_0_0_pow2_2layer + 0.38865232467651367 * n_0_1_pow2_2layer + 0.10737897455692291 * n_0_2_pow2_2layer + 0.42316457629203796 * n_0_3_pow2_2layer + -0.10179144144058228 * n_0_4_pow2_2layer + 0.248104989528656 * n_0_5_pow2_2layer + 0.8382107019424438), 0));
var float: n_1_5_pow2_2layer;
constraint (n_1_5_pow2_2layer = max((0.07881924510002136 * n_0_0_pow2_2layer + -0.11839830130338669 * n_0_1_pow2_2layer + -0.13275417685508728 * n_0_2_pow2_2layer + 0.1818002462387085 * n_0_3_pow2_2layer + -0.08498691022396088 * n_0_4_pow2_2layer + -0.029632631689310074 * n_0_5_pow2_2layer + 0.7604946494102478), 0));
% Layer 2
var float: n_2_0_pow2_2layer;
constraint (n_2_0_pow2_2layer = (-0.7561257481575012 * n_1_0_pow2_2layer + 0.03564310446381569 * n_1_1_pow2_2layer + -0.23444099724292755 * n_1_2_pow2_2layer + -0.013484170660376549 * n_1_3_pow2_2layer + -0.49739769101142883 * n_1_4_pow2_2layer + -0.6048319935798645 * n_1_5_pow2_2layer + -0.20694147050380707));
var float: n_2_1_pow2_2layer;
constraint (n_2_1_pow2_2layer = (-0.20989927649497986 * n_1_0_pow2_2layer + -0.38808754086494446 * n_1_1_pow2_2layer + -0.49252352118492126 * n_1_2_pow2_2layer + 0.62294602394104 * n_1_3_pow2_2layer + 0.1760367900133133 * n_1_4_pow2_2layer + 0.5163780450820923 * n_1_5_pow2_2layer + 0.5819405913352966));
% Add activation function
constraint (succes_ratio * (1 + n_2_0_pow2_2layer * n_2_0_pow2_2layer) = 1);
constraint (spoil_ratio * (1 + n_2_1_pow2_2layer * n_2_1_pow2_2layer) = 1);
