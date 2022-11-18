% raw_data_path = '/net/dk-server/bholloway/Zhongkai/CBF Data';
<<<<<<< HEAD
out_dir='/net/dk-server/bholloway/Zhongkai/Tifs and Mats';
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_dir );
update_start_and_end_time( pmt_files, meta_files, out_put_dir );
%generate_analysis_result(out_dir);
=======
out_dir='Z:\Zhongkai\temp\';
% parpool(16)
%meta_files = FileHandler.get_meta_files(raw_data_path);
% pmt_files = FileHandler.get_pmt_files(raw_data_path);
% pmtToTiff( pmt_files, meta_files, out_dir );
% update_start_and_end_time( pmt_files, meta_files, out_put_dir );
generate_analysis_result(out_dir);
>>>>>>> f3030c93718083a6cdf36a6da4d762a95dc37def

