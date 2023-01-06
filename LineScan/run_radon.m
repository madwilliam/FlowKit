directory = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
% save_path = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
mat_files = FileHandler.get_mat_files(directory);
tif_files = FileHandler.get_tif_files(directory);
meta_files = FileHandler.get_meta_files(directory);

mat_names = {mat_files.name};
mat_names = cellfun(@FileHandler.strip_extensions,mat_names,'UniformOutput',false);
mat_names = cellfun(@(x) x(1:end-5),mat_names,'UniformOutput',false);


meta_names = {meta_files.name};
meta_names = cellfun(@FileHandler.strip_extensions,meta_names,'UniformOutput',false);

pmt_names = {pmt_files.name};
pmt_names = cellfun(@FileHandler.strip_extensions,pmt_names,'UniformOutput',false);

common_names = intersect( mat_names,pmt_names);
common_names = intersect( common_names,meta_names);