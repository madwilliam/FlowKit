raw_data_path = 'Y:\Zhongkai\CBF Data';
out_put_dir='Y:\Zhongkai\outpath';

meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_put_dir )
generate_analysis_result(out_put_dir)

