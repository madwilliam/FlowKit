weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
tif_files = FileHandler.get_tif_files(mat_root);
mat_files = FileHandler.get_mat_files(mat_root);
weka_mat_files = FileHandler.get_mat_files(weka_root);
weka_tifs = FileHandler.get_tif_files(weka_root);
file_name = 'Pack-050522-NoCut_05-17-22_Vessel-2_CBF_00002_roi_1';
tif_path = FileHandler.get_file_path(tif_files,file_name);
mat_path = FileHandler.get_file_path(mat_files,file_name);
weka_mat_path = FileHandler.get_file_path(weka_mat_files,file_name);
weka_tif_path = FileHandler.get_file_path(weka_tifs,file_name);
Plotter.show_flow_speed_around_stimulation_weka(mat_path,tif_path,weka_mat_path)

%%
image = FileHandler.load_image_data(tif_path);
weka_image = FileHandler.load_image_data(weka_tif_path);
load(weka_mat_path,'stripe_statistics');
WekaAnalyzer.plot_stripe(weka_image,stripe_statistics,[1,1000])
WekaAnalyzer.plot_stripe(image,stripe_statistics,[109235,112232])

process_weka(file,weka_root)
%%
found = false;
files = weka_tifs;
for i =1:numel(files)
   name = FileHandler.strip_extensions(files(i).name);
   if strcmp(name,file_name)
       file = files(i);
       if found
           disp(append('more than one file found for ',file_name))
       else
           found = true;
       end
   end
end