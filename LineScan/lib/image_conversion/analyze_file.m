function analyze_file(save_path,pmt_file,meta_file,namei)
    if contains(pmt_file.folder,'CBF')
        animal_name = get_animal_name(pmt_file.folder,'/CBF/');
%     elseif contains(pmt_file.folder,'Other Data/Otros')
%         if contains(pmt_file.folder,'Wild Type Mice')
%             animal_name = get_animal_name(pmt_file.folder,'/Wild Type Mice/');
%         else 
%             animal_name = get_animal_name(pmt_file.folder,'/Otros/');
%         end
%     elseif contains(pmt_file.folder,'Unsorted')
%         animal_name = get_animal_name(pmt_file.folder,'/Unsorted/');
%     else
%         return
    end
    output_dir = fullfile(save_path,animal_name);
    pmt_path = fullfile(pmt_file.folder,pmt_file.name);
    meta_path = fullfile(meta_file.folder,meta_file.name);
    if ~exist(output_dir)
        mkdir(output_dir)
    end
    crop_tiff(namei,pmt_path,meta_path, output_dir)
end

function animal_name = get_animal_name(folder,divider)
    result = split(folder,divider);
    result = result{2};
    result = split(result,filesep);
    animal_name = result{1};
end