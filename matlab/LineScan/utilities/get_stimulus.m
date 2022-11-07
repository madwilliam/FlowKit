function [start_time,end_time] = get_stimulus(image,channels,pmt_path)
    if channels(end) == 4
        stimulus_channel = find(channels==4);
        stimulus = FileHandler.load_pmt_file(pmt_path,numel(channels),stimulus_channel);
        [start_time,end_time] = find_event_start_and_end_time(stimulus > 800);
    else
        space_average = mean( image,1 );
        [start_time,end_time] = find_event_start_and_end_time(space_average == intmax(class(image)));
    end
end