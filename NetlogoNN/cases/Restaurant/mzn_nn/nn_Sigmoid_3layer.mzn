% auto generated file, representing a neural network
% features in: ['buy1', 'buy2']
% features out: ['succes_ratio', 'spoil_ratio']
% layerCount: 3
% layerWidth: 6

% use these to access output parameters
array[Time] of var float: succes_ratio;
array[Time] of var float: spoil_ratio;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_3layer_sig;
constraint forall(t in Time) (n_0_0_3layer_sig[t] = max((0.031253017485141754 * buy1[t] + -0.20745933055877686 * buy2[t] + -0.30410099029541016), 0));
array[Time] of var float: n_0_1_3layer_sig;
constraint forall(t in Time) (n_0_1_3layer_sig[t] = max((0.7125085592269897 * buy1[t] + 0.8776071667671204 * buy2[t] + 0.5465533137321472), 0));
array[Time] of var float: n_0_2_3layer_sig;
constraint forall(t in Time) (n_0_2_3layer_sig[t] = max((0.5132951736450195 * buy1[t] + 0.16624721884727478 * buy2[t] + -0.6371250152587891), 0));
array[Time] of var float: n_0_3_3layer_sig;
constraint forall(t in Time) (n_0_3_3layer_sig[t] = max((-0.21240316331386566 * buy1[t] + 0.10402179509401321 * buy2[t] + 0.6058915257453918), 0));
array[Time] of var float: n_0_4_3layer_sig;
constraint forall(t in Time) (n_0_4_3layer_sig[t] = max((-0.4307684302330017 * buy1[t] + 0.3806377649307251 * buy2[t] + 0.8494874238967896), 0));
array[Time] of var float: n_0_5_3layer_sig;
constraint forall(t in Time) (n_0_5_3layer_sig[t] = max((0.3042387366294861 * buy1[t] + -0.520136833190918 * buy2[t] + 0.749871015548706), 0));
% Layer 1
array[Time] of var float: n_1_0_3layer_sig;
constraint forall(t in Time) (n_1_0_3layer_sig[t] = max((0.057834699749946594 * n_0_0_3layer_sig[t] + 0.618968665599823 * n_0_1_3layer_sig[t] + 0.09958269447088242 * n_0_2_3layer_sig[t] + 0.6651567220687866 * n_0_3_3layer_sig[t] + -0.27969181537628174 * n_0_4_3layer_sig[t] + 0.7847997546195984 * n_0_5_3layer_sig[t] + 0.3659588694572449), 0));
array[Time] of var float: n_1_1_3layer_sig;
constraint forall(t in Time) (n_1_1_3layer_sig[t] = max((-0.10490575432777405 * n_0_0_3layer_sig[t] + -0.2082138955593109 * n_0_1_3layer_sig[t] + 0.46031704545021057 * n_0_2_3layer_sig[t] + -0.12151625007390976 * n_0_3_3layer_sig[t] + -0.0070152245461940765 * n_0_4_3layer_sig[t] + -0.28927722573280334 * n_0_5_3layer_sig[t] + 0.5753110647201538), 0));
array[Time] of var float: n_1_2_3layer_sig;
constraint forall(t in Time) (n_1_2_3layer_sig[t] = max((-0.07352659106254578 * n_0_0_3layer_sig[t] + 0.436151385307312 * n_0_1_3layer_sig[t] + 0.18374063074588776 * n_0_2_3layer_sig[t] + -0.7590959668159485 * n_0_3_3layer_sig[t] + 0.5500527024269104 * n_0_4_3layer_sig[t] + -0.6954249143600464 * n_0_5_3layer_sig[t] + 0.25316956639289856), 0));
array[Time] of var float: n_1_3_3layer_sig;
constraint forall(t in Time) (n_1_3_3layer_sig[t] = max((0.050211891531944275 * n_0_0_3layer_sig[t] + -0.07222486287355423 * n_0_1_3layer_sig[t] + 0.23159901797771454 * n_0_2_3layer_sig[t] + 0.043185506016016006 * n_0_3_3layer_sig[t] + 0.7497729659080505 * n_0_4_3layer_sig[t] + -0.0006594173610210419 * n_0_5_3layer_sig[t] + -0.6235331296920776), 0));
array[Time] of var float: n_1_4_3layer_sig;
constraint forall(t in Time) (n_1_4_3layer_sig[t] = max((-0.051155537366867065 * n_0_0_3layer_sig[t] + -0.2739808261394501 * n_0_1_3layer_sig[t] + 0.6156389713287354 * n_0_2_3layer_sig[t] + -0.362136572599411 * n_0_3_3layer_sig[t] + 0.6886484026908875 * n_0_4_3layer_sig[t] + -0.16690906882286072 * n_0_5_3layer_sig[t] + 0.37508851289749146), 0));
array[Time] of var float: n_1_5_3layer_sig;
constraint forall(t in Time) (n_1_5_3layer_sig[t] = max((0.1537855565547943 * n_0_0_3layer_sig[t] + -0.059522926807403564 * n_0_1_3layer_sig[t] + -0.039449386298656464 * n_0_2_3layer_sig[t] + 0.08574288338422775 * n_0_3_3layer_sig[t] + -0.13761162757873535 * n_0_4_3layer_sig[t] + -0.12056490778923035 * n_0_5_3layer_sig[t] + -0.1952608823776245), 0));
% Layer 2
array[Time] of var float: n_2_0_3layer_sig;
constraint forall(t in Time) (n_2_0_3layer_sig[t] = max((-0.49023300409317017 * n_1_0_3layer_sig[t] + 1.0664085149765015 * n_1_1_3layer_sig[t] + -0.004040065221488476 * n_1_2_3layer_sig[t] + 0.5354564785957336 * n_1_3_3layer_sig[t] + -0.30896541476249695 * n_1_4_3layer_sig[t] + 0.1461101472377777 * n_1_5_3layer_sig[t] + 0.16579541563987732), 0));
array[Time] of var float: n_2_1_3layer_sig;
constraint forall(t in Time) (n_2_1_3layer_sig[t] = max((-0.19528907537460327 * n_1_0_3layer_sig[t] + -0.14401781558990479 * n_1_1_3layer_sig[t] + -0.0756697803735733 * n_1_2_3layer_sig[t] + -0.08487246930599213 * n_1_3_3layer_sig[t] + -0.07238763570785522 * n_1_4_3layer_sig[t] + 0.1964646279811859 * n_1_5_3layer_sig[t] + -0.12240870296955109), 0));
array[Time] of var float: n_2_2_3layer_sig;
constraint forall(t in Time) (n_2_2_3layer_sig[t] = max((-0.10105282068252563 * n_1_0_3layer_sig[t] + 0.458048015832901 * n_1_1_3layer_sig[t] + 0.04814422130584717 * n_1_2_3layer_sig[t] + -3.3247275352478027 * n_1_3_3layer_sig[t] + 1.5966987609863281 * n_1_4_3layer_sig[t] + 0.12238697707653046 * n_1_5_3layer_sig[t] + 0.6866620779037476), 0));
array[Time] of var float: n_2_3_3layer_sig;
constraint forall(t in Time) (n_2_3_3layer_sig[t] = max((0.09720700234174728 * n_1_0_3layer_sig[t] + -2.03377628326416 * n_1_1_3layer_sig[t] + 0.8303729295730591 * n_1_2_3layer_sig[t] + -0.5767341256141663 * n_1_3_3layer_sig[t] + -0.6725355386734009 * n_1_4_3layer_sig[t] + 0.16612038016319275 * n_1_5_3layer_sig[t] + -0.12898068130016327), 0));
array[Time] of var float: n_2_4_3layer_sig;
constraint forall(t in Time) (n_2_4_3layer_sig[t] = max((0.7283750772476196 * n_1_0_3layer_sig[t] + 0.6704211831092834 * n_1_1_3layer_sig[t] + -0.23032274842262268 * n_1_2_3layer_sig[t] + 1.188297152519226 * n_1_3_3layer_sig[t] + -0.5857768058776855 * n_1_4_3layer_sig[t] + 0.1022336333990097 * n_1_5_3layer_sig[t] + 0.7498317360877991), 0));
array[Time] of var float: n_2_5_3layer_sig;
constraint forall(t in Time) (n_2_5_3layer_sig[t] = max((0.19864362478256226 * n_1_0_3layer_sig[t] + -1.8989592790603638 * n_1_1_3layer_sig[t] + 0.06931592524051666 * n_1_2_3layer_sig[t] + -1.589583396911621 * n_1_3_3layer_sig[t] + -1.004448652267456 * n_1_4_3layer_sig[t] + -0.056537359952926636 * n_1_5_3layer_sig[t] + -0.5658463835716248), 0));
% Layer 3
array[Time] of var float: n_3_0_3layer_sig;
constraint forall(t in Time) (n_3_0_3layer_sig[t] = (1.2583991289138794 * n_2_0_3layer_sig[t] + 0.05236397683620453 * n_2_1_3layer_sig[t] + -0.5586700439453125 * n_2_2_3layer_sig[t] + 0.9415854215621948 * n_2_3_3layer_sig[t] + -0.5379956364631653 * n_2_4_3layer_sig[t] + 0.7698145508766174 * n_2_5_3layer_sig[t] + -0.7583211660385132));
array[Time] of var float: n_3_1_3layer_sig;
constraint forall(t in Time) (n_3_1_3layer_sig[t] = (-0.1573522835969925 * n_2_0_3layer_sig[t] + -0.005730045028030872 * n_2_1_3layer_sig[t] + -2.9321248531341553 * n_2_2_3layer_sig[t] + -0.550321102142334 * n_2_3_3layer_sig[t] + 0.7119452357292175 * n_2_4_3layer_sig[t] + 0.4322153329849243 * n_2_5_3layer_sig[t] + 0.5497444272041321));
% Add activation function
constraint forall(t in Time) (succes_ratio[t] * (1 + exp(-n_3_0_3layer_sig[t])) = 1.0);
constraint forall(t in Time) (spoil_ratio[t] * (1 + exp(-n_3_1_3layer_sig[t])) = 1.0);
