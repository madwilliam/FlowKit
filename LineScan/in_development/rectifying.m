mat = load('/net/dk-server/bholloway/Zhongkai/FoG/Pack-050522-NoCut_05-17-22_Vessel-2_CBF_00001_roi_1.mat');
%%
jumps = diff(mat.result.slopes);
jumps(isnan(jumps))=0;
mean_jump = mean(jumps(~isinf(jumps)));
std_jump = std(jumps(~isinf(jumps)));
big_jumps = arrayfun(@(x) x>mean_jump+std_jump || x<mean_jump-std_jump,jumps);
rectified_slopes = mat.result.slopes;
[start_time,end_time] = find_event_start_and_end_time(big_jumps);

for i = 1:numel(start_time)
    starti = start_time(i);
    endi = end_time(i);
    if starti <2
        rectified_slopes(1:endi)=nan;
        continue
    elseif endi> numel(mat.result.slopes)-2
        rectified_slopes(starti:end)=nan;
        continue
    end
rectified_slopes(starti-1:endi+1) = nan;
end
%%
rectified_slopes = rectify_signal(mat.result.slopes,3);
% double_rectified_slopes = rectify_signal(rectified_slopes,2);
plot(mat.result.slopes)
plot(rectified_slopes)
plot(double_rectified_slopes)

plot(rectified_slopes(8450:8460))
plot(mat.result.slopes(8450:8460))

