directory = '/net/dk-server/bholloway/Data and Analysis/Data/Two Photon Directory/CBF';
save_path = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
mat_files = FileHandler.get_mat_files(directory);
pmt_files = FileHandler.get_pmt_files(directory);
meta_files = FileHandler.get_meta_files(directory);
mat_names = {mat_files.name};
mat_names = cellfun(@FileHandler.strip_extensions,mat_names,'UniformOutput',false);
mat_names = cellfun(@(x) x(1:end-5),mat_names,'UniformOutput',false);
pmt_names = {pmt_files.name};
meta_names = {meta_files.name};
meta_names = cellfun(@FileHandler.strip_extensions,meta_names,'UniformOutput',false);
pmt_names = cellfun(@FileHandler.strip_extensions,pmt_names,'UniformOutput',false);
%%
common_names = intersect( mat_names,pmt_names);
common_names = intersect( common_names,meta_names);
process_names = common_names;
%%
processed_mats = FileHandler.get_mat_files(save_path);
processed_names = {processed_mats.name};
processed_names = cellfun(@FileHandler.strip_extensions,processed_names,'UniformOutput',false);
processed_names = cellfun(@(x) split(x,'_roi_'),processed_names,'UniformOutput',false);
processed_names = cellfun(@(x) x{1},processed_names,'UniformOutput',false);
process_names = setdiff(process_names,processed_names);
%%
no_stimulus = read_text(fullfile('/net/dk-server/bholloway/Data and Analysis/no_stimulus.txt'));
no_stimulus = split(no_stimulus,'======================================');
no_stimulus = no_stimulus(2:end);
no_stimulus = cellfun(@(x) x(2:end-1),no_stimulus,'UniformOutput',false)';
process_names = setdiff(process_names,no_stimulus);

