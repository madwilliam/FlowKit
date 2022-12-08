directory = '/data/test_ben/';
mat_files = FileHandler.get_mat_files(directory);
pmt_files = FileHandler.get_pmt_files(directory);
mat_names = {mat_files.name};
mat_names = cellfun(@FileHandler.strip_extensions,mat_names,'UniformOutput',false);
mat_names = cellfun(@(x) x(1:end-5),mat_names,'UniformOutput',false);
pmt_names = {pmt_files.name};
pmt_names = cellfun(@FileHandler.strip_extensions,pmt_names,'UniformOutput',false);
common_names = intersect( mat_names,pmt_names);
for namei = common_names
    target = cellfun(@(x) contains(x,namei),pmt_names);
    pmt_file = pmt_files(target);
    target = cellfun(@(x) contains(x,namei),mat_names);
    mat_file = mat_files(target);
    assert(strcmp(pmt_file.folder,mat_file.folder))
    assert(numel(pmt_file)==1)
    assert(numel(mat_file)==1)
    folder_path = pmt_file.folder;
    [~,name,~]=fileparts(folder_path);
    line_scan_folder = fullfile(folder_path,[name '_Line_Scan']);
    if ~exist(line_scan_folder)
        mkdir(line_scan_folder)
    end
    associated_Files = dir(fullfile(folder_path,append("*",namei,"*")));
    for i = 1:numel(associated_Files)
        file = associated_Files(i);
        file_path = fullfile(file.folder,file.name);
        destination = fullfile(file.folder,[name '_Line_Scan']);
        movefile(file_path,destination)
    end
end
