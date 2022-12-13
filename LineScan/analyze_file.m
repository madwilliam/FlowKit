function analyze_file(pmt_file,meta_file,namei)
    save_path = '/net/dk-server/bholloway/Data and Analysis/Analysis/Two Photon Analysis/TIFs_and_MATs';
    result = split(pmt_file.folder,'/CBF/');
    result = result{2};
    result = split(result,filesep);
    animal_name = result{1};
    output_dir = fullfile(save_path,animal_name);
    pmt_path = fullfile(pmt_file.folder,pmt_file.name);
    meta_path = fullfile(meta_file.folder,meta_file.name);
    crop_tiff(namei,pmt_path,meta_path, output_dir)
end