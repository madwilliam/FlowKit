raw_data_path = '/net/dk-server/bholloway/Data and Analysis/Data/Two Photon Directory/CBF';
out_dir='/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
meta_files = FileHandler.get_meta_files(raw_data_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);
pmtToTiff( pmt_files, meta_files, out_dir );