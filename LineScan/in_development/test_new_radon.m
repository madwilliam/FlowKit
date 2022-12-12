image_path = '/net/dk-server/bholloway/Zhongkai/Pack-100322 Tifs and Mats/diving_vessel_-180um_7xx_00011_roi_1.tif';
mat_path = '/net/dk-server/bholloway/Zhongkai/Pack-100322 Tifs and Mats/diving_vessel_-180um_7xx_00011_roi_1.mat';

image = FileHandler.load_image_data(image_path);
load(mat_path, 'start_time','end_time');
annalyzer = RadonAnnalyzer(@roi_radon,1);
annalyzer.radon_window_size = 100;
result=annalyzer.get_slope_from_line_scan(image,5,3);
RadonBackPlotter.plot_stipes_for_all_stimulation(image,start_time,end_time,result,true,nan,@RadonBackPlotter.get_plotting_information)

%%
down_sampling_factor = 3;
chunk_offset = 15000;
chunk_length = 1000;
nstimulus = numel(start_time);
stimulationi = 1
start_timei = start_time(stimulationi);
end_timei = end_time(stimulationi);
[imagers,all_slopes,all_locations] = RadonBackPlotter.get_plotting_information(image,...
   start_timei,end_timei,chunk_offset,chunk_length,result,down_sampling_factor);
RadonBackPlotter.plot_strips(imagers,all_locations,all_slopes,start_timei,...
   end_timei,chunk_offset,chunk_length,down_sampling_factor,1)


%%
figure
chunk = image(:,start_time-chunk_offset:start_time-chunk_offset+500);
imagesc(chunk);