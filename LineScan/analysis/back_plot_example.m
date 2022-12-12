out_put_dir='C:\Users\dklab\Desktop\test';
mat_files = FileHandler.get_mat_files(out_put_dir);
mat_file = mat_files(2);
back_plot_from_mat(mat_file,[1 100])

%or
load(mat_path,'result','tif_file')
image = FileHandler.load_image_data(tif_path);
RadonBackPlotter.plot_detected_stripes(image,result,1:1000)