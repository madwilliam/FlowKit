input_dir = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
out_dir = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/Analysis/two_step_radon';
annalyzer = RadonAnnalyzer(@two_step_radon,0.25);
annalyzer.run_batch_radon_analysis(input_dir,out_dir);
%%
out_dir = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/Analysis/roi_radon';
annalyzer = RadonAnnalyzer(@roi_radon,1);
annalyzer.radon_window_size=500;
annalyzer.run_batch_radon_analysis(input_dir,out_dir,1,1,1,1000);

[theta_fine,radius,max_val] = two_step_radon(data_chunk,angles_to_detect)