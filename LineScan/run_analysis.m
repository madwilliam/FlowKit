raw_data_path = 'Y:\Data and Analysis\Data\Two Photon Directory';
tiff_path = 'Y:\Data and Analysis\Analysis';
out_put_dir='C:\Users\dklab\Desktop\test';
meta_files = FileHandler.get_meta_files(raw_data_path);
tif_files = FileHandler.get_tif_files(tiff_path);
pmt_files = FileHandler.get_pmt_files(raw_data_path);

% crop_tiffs(meta_files,tif_files,pmt_files,tiff_path)
generate_analysis_result(meta_files,tif_files,pmt_files,out_put_dir)
%generate spike files