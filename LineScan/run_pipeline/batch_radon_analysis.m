raw_data_path = '/net/dk-server/bholloway/Data and Analysis/Data/Two Photon Directory/Pack-100322';
out_dir='/net/dk-server/bholloway/Zhongkai/Pack-100322 Tifs and Mats new radon';
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_dir );
update_start_and_end_time( pmt_files, meta_files, out_dir );
annalyzer = RadonAnnalyzer(@two_step_radon,0.25);
annalyzer.run_batch_radon_analysis(out_dir);
% annalyzer = RadonAnnalyzer(@roi_radon,1);
% annalyzer.run_batch_radon_analysis(out_dir);

[theta_fine,radius,max_val] = two_step_radon(data_chunk,angles_to_detect)