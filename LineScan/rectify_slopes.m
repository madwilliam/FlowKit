mat_root = "/net/dk-server/bholloway/Zhongkai/fog_divgauss";
mat_files = FileHandler.get_mat_files(mat_root);
for filei = 1:numel(mat_files)
    file = mat_files(filei);
    result = load(fullfile(file.folder,file.name),'result').result;
    rectified_slopes = rectify_signal(result.slopes,1);
    result.slopes = rectify_signal(rectified_slopes,1);
    save(fullfile(file.folder,file.name),'result','-append')
end