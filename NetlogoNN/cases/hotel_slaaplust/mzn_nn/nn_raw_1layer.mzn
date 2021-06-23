% auto generated file, representing a neural network
% features in: ['receptionists_amount', 'p_incoming_t1', 'p_incoming_t3', 'p_showup', 'spread_factor', 'satisfied_max_quetime', 'checkin_max_quetime', 'reservation_max_quetime', 't1_duration', 't2_duration', 't3_duration', 't4_duration', 't5_duration', 't6_duration', 'spread_horizon', 'stay_duration', 'time_between_t1_and_t3']
% features out: ['mean_no_show_times', 'var_no_show_times']
% layerCount: 2
% layerWidth: 6

% use these to access output parameters
array[Time] of var float: mean_no_show_times;
array[Time] of var float: var_no_show_times;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_raw;
constraint forall(t in Time) (n_0_0_raw[t] = max((-8.11348819732666 * receptionists_amount[t] + 34.318294525146484 * p_incoming_t1[t] + 20.467288970947266 * p_incoming_t3[t] + -29.01137924194336 * p_showup[t] + 11.113906860351562 * spread_factor[t] + 11.991146087646484 * satisfied_max_quetime[t] + -4.208023548126221 * checkin_max_quetime[t] + 17.657127380371094 * reservation_max_quetime[t] + -0.2717128098011017 * t1_duration[t] + -0.12294768542051315 * t2_duration[t] + 4.073569297790527 * t3_duration[t] + 10.892740249633789 * t4_duration[t] + 4.293010234832764 * t5_duration[t] + -4.767108917236328 * t6_duration[t] + 0.5828095078468323 * spread_horizon[t] + -0.2727639973163605 * stay_duration[t] + -2.061824083328247 * time_between_t1_and_t3[t] + 11.17400074005127), 0));
array[Time] of var float: n_0_1_raw;
constraint forall(t in Time) (n_0_1_raw[t] = max((-4.98801851272583 * receptionists_amount[t] + 36.78458786010742 * p_incoming_t1[t] + 28.277873992919922 * p_incoming_t3[t] + -27.244674682617188 * p_showup[t] + 12.129670143127441 * spread_factor[t] + 11.359116554260254 * satisfied_max_quetime[t] + 0.5173043012619019 * checkin_max_quetime[t] + 17.771106719970703 * reservation_max_quetime[t] + 1.2097384929656982 * t1_duration[t] + 2.8732268810272217 * t2_duration[t] + 6.204626083374023 * t3_duration[t] + 8.99301815032959 * t4_duration[t] + 5.308727264404297 * t5_duration[t] + 1.7121487855911255 * t6_duration[t] + -0.09672564268112183 * spread_horizon[t] + -0.040870726108551025 * stay_duration[t] + 0.052881889045238495 * time_between_t1_and_t3[t] + 13.740312576293945), 0));
array[Time] of var float: n_0_2_raw;
constraint forall(t in Time) (n_0_2_raw[t] = max((-6.314472198486328 * receptionists_amount[t] + 37.86844253540039 * p_incoming_t1[t] + 28.323461532592773 * p_incoming_t3[t] + -27.240982055664062 * p_showup[t] + 12.353164672851562 * spread_factor[t] + 12.906132698059082 * satisfied_max_quetime[t] + 0.637352466583252 * checkin_max_quetime[t] + 18.458309173583984 * reservation_max_quetime[t] + 0.005768908653408289 * t1_duration[t] + 2.1165568828582764 * t2_duration[t] + 5.272967338562012 * t3_duration[t] + 8.418864250183105 * t4_duration[t] + 5.810680389404297 * t5_duration[t] + 1.0610072612762451 * t6_duration[t] + 0.05653674155473709 * spread_horizon[t] + -0.2540367841720581 * stay_duration[t] + -0.009868365712463856 * time_between_t1_and_t3[t] + 14.093230247497559), 0));
array[Time] of var float: n_0_3_raw;
constraint forall(t in Time) (n_0_3_raw[t] = max((-5.8437042236328125 * receptionists_amount[t] + 36.638519287109375 * p_incoming_t1[t] + 26.27382469177246 * p_incoming_t3[t] + -26.89153480529785 * p_showup[t] + 12.365215301513672 * spread_factor[t] + 13.916255950927734 * satisfied_max_quetime[t] + 1.8304798603057861 * checkin_max_quetime[t] + 18.935821533203125 * reservation_max_quetime[t] + -1.2797874212265015 * t1_duration[t] + 1.4884001016616821 * t2_duration[t] + 5.000082969665527 * t3_duration[t] + 10.482644081115723 * t4_duration[t] + 4.97435188293457 * t5_duration[t] + 1.4351520538330078 * t6_duration[t] + 0.07854439318180084 * spread_horizon[t] + -0.3099864423274994 * stay_duration[t] + -0.7663266658782959 * time_between_t1_and_t3[t] + 14.008593559265137), 0));
array[Time] of var float: n_0_4_raw;
constraint forall(t in Time) (n_0_4_raw[t] = max((-6.263774871826172 * receptionists_amount[t] + 37.830081939697266 * p_incoming_t1[t] + 28.347978591918945 * p_incoming_t3[t] + -27.208641052246094 * p_showup[t] + 12.20452880859375 * spread_factor[t] + 12.680815696716309 * satisfied_max_quetime[t] + 0.8147150874137878 * checkin_max_quetime[t] + 18.3304500579834 * reservation_max_quetime[t] + -0.013812229968607426 * t1_duration[t] + 2.180372476577759 * t2_duration[t] + 5.281925678253174 * t3_duration[t] + 8.351487159729004 * t4_duration[t] + 5.895033836364746 * t5_duration[t] + 1.1643778085708618 * t6_duration[t] + 0.05274440720677376 * spread_horizon[t] + -0.27316200733184814 * stay_duration[t] + -0.008814873173832893 * time_between_t1_and_t3[t] + 14.165877342224121), 0));
array[Time] of var float: n_0_5_raw;
constraint forall(t in Time) (n_0_5_raw[t] = max((-6.447279453277588 * receptionists_amount[t] + 37.52924346923828 * p_incoming_t1[t] + 28.256681442260742 * p_incoming_t3[t] + -27.321674346923828 * p_showup[t] + 12.313901901245117 * spread_factor[t] + 12.482742309570312 * satisfied_max_quetime[t] + 0.5725298523902893 * checkin_max_quetime[t] + 18.541784286499023 * reservation_max_quetime[t] + -0.18186485767364502 * t1_duration[t] + 2.1654396057128906 * t2_duration[t] + 5.485168933868408 * t3_duration[t] + 8.315055847167969 * t4_duration[t] + 5.8364129066467285 * t5_duration[t] + 1.1469217538833618 * t6_duration[t] + 0.062048688530921936 * spread_horizon[t] + -0.18672597408294678 * stay_duration[t] + -0.06460952013731003 * time_between_t1_and_t3[t] + 14.07005500793457), 0));
% Layer 1
array[Time] of var float: n_1_0_raw;
constraint forall(t in Time) (n_1_0_raw[t] = max((16.017053604125977 * n_0_0_raw[t] + 10.830556869506836 * n_0_1_raw[t] + 11.81236743927002 * n_0_2_raw[t] + 13.689056396484375 * n_0_3_raw[t] + 11.734842300415039 * n_0_4_raw[t] + 11.54900074005127 * n_0_5_raw[t] + 25.22687530517578), 0));
array[Time] of var float: n_1_1_raw;
constraint forall(t in Time) (n_1_1_raw[t] = max((16.38156509399414 * n_0_0_raw[t] + 10.828166961669922 * n_0_1_raw[t] + 11.953226089477539 * n_0_2_raw[t] + 14.030376434326172 * n_0_3_raw[t] + 11.753063201904297 * n_0_4_raw[t] + 11.772418022155762 * n_0_5_raw[t] + 25.454212188720703), 0));
array[Time] of var float: n_1_2_raw;
constraint forall(t in Time) (n_1_2_raw[t] = max((16.368717193603516 * n_0_0_raw[t] + 10.737831115722656 * n_0_1_raw[t] + 11.878606796264648 * n_0_2_raw[t] + 14.143696784973145 * n_0_3_raw[t] + 11.871613502502441 * n_0_4_raw[t] + 11.706896781921387 * n_0_5_raw[t] + 25.190568923950195), 0));
array[Time] of var float: n_1_3_raw;
constraint forall(t in Time) (n_1_3_raw[t] = max((16.35385513305664 * n_0_0_raw[t] + 10.830554962158203 * n_0_1_raw[t] + 11.861793518066406 * n_0_2_raw[t] + 14.000012397766113 * n_0_3_raw[t] + 11.647966384887695 * n_0_4_raw[t] + 11.760576248168945 * n_0_5_raw[t] + 25.18221664428711), 0));
array[Time] of var float: n_1_4_raw;
constraint forall(t in Time) (n_1_4_raw[t] = max((-0.21726574003696442 * n_0_0_raw[t] + -0.0673142820596695 * n_0_1_raw[t] + -0.08081333339214325 * n_0_2_raw[t] + -0.00030250995769165456 * n_0_3_raw[t] + -0.051727525889873505 * n_0_4_raw[t] + -0.01622960716485977 * n_0_5_raw[t] + -0.0008966183522716165), 0));
array[Time] of var float: n_1_5_raw;
constraint forall(t in Time) (n_1_5_raw[t] = max((16.1364803314209 * n_0_0_raw[t] + 10.876254081726074 * n_0_1_raw[t] + 11.619278907775879 * n_0_2_raw[t] + 13.85484504699707 * n_0_3_raw[t] + 11.838658332824707 * n_0_4_raw[t] + 11.585173606872559 * n_0_5_raw[t] + 25.35225486755371), 0));
% Layer 2
array[Time] of var float: n_2_0_raw;
constraint forall(t in Time) (n_2_0_raw[t] = (0.0626530572772026 * n_1_0_raw[t] + -0.15332728624343872 * n_1_1_raw[t] + -0.01010710746049881 * n_1_2_raw[t] + 0.07805030792951584 * n_1_3_raw[t] + 0.03901318088173866 * n_1_4_raw[t] + 0.10420593619346619 * n_1_5_raw[t] + 35.285621643066406));
array[Time] of var float: n_2_1_raw;
constraint forall(t in Time) (n_2_1_raw[t] = (14.4033203125 * n_1_0_raw[t] + 14.505996704101562 * n_1_1_raw[t] + 14.688760757446289 * n_1_2_raw[t] + 14.547571182250977 * n_1_3_raw[t] + -0.056844886392354965 * n_1_4_raw[t] + 14.689160346984863 * n_1_5_raw[t] + 25.110977172851562));
% Add activation function
constraint forall(t in Time) (mean_no_show_times[t] = max(n_2_0_raw[t], 0));
constraint forall(t in Time) (var_no_show_times[t] = max(n_2_1_raw[t], 0));
