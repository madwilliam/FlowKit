function back_plot_from_mat(mat_file,start_and_stop)
load(fullfile(mat_file.folder, mat_file.name),'result','tif_file')
image = FileHandler.load_image_data(tif_file);
RadonBackPlotter.plot_detected_stripes(image,result,start_and_stop)
end