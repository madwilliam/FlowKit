path = 'C:\Users\Montana\Documents\Server_Data and Analysis\Test';
tiff_path = 'C:\Users\Montana\Documents\Server_Data and Analysis\Test';
mat_out_dir='C:\Users\Montana\Documents\Server_Data and Analysis\Test\WilliamOutput';
tiff_out_dir = 'C:\Users\Montana\Documents\Server_Data and Analysis\Test\WilliamOutput';
meta_files = FileHandler.get_meta_files(path);
tif_files = FileHandler.get_tif_files(tiff_path);
pmt_files = FileHandler.get_pmt_files(path);

crop_tiffs(meta_files,tif_files,pmt_files,tiff_out_dir)
generate_analysis_result(meta_files,tif_files,pmt_files,mat_out_dir)
%generate spike files