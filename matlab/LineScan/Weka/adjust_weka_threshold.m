weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
tif_files = FileHandler.get_tif_files(mat_root);
mat_files = FileHandler.get_mat_files(mat_root);
weka_mat_files = FileHandler.get_mat_files(weka_root);
weka_tifs = FileHandler.get_tif_files(weka_root);

% nweka = nume(weka_mat_files);
% for wekai = 1:nweka
%     weka_mat = weka_mat_files(wekai);
%     file_name = FileHandler.strip_extensions(weka_mat.name);
while true
    
    file_name = input('input file to examine\n','s');
    tif_path = FileHandler.get_file_path(tif_files,file_name);
    weka_mat_path = FileHandler.get_file_path(weka_mat_files,file_name);
    mat_path = FileHandler.get_file_path(mat_files,file_name);
    Plotter.show_flow_speed_around_stimulation_weka(mat_path,tif_path,weka_mat_path)
    pause(0.1)
    
    while true
        keep = input('keep the result? (y/n)\n','s');
        if strcmp(keep,'y')
            break
        elseif strcmp(keep,'n')
            threshold = input('enter new threshold \n');
            close all
            disp('recalculating')
            weka_file = FileHandler.get_file(tif_files,file_name);
            process_weka(weka_file,weka_root,threshold)
            Plotter.show_flow_speed_around_stimulation_weka(mat_path,tif_path,weka_mat_path)
        end
    end
end
% end
