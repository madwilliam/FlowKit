raw_data_path = 'Y:\Data and Analysis\Data\Two Photon Directory';
out_put_dir='C:\Users\dklab\Desktop\test';

meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_put_dir )
generate_analysis_result(out_put_dir)

