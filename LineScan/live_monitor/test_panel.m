%%
panel = LineScanPanel(@DataSimulator.get_simulated_data_feed,64);
panel = SimpleLineScanPanel(@DataSimulator.get_simulated_data_feed,64);
%%
panel =  LineScanPanel(@DataSimulator.get_one_radon_test,100);
%%
panel =  ImageLineScanSimulation('/net/dk-server/bholloway/Zhongkai/FoG/Pack-120821_03-12-22_OBISlaserPwr_9per_00005_roi_1.tif');
%%
% hSI.hDisplay.stripeDataBufferPointer = 1;
% lastStripe.rawData = DataSimulator.get_one_radon_test();
% hSI.hDisplay.stripeDataBuffer = {lastStripe};
% panel =  LineScanPanel(@get_live_data_feed);

%%
f = LiveFeedManager.start_panel_in_background(@DataSimulator.get_simulated_data_feed,64);