out_put_dir='C:\Users\dklab\Desktop\test';
mat_files = FileHandler.get_mat_files(out_put_dir);
mat_file = mat_files(2);
back_plot_from_mat(mat_file,[1 100])

%or
load(fullfile(mat_file.folder, mat_file.name),'result','tif_file')
image = FileHandler.load_image_data(tif_file);
Plotter.plot_detected_stripes(image,result,start_and_stop)