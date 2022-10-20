weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
tif_files = FileHandler.get_tif_files(mat_root);
mat_files = FileHandler.get_mat_files(mat_root);
weka_mat_files = FileHandler.get_mat_files(weka_root);
weka_tifs = FileHandler.get_tif_files(weka_root);
%%
weka_width_and_height = cell(1,nweka);
for wi = 1:nweka
    weka_path = fullfile(weka_tifs(wi).folder,weka_tifs(wi).name);
    info = imfinfo(weka_path);
    weka_width_and_height{wi} = [info.Height,info.Width];
end

tif_width_and_height = cell(1,ntif);
for ti = 1:ntif
    tif_path = fullfile(tif_files(ti).folder,tif_files(ti).name);
    info = imfinfo(tif_path);
    tif_width_and_height{ti} = [info.Height,info.Width];
end
%%
nweka = numel(weka_tifs);
ntif = numel(tif_files);
pairs = [];
for wi = 1:nweka
    weka_size = weka_width_and_height{wi};
    for ti = 1:ntif
        tif_size = tif_width_and_height{ti};
        if isequal(weka_size,tif_size)
            pairs = [pairs [wi,ti]'];
        end
    end
end

mis_match = find(pairs(1,:)~=pairs(2,:));
%%
for i = 1:numel(mis_match)
    mis_id = pairs(:,mis_match(i));
    disp(['mismatch ' num2str(i) ' id weka ' num2str(num2str(mis_id(1))) ' id tif ' num2str(num2str(mis_id(2))) ])
    wi = mis_id(1);
    ti = mis_id(2);
%     weka_path = fullfile(weka_tifs(wi).folder,weka_tifs(wi).name);
%     new_weka_path = fullfile(weka_tifs(wi).folder,tif_files(ti).name);
%     tif_path = fullfile(tif_files(ti).folder,tif_files(ti).name);
    disp(weka_tifs(wi).name)
    disp(tif_files(ti).name)
%     movefile()
end

