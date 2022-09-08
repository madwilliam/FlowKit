function [start_time,end_time] = find_event_start_and_end_time(input)
    [~, start_time] = find(diff(input, [], 2) == 1);
    start_time = start_time+1;
    [~, end_time] = find(diff(input, [], 2) == -1);
    if start_time(1)>end_time(1)
        start_time = [1 start_time];
    end
    if end_time(end)<start_time(end)
        end_time = [end_time length(input)];
    end
    assert(length(start_time)==length(end_time))