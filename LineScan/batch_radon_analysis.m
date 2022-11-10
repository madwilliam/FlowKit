raw_data_path = '/scratch/line_scan_ben/PreAnal/';
out_dir='/scratch/line_scan_ben/new_batch';
parpool(48)
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_dir );
update_start_and_end_time( pmt_files, meta_files, out_dir );
% generate_analysis_result(out_dir);

