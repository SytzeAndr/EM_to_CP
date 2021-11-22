% auto generated file, representing a neural network
% features in: ['buy1', 'buy2']
% features out: ['succes_ratio', 'spoil_ratio']
% layerCount: 2
% layerWidth: 6

% use these to access output parameters
array[Time] of var float: succes_ratio;
array[Time] of var float: spoil_ratio;


% Node constraints
% Layer 0
array[Time] of var float: n_0_0_2layer_sig;
constraint forall(t in Time) (n_0_0_2layer_sig[t] = max((-0.13933873176574707 * buy1[t] + 0.8214539289474487 * buy2[t] + -0.2737421989440918), 0));
array[Time] of var float: n_0_1_2layer_sig;
constraint forall(t in Time) (n_0_1_2layer_sig[t] = max((0.7829320430755615 * buy1[t] + -0.44379526376724243 * buy2[t] + 0.4719366431236267), 0));
array[Time] of var float: n_0_2_2layer_sig;
constraint forall(t in Time) (n_0_2_2layer_sig[t] = max((0.44371628761291504 * buy1[t] + 0.022542642429471016 * buy2[t] + -0.20377254486083984), 0));
array[Time] of var float: n_0_3_2layer_sig;
constraint forall(t in Time) (n_0_3_2layer_sig[t] = max((0.7001592516899109 * buy1[t] + -0.9288433194160461 * buy2[t] + 0.016083380207419395), 0));
array[Time] of var float: n_0_4_2layer_sig;
constraint forall(t in Time) (n_0_4_2layer_sig[t] = max((0.1255946308374405 * buy1[t] + 0.7754433751106262 * buy2[t] + -0.5462579131126404), 0));
array[Time] of var float: n_0_5_2layer_sig;
constraint forall(t in Time) (n_0_5_2layer_sig[t] = max((0.3912462592124939 * buy1[t] + 0.07051882892847061 * buy2[t] + -0.8893921375274658), 0));
% Layer 1
array[Time] of var float: n_1_0_2layer_sig;
constraint forall(t in Time) (n_1_0_2layer_sig[t] = max((0.22028294205665588 * n_0_0_2layer_sig[t] + -0.9505602717399597 * n_0_1_2layer_sig[t] + -0.4476681351661682 * n_0_2_2layer_sig[t] + 0.6193693280220032 * n_0_3_2layer_sig[t] + 0.23619277775287628 * n_0_4_2layer_sig[t] + -0.33238330483436584 * n_0_5_2layer_sig[t] + 0.487433522939682), 0));
array[Time] of var float: n_1_1_2layer_sig;
constraint forall(t in Time) (n_1_1_2layer_sig[t] = max((0.20129472017288208 * n_0_0_2layer_sig[t] + -0.12072665244340897 * n_0_1_2layer_sig[t] + -0.16977910697460175 * n_0_2_2layer_sig[t] + 0.03830959275364876 * n_0_3_2layer_sig[t] + -0.03951368108391762 * n_0_4_2layer_sig[t] + -0.29171738028526306 * n_0_5_2layer_sig[t] + 1.2527437210083008), 0));
array[Time] of var float: n_1_2_2layer_sig;
constraint forall(t in Time) (n_1_2_2layer_sig[t] = max((0.4915744960308075 * n_0_0_2layer_sig[t] + 0.06757837533950806 * n_0_1_2layer_sig[t] + 0.33709320425987244 * n_0_2_2layer_sig[t] + -0.15320467948913574 * n_0_3_2layer_sig[t] + -0.507572591304779 * n_0_4_2layer_sig[t] + -0.11494665592908859 * n_0_5_2layer_sig[t] + -0.26030033826828003), 0));
array[Time] of var float: n_1_3_2layer_sig;
constraint forall(t in Time) (n_1_3_2layer_sig[t] = max((0.017329558730125427 * n_0_0_2layer_sig[t] + 0.03394348546862602 * n_0_1_2layer_sig[t] + -0.3840668201446533 * n_0_2_2layer_sig[t] + 0.09634099155664444 * n_0_3_2layer_sig[t] + -0.049340758472681046 * n_0_4_2layer_sig[t] + 0.2475760132074356 * n_0_5_2layer_sig[t] + -0.01951109804213047), 0));
array[Time] of var float: n_1_4_2layer_sig;
constraint forall(t in Time) (n_1_4_2layer_sig[t] = max((-0.16348741948604584 * n_0_0_2layer_sig[t] + 0.543686032295227 * n_0_1_2layer_sig[t] + 0.1405116319656372 * n_0_2_2layer_sig[t] + 0.5009548664093018 * n_0_3_2layer_sig[t] + -0.23181527853012085 * n_0_4_2layer_sig[t] + 0.0016754009993746877 * n_0_5_2layer_sig[t] + -0.3194059729576111), 0));
array[Time] of var float: n_1_5_2layer_sig;
constraint forall(t in Time) (n_1_5_2layer_sig[t] = max((0.5682896971702576 * n_0_0_2layer_sig[t] + -0.04782582446932793 * n_0_1_2layer_sig[t] + 0.19958443939685822 * n_0_2_2layer_sig[t] + 0.1482628881931305 * n_0_3_2layer_sig[t] + 0.7124266028404236 * n_0_4_2layer_sig[t] + 0.25140607357025146 * n_0_5_2layer_sig[t] + -0.32968515157699585), 0));
% Layer 2
array[Time] of var float: n_2_0_2layer_sig;
constraint forall(t in Time) (n_2_0_2layer_sig[t] = (-0.4892268478870392 * n_1_0_2layer_sig[t] + -0.8774593472480774 * n_1_1_2layer_sig[t] + 0.4881269931793213 * n_1_2_2layer_sig[t] + 0.3973095417022705 * n_1_3_2layer_sig[t] + -0.253823459148407 * n_1_4_2layer_sig[t] + 0.38956037163734436 * n_1_5_2layer_sig[t] + -0.2960200011730194));
array[Time] of var float: n_2_1_2layer_sig;
constraint forall(t in Time) (n_2_1_2layer_sig[t] = (0.9708850383758545 * n_1_0_2layer_sig[t] + -0.3298981189727783 * n_1_1_2layer_sig[t] + 0.26338499784469604 * n_1_2_2layer_sig[t] + 0.3271954655647278 * n_1_3_2layer_sig[t] + 0.40173807740211487 * n_1_4_2layer_sig[t] + 0.11598881334066391 * n_1_5_2layer_sig[t] + -0.04158942401409149));
% Add activation function
constraint forall(t in Time) (succes_ratio[t] * (1 + exp(-n_2_0_2layer_sig[t])) = 1.0);
constraint forall(t in Time) (spoil_ratio[t] * (1 + exp(-n_2_1_2layer_sig[t])) = 1.0);
