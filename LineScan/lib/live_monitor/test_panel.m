%%
% panel = LineScanPanel(@DataSimulator.get_simulated_data_feed,64);
% panel = SimpleLineScanPanel(@DataSimulator.get_simulated_data_feed,64,100);
% %%
% panel =  LineScanPanel(@DataSimulator.get_one_radon_test,100);
% %%
% panel =  ImageLineScanSimulation('/net/dk-server/bholloway/Zhongkai/FoG/Pack-120821_03-12-22_OBISlaserPwr_9per_00005_roi_1.tif');
%%
% hSI.hDisplay.stripeDataBufferPointer = 1;
% lastStripe.rawData = DataSimulator.get_one_radon_test();
% hSI.hDisplay.stripeDataBuffer = {lastStripe};
% panel =  LineScanPanel(@get_live_data_feed);

%%
% f= LiveFeedManager.start_panel_in_background(@DataSimulator.get_simulated_data_feed,64,10);
%%
annalyzer = PassiveLiveRandonAnnalyzer(64,[],30,1,64,100);
%%
annalyzer.n_pixel=100;
for i = 1:100
    data_chunk = DataSimulator.get_simulated_data_feed(i);
    data_chunk = reshape(data_chunk,64,[]);
    annalyzer.add_data(data_chunk);
    plot(annalyzer.slope_data)
    pause(0.1)
end
%%
% data_chunk = DataSimulator.get_simulated_data_feed(60);
% data_chunk = reshape(data_chunk,[],100);
% result=get_slope_from_line_scan(data_chunk,annalyzer.radon_chunk_size,@max_and_variance_radon)
% %%
% data_chunk = DataSimulator.get_simulated_data_feed(61);
% data_chunk = reshape(data_chunk,[],100);
% result=get_slope_from_line_scan(data_chunk,annalyzer.radon_chunk_size,@max_and_variance_radon)
% 


