raw_data_path = '/net/dk-server/bholloway/Zhongkai/CBF Data';
out_put_dir='/net/dk-server/bholloway/Zhongkai/Tifs and Mats';
parpool(16)
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_put_dir );
% update_start_and_end_time( pmt_files, meta_files, out_put_dir );
generate_analysis_result(out_put_dir);

