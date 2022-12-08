function rectified_signal = rectify_signal(signal,nstd)
    jumps = diff(signal);
    jumps(isnan(jumps))=0;
    mean_jump = mean(jumps(~isinf(jumps)));
    std_jump = std(jumps(~isinf(jumps)));
    big_jumps = arrayfun(@(x) x>mean_jump+nstd*std_jump || x<mean_jump-nstd*std_jump,jumps);
    rectified_signal = signal;
    [start_time,end_time] = find_event_start_and_end_time(big_jumps);
    for i = 1:numel(start_time)
        starti = start_time(i);
        endi = end_time(i);
        if starti <2
            rectified_signal(1:endi)=nan;
            continue
        elseif endi> numel(signal)-2
            rectified_signal(starti:end)=nan;
            continue
        end
    rectified_signal(starti-1:endi+1) = nan;
    end
end