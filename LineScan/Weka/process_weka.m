function process_weka(weka_file,weka_root,threshold)
    if ~exist('threshold','var')
        threshold = 2;
    end
    try
        weka_path = fullfile(weka_root,weka_file.name);
        file_name = FileHandler.strip_extensions(weka_file.name);
        mat_path = fullfile(weka_root,append(file_name,'.mat'));
        image = FileHandler.load_image_data(weka_path);
        stripe_statistics = WekaAnalyzer.find_stripes(image,threshold);
        save(mat_path,'stripe_statistics')
    catch
        disp(weka_file.name)
    end
end