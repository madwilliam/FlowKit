mat_root = "/net/dk-server/bholloway/Zhongkai/FoG";
weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
weka_mat_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_tif_files(mat_root);

weka_names = {weka_mat_files.name};
mat_names = {mat_files.name};

unprocessed = {};
unprocessed_root = '/net/dk-server/bholloway/Zhongkai/unprocessed/';
for name = mat_names
    if ~any(cellfun(@(x) strcmp(x,name),weka_names))
        disp(name)
        unprocessed{end+1} = name{1};
        copyfile(fullfile(mat_root,name{1}),fullfile(unprocessed_root,name{1}))
    end
end

