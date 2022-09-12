function [location_per_stripe,slopes_per_stripe,time_per_stripe] = find_speed_per_cell(locations,raw_slopes,time)
    threshold = 30;
    inter_stripe_interval = diff(locations);
    [start_time,end_time] = find_event_start_and_end_time(inter_stripe_interval<30);
    nstripes = numel(start_time);
    location_per_stripe = zeros(1,nstripes);
    slopes_per_stripe = zeros(1,nstripes);
    time_per_stripe = zeros(1,nstripes);
    for i=1:nstripes
        starti = start_time(i);
        endi = end_time(i);
        location_per_stripe(i) = mean(locations(starti:endi));    
        slopes_per_stripe(i) = mean(raw_slopes(starti:endi));
        time_per_stripe(i) = mean(time(starti:endi));
    end
end