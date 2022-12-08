function all_results = get_all_results(mat_root,weka_root,save_root,window_size_seconds,offset_seconds)
    group_name = split(weka_root,'/');
    if strcmp(group_name(end),'')
        group_name = group_name(end-1);
    else
        group_name = group_name(end);
    end
    save_path = fullfile(save_root,append(strjoin([group_name,'windowsize',num2str(window_size_seconds),'offset',num2str(offset_seconds)],'_'),'.mat'));
    if exist(save_path)
        all_results = load(save_path,'all_results').all_results;
    else
        all_results = WekaPlotter.parse_result_by_stimulation(weka_root,mat_root,offset_seconds,window_size_seconds);
        save(save_path,'all_results')
    end
end