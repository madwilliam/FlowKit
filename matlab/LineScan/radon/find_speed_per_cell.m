function [location_per_stripe,slopes_per_stripe,time_per_stripe] = find_speed_per_cell(radon_result)
    threshold = 30;
    inter_stripe_interval = diff(radon_result.locations);
    [start_time,end_time] = find_event_start_and_end_time(inter_stripe_interval<threshold);
    nstripes = numel(start_time);
    location_per_stripe = zeros(1,nstripes);
    slopes_per_stripe = zeros(1,nstripes);
    time_per_stripe = zeros(1,nstripes);
    for i=1:nstripes
        starti = start_time(i);
        endi = end_time(i);
        location_per_stripe(i) = mean(radon_result.locations(starti:endi));    
        slopes_per_stripe(i) = mean(radon_result.slopes(starti:endi));
        time_per_stripe(i) = mean(radon_result.time(starti:endi));
    end
end