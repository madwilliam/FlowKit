%%
panel = LineScanPanel(@DataSimulator.get_simulated_data_feed,64,10);
%%
panel =  LineScanPanel(@DataSimulator.get_one_radon_test);
%%
panel =  ImageLineScanSimulation('/net/dk-server/bholloway/Zhongkai/FoG/Pack-120821_03-12-22_OBISlaserPwr_9per_00005_roi_1.tif');
%%
% hSI.hDisplay.stripeDataBufferPointer = 1;
% lastStripe.rawData = DataSimulator.get_one_radon_test();
% hSI.hDisplay.stripeDataBuffer = {lastStripe};
% panel =  LineScanPanel(@get_live_data_feed);

%%
%%run this on real scan machine
panel = start_live_panel(hSI);