function move_file(pmt_file,mat_file,namei)
        assert(numel(pmt_file)==1);
        assert(numel(mat_file)==1);
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