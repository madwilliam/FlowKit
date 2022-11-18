control_path = '/net/dk-server/bholloway/Zhongkai/group_results/controls_mask_windowsize_10_offset_0.mat';
fog_path = '/net/dk-server/bholloway/Zhongkai/group_results/fog_new_mask_windowsize_10_offset_0.mat';
unprocessed_path = '/net/dk-server/bholloway/Zhongkai/group_results/matlab_filtered_unprocessed_new_mask_windowsize_10_offset_0.mat';

control = load(control_path,'all_results').all_results;
fog = load(fog_path,'all_results').all_results;
unprocessed = load(unprocessed_path,'all_results').all_results;


all = [control fog];

all_file_info = WekaPlotter.organize_file_information(all);
animal_id = {all_file_info.animal_id};
is_control = cellfun(@(animal_id) contains(animal_id,'NVC') ,animal_id);
control = all(is_control);
control_info = all_file_info(is_control);
experimental = all(~is_control);
exp_info = all_file_info(~is_control);


pre_mean_control = [control.mean_pre_stim];
post_mean_control = [control.mean_post_stim];
delta_control = post_mean_control-pre_mean_control;

pre_mean_experimental = [experimental.mean_pre_stim];
post_mean_experimental = [experimental.mean_post_stim];
delta_experimental = post_mean_experimental-pre_mean_experimental;
%%
figure
hold on 
bins = linspace(-0.7,0.8,30);
histogram(delta_control,bins)
histogram(delta_experimental,bins)
hold off
legend('control','experimental')
%%
[h,p] = ttest2(delta_control,delta_experimental);
figure
data = [delta_control,delta_experimental];
group = [ones(1,numel(delta_control)),ones(1,numel(delta_experimental))*2];
boxplot(data,group,'labels',{'control','experimental'})
yt = get(gca, 'YTick');
axis([xlim    0  ceil(max(yt))])
xt = get(gca, 'XTick');
hold on
pair = [1,2];
height = max(yt)*0.8;
plot(pair, [1 1]*height, '-k', mean(pair) , height+0.01, '*k')
hold off
%%
figure
[pre_stims,post_stims,info] = WekaPlotter.get_trail_data(control_info,control,'mean_pre_stim','mean_post_stim');
WekaPlotter.plot_group_box_plot(pre_stims,post_stims,info);
title('mean')

figure
[pre_stims,post_stims,info] = WekaPlotter.get_trail_data(exp_info,experimental,'mean_pre_stim','mean_post_stim');
WekaPlotter.plot_group_box_plot(pre_stims,post_stims,info);
title('mean')
%%
% all_exp = [unprocessed fog];
all_exp = fog;
all_info = WekaPlotter.organize_file_information(all_exp);
WekaPlotter.print_stimulation_counts(all_exp)
deltas = {};
stimulations = unique([all_results.duration_ms]);
for stimulationi = stimulations
    [stimi_result,stimulationi_info] = WekaAnnalyzer.get_result_of_stimulationi(all_exp,stimulationi);
    pre_mean = [stimi_result.mean_pre_stim];
    post_mean = [stimi_result.mean_post_stim];
    delta = post_mean-pre_mean;
    deltas{end+1} = delta; 
end
%%
figure
hold on 
bins = linspace(-0.7,0.8,30);
for data = deltas
    histogram(data{1},bins)
end
hold off
legend(arrayfun(@num2str,stimulations,'UniformOutput',false))
%%
figure
data = [delta_control];
group = [ones(1,numel(delta_control))];
i = 2;
for delta = deltas
    delta = delta{1};
    data = [data,delta];
    group = [group,ones(1,numel(delta))*i];
    i = i+1;
end
boxplot(data,group,'labels',['control' arrayfun(@num2str,stimulations,'UniformOutput',false)])
%%
disp('control')
for delta = deltas
    delta = delta{1};
    [h,p] = ttest2(delta_control,delta);
    disp(p)
end
for i =1:4
    disp(i)
    for delta = deltas
        delta = delta{1};
        [h,p] = ttest2(deltas{i},delta);
        disp(p)
    end
end
%%
yt = get(gca, 'YTick');
axis([xlim    0  ceil(max(yt))])
xt = get(gca, 'XTick');
hold on
pair = [1,3];
height = max(yt)*0.5;
plot(pair, [1 1]*height, '-k', mean(pair) , height+0.01, '*k')
pair = [1,4];
height = max(yt)*0.6;
plot(pair, [1 1]*height, '-k', mean(pair) , height+0.01, '*k',mean(pair)-0.1 , height+0.01, '*k',mean(pair)+0.1 , height+0.01, '*k')
pair = [1,5];
height = max(yt)*0.7;
plot(pair, [1 1]*height, '-k', mean(pair) , height+0.01, '*k')
hold off
title('Delta Speed of Control VS Different Stimulation duration (ms)')
%%
WekaPlotter.print_stimulation_counts(all_results)
%%
yt = get(gca, 'YTick');
axis([xlim    0  ceil(max(yt))])
xt = get(gca, 'XTick');
hold on
pair = [1,2];
height = max(yt)*0.8;
plot(pair, [1 1]*height, '-k', mean(pair) , height+0.01, '*k')
hold off
