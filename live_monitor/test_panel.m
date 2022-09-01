%%
panel = LineScanPanel(@get_simulated_data_feed,64,10);
%%
panel =  LineScanPanel(@DataSimulator.get_one_radon_test);

%%
persistent hSI
hSI.hDisplay.stripeDataBufferPointer = 1;
lastStripe.rawData = DataSimulator.get_one_radon_test();
hSI.hDisplay.stripeDataBuffer = {lastStripe};
panel =  LineScanPanel(@get_live_data_feed);