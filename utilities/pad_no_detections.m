function theta = pad_no_detections(theta)
    input = (theta>0)';
    [start_time,end_time] = find_event_start_and_end_time(input);
    n_segments = length(start_time);
    for segmenti = 1:n_segments
        starti = start_time(segmenti);
        endi = end_time(segmenti);
        if endi==length(theta)
            continue
        end
        value_before = theta(starti-1);
        value_after = theta(endi+1);
        if endi ==starti
            theta(starti)=value_before;
        else
            pad_value = linspace(value_before,value_after,endi-starti+1);
            theta(starti:endi) = pad_value;
        end
    end
end