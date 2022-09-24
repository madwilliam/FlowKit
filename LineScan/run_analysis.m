
raw_data_path = 'C:\Users\Montana\Documents\Server_Data and Analysis\CBF Data\';
tiff_path = 'C:\Users\Montana\Documents\Server_Data and Analysis\AutorunOutput\';
out_put_dir='C:\Users\Montana\Documents\Server_Data and Analysis\AutorunOutput\';

meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_put_dir )
generate_analysis_result(out_put_dir)