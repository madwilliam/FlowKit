function [start_time,end_time] = find_event_start_and_end_time(input)
    if sum(input)==0
        start_time = [];
        end_time = [];
    else
        start_time= find(diff(input) == 1);
        start_time = start_time+1;
        end_time = find(diff(input) == -1);
        if numel(start_time)==numel(end_time)+1
            end_time = [end_time numel(input)];
        end
        if numel(start_time)==numel(end_time)-1
            start_time = [start_time 1];
        end
        if start_time(1)>end_time(1)
            if size(start_time,2)==1
               start_time = start_time';
            end
            start_time = [1 start_time];
        end
        if end_time(end)<start_time(end)
            if size(end_time,2)==1
                end_time = end_time';
            end
            end_time = [end_time length(input)];
        end
        assert(length(start_time)==length(end_time))
    end