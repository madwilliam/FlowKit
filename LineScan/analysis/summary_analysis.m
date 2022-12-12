mat_root = "/net/dk-server/bholloway/Zhongkai/FoG";
weka_root = '/net/dk-server/bholloway/Zhongkai/fog_new_mask/';
save_root = '/net/dk-server/bholloway/Zhongkai/group_results/';
window_size_seconds = 10;
offset_seconds = 0;
all_results = get_all_results(mat_root,weka_root,save_root,window_size_seconds,offset_seconds);
power_variation = cellfun(@(x) contains(x,'Pack-081621_10-27-21')|contains(x,'Pack-071022_08-19-22'),{all_results.file_name});
all_results = all_results(~power_variation);
%%
mat_root = "/net/dk-server/bholloway/Zhongkai/Pack-100322 Tifs and Mats new radon";
save_root = '/net/dk-server/bholloway/Zhongkai/group_results/';
all_results = WekaPlotter.parse_result_by_stimulation_radon(mat_root,offset_seconds,window_size_seconds);
%%
WekaPlotter.print_stimulation_counts(all_results)
stimulationi = 100;
[stimi_result,all_file_info] = WekaAnnalyzer.get_result_of_stimulationi(all_results,stimulationi);
%%
WekaPlotter.plot_all_trace_plus_average_grouped_by_vessel(all_file_info,stimi_result)

%%
WekaPlotter.plot_mean_speed_before_and_after(stimi_result)
WekaPlotter.plot_filtered_trace_separately(stimi_result,window_size_seconds)
WekaPlotter.plot_unfiltered_trace_separately(stimi_result,window_size_seconds)
WekaPlotter.plot_all_filtered_traces_standardize_direction(stimi_result)
WekaPlotter.plot_uncentered_filtered_traces(stimi_result)
WekaPlotter.plot_average_filtered_response(stimi_result)

%%
WekaPlotter.print_animal_and_vessel_counts(all_file_info)
WekaPlotter.plot_histogram_grouped_by_vessel(all_file_info,stimi_result)
mean_result = WekaPlotter.print_nomality_test(all_file_info,stimi_result,'mean_pre_stim','mean_post_stim');
auc_result = WekaPlotter.print_nomality_test(all_file_info,stimi_result,'area_under_the_curve_pre_stim','area_under_the_curve_post_stim');
peak_result = WekaPlotter.print_nomality_test(all_file_info,stimi_result,'peak_pre_stim','peak_post_stim');
mean_comparison_result = WekaPlotter.print_comparison_test(all_file_info,stimi_result,'mean_pre_stim','mean_post_stim');
auc_comparison_result = WekaPlotter.print_comparison_test(all_file_info,stimi_result,'area_under_the_curve_pre_stim','area_under_the_curve_post_stim');
peal_comparison_result = WekaPlotter.print_comparison_test(all_file_info,stimi_result,'peak_pre_stim','peak_post_stim');

%%
figure
[pre_stims,post_stims,info] = WekaPlotter.get_trail_data(all_file_info,stimi_result,'mean_pre_stim','mean_post_stim');
WekaPlotter.plot_group_box_plot(pre_stims,post_stims,info);
title('mean')

figure
[pre_stims,post_stims,info] = WekaPlotter.get_trail_data(all_file_info,stimi_result,'area_under_the_curve_pre_stim','area_under_the_curve_post_stim');
WekaPlotter.plot_group_box_plot(pre_stims,post_stims,info);
title('area under the curve')

figure
[pre_stims,post_stims,info] = WekaPlotter.get_trail_data(all_file_info,stimi_result,'peak_pre_stim','peak_post_stim');
WekaPlotter.plot_group_box_plot(pre_stims,post_stims,info);
title('peak value')

%%
animals = {all_file_info.animal_id};
is050522 = cellfun(@(x) strcmp(x,'Pack-050522'),animals);
Pack_050522 = stimi_result(is050522);
figure
WekaPlotter.plot_rbc_histogram(Pack_050522,'Pack-050522','',40)

[p,tbl,stats] = WekaAnnalyzer.population_annova_per_trace(all_results);
%%
all_delta = WekaAnnalyzer.get_mean_delta_per_vessel(all_results);
[p,tbl,stats] = WekaAnnalyzer.uneven_annova(all_delta);
%%
all_file_info = WekaPlotter.organize_file_information(all_results);
is_animal = arrayfun(@(x)strcmp(x.animal_id,'Pack-050522'),all_file_info);
animal_result = all_results(is_animal);
animal_file_info = WekaPlotter.organize_file_information(animal_result);
vessels = unique({animal_file_info.vessel_id});
for vesseli = vessels
    is_vesseli = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file_info);
    vessel_result = all_results(is_vesseli);
    vessel_file_info = WekaPlotter.organize_file_information(vessel_result);
    grouped_result = WekaAnnalyzer.group_delta_by_stimulation(vessel_result);
    [p,tbl,stats] = WekaAnnalyzer.uneven_annova(grouped_result);
    title(vesseli)
end
%%
all_file_info = WekaPlotter.organize_file_information(all_results);
is_animal = arrayfun(@(x)strcmp(x.animal_id,'Pack-050522'),all_file_info);
animal_result = all_results(is_animal);
animal_file_info = WekaPlotter.organize_file_information(animal_result);
vessels = unique({animal_file_info.vessel_id});
for vesseli = vessels
    is_vesseli = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file_info);
    vessel_result = all_results(is_vesseli);
    durations = unique([vessel_result.duration_ms]);
    disp(vesseli)
    disp(durations)
end
%%
grouped_result = WekaAnnalyzer.group_results_by_stimulation(vessel_result);
