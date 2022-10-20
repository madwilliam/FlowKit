mat_root = "/net/dk-server/bholloway/Zhongkai/FoG";
weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
weka_mat_files = FileHandler.get_mat_files(weka_root);
mat_files = FileHandler.get_mat_files(mat_root);
all_results = WekaPlotter.parse_result_by_stimulation(weka_root,mat_root);
WekaPlotter.print_stimulation_counts(all_results)
stimulationi = 100;
is_stimulationi = [all_results.duration_ms]==stimulationi;
stimi_result = all_results(is_stimulationi);
%%
WekaPlotter.plot_mean_speed_before_and_after(stimi_result)
WekaPlotter.plot_filtered_trace_separately(stimi_result,stimulationi)
WekaPlotter.plot_all_filtered_traces_standardize_direction(stimi_result)
WekaPlotter.plot_uncentered_filtered_traces(stimi_result)
WekaPlotter.plot_average_filtered_response(stimi_result)

%%
all_file_info = WekaPlotter.organize_file_information(stimi_result);
WekaPlotter.print_animal_and_vessel_counts(all_file_info)
WekaPlotter.plot_all_trace_plus_average_grouped_by_vessel(all_file_info,stimi_result)