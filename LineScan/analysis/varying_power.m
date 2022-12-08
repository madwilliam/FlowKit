mat_root = "/net/dk-server/bholloway/Zhongkai/FoG";
weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
weka_mat_files = FileHandler.get_mat_files(weka_root);
mat_files = FileHandler.get_mat_files(mat_root);
window_size_seconds = 4;
offset_seconds = 1;
all_results = WekaPlotter.parse_result_by_stimulation(weka_root,mat_root,offset_seconds,window_size_seconds);

is_power = cellfun(@(x)contains(x,'mW'),{all_results.file_name});
power_results = all_results(is_power);
power_file_info = WekaPlotter.organize_file_information(power_results);
all_powers = [power_file_info.power_mw];
powers = unique(all_powers);
%%
figure
ploti = 1;
for poweri = powers
    ispoweri = all_powers==poweri;
    poweri_results = power_results(ispoweri);
    subplot(2,2,ploti)
    hold on
    for tracei = 1:numel(poweri_results)
        resulti = poweri_results(tracei);
        time = resulti.time_standard-min(resulti.time_standard);
        speed = (resulti.speed_standard - resulti.mean_pre_stim*resulti.sign_change)*resulti.sign_change;
        plot(time,speed,'k')
    end
    hold off
    ploti = ploti+1;
end
%%
WekaPlotter.plot_filtered_trace_separately(power_results,window_size_seconds)
