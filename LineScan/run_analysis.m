path = 'Y:\Data and Analysis\Data\Two Photon Directory';
tiff_path = 'Y:\Data and Analysis\Analysis';
mat_out_dir='C:\Users\dklab\Desktop\test';
tiff_out_dir = 'Y:\Data and Analysis\Analysis\old\AutoCropped';
meta_files = FileHandler.get_meta_files(path);
tif_files = FileHandler.get_tif_files(tiff_path);
pmt_files = FileHandler.get_pmt_files(path);

crop_tiffs(meta_files,tif_files,pmt_files,tiff_out_dir)
generate_analysis_result(meta_files,tif_files,pmt_files,mat_out_dir)
%generate spike files