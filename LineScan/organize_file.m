directory = '/net/dk-server/bholloway/Data and Analysis/';
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
common_names = intersect( mat_names,pmt_names);
common_names = intersect( common_names,meta_names);
%%
for namei = common_names
     try
        target_pmt = cellfun(@(x) contains(x,namei),pmt_names);
        target_mat = cellfun(@(x) contains(x,namei),mat_names);
        if sum(target_pmt)>1 && sum(target_mat)>1
            for i = find(target_pmt)
                pmt_file = pmt_files(i);
                mat_file_id = cellfun(@(x) strcmp(pmt_file.folder,x),{mat_file.folder});
                mat_file = mat_files(target_mat);
                mat_file = mat_file(mat_file_id);
                if isempty(mat_file)
                    continue
                end
                move_file(pmt_file,mat_file,namei)
            end
        elseif sum(target_pmt)==1 && sum(target_mat)>1
            pmt_file = pmt_files(target_pmt);
            mat_file_id = cellfun(@(x) strcmp(pmt_file.folder,x),{mat_file.folder});
            mat_file = mat_files(target_mat);
            mat_file = mat_file(mat_file_id);
            if isempty(mat_file)
                continue
            end
            move_file(pmt_file,mat_file,namei)
        elseif sum(target_pmt)>1 && sum(target_mat)==1
            for i = find(target_pmt)
                pmt_file = pmt_files(i);
                mat_file_id = cellfun(@(x) strcmp(pmt_file.folder,x),{mat_file.folder});
                mat_file = mat_files(target_mat);
                mat_file = mat_file(mat_file_id);
                if isempty(mat_file)
                    continue
                end
                move_file(pmt_file,mat_file,namei)
            end
        else
            pmt_file = pmt_files(target_pmt);
            mat_file = mat_files(target_mat);
            if ~strcmp(pmt_file.folder,mat_file.folder)
                continue
            end
            
            move_file(pmt_file,mat_file,namei);
        end
    catch ME
        log_error(namei{1},ME,directory);
    end
end
