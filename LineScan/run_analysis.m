<<<<<<< HEAD

raw_data_path = 'C:\Users\Montana\Documents\Server_Data and Analysis\CBF Data\';
tiff_path = 'C:\Users\Montana\Documents\Server_Data and Analysis\AutorunOutput\';
out_put_dir='C:\Users\Montana\Documents\Server_Data and Analysis\AutorunOutput\';

=======
raw_data_path = 'Y:\Data and Analysis\Data';
out_put_dir='C:\Users\dklab\Desktop\test';
>>>>>>> ee1def4c576b4c9d7743ebfe89c0c6d70769da62
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_put_dir )
generate_analysis_result(out_put_dir)

