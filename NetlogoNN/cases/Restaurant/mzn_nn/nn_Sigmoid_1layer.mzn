% auto generated file, representing a neural network
% features in: ['buy1', 'buy2']
% features out: ['succes_ratio', 'spoil_ratio']
% layerCount: 1
% layerWidth: 6

% use these to access output parameters
array[Time] of var float: succes_ratio;
array[Time] of var float: spoil_ratio;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_1layer_sig;
constraint forall(t in Time) (n_0_0_1layer_sig[t] = max((-0.0716952383518219 * buy1[t] + -0.21271730959415436 * buy2[t] + 1.2153451442718506), 0));
array[Time] of var float: n_0_1_1layer_sig;
constraint forall(t in Time) (n_0_1_1layer_sig[t] = max((-0.6773457527160645 * buy1[t] + 0.5461635589599609 * buy2[t] + -0.00010683528671506792), 0));
array[Time] of var float: n_0_2_1layer_sig;
constraint forall(t in Time) (n_0_2_1layer_sig[t] = max((-0.9317048788070679 * buy1[t] + 0.6135537624359131 * buy2[t] + 0.05786718428134918), 0));
array[Time] of var float: n_0_3_1layer_sig;
constraint forall(t in Time) (n_0_3_1layer_sig[t] = max((0.6439339518547058 * buy1[t] + -0.8733808994293213 * buy2[t] + 0.27433741092681885), 0));
array[Time] of var float: n_0_4_1layer_sig;
constraint forall(t in Time) (n_0_4_1layer_sig[t] = max((-0.5570590496063232 * buy1[t] + -0.18807095289230347 * buy2[t] + -0.5469974279403687), 0));
array[Time] of var float: n_0_5_1layer_sig;
constraint forall(t in Time) (n_0_5_1layer_sig[t] = max((0.24402384459972382 * buy1[t] + 0.21188171207904816 * buy2[t] + -1.303227424621582), 0));
% Layer 1
array[Time] of var float: n_1_0_1layer_sig;
constraint forall(t in Time) (n_1_0_1layer_sig[t] = (-1.1735581159591675 * n_0_0_1layer_sig[t] + -0.17555685341358185 * n_0_1_1layer_sig[t] + -0.20253002643585205 * n_0_2_1layer_sig[t] + -0.23641179502010345 * n_0_3_1layer_sig[t] + -0.04843181371688843 * n_0_4_1layer_sig[t] + 0.7976044416427612 * n_0_5_1layer_sig[t] + 0.11548887938261032));
array[Time] of var float: n_1_1_1layer_sig;
constraint forall(t in Time) (n_1_1_1layer_sig[t] = (-0.20685650408267975 * n_0_0_1layer_sig[t] + 0.5774577856063843 * n_0_1_1layer_sig[t] + 0.46669629216194153 * n_0_2_1layer_sig[t] + 0.48441293835639954 * n_0_3_1layer_sig[t] + -0.09932932257652283 * n_0_4_1layer_sig[t] + 0.43217501044273376 * n_0_5_1layer_sig[t] + 0.02192622423171997));
% Add activation function
constraint forall(t in Time) (succes_ratio[t] * (1 + exp(-n_1_0_1layer_sig[t])) = 1.0);
constraint forall(t in Time) (spoil_ratio[t] * (1 + exp(-n_1_1_1layer_sig[t])) = 1.0);
