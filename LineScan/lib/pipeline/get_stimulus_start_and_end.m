function [start_time,end_time] = get_stimulus_start_and_end(image,channels,total_pixels,pmt_path)
    if channels(end) == 4
        stimulus_channel = find(channels==4);
        stimulus = FileHandler.load_pmt_file(pmt_path,total_pixels,numel(channels),stimulus_channel);
        [start_time,end_time] = find_event_start_and_end_time(stimulus(1,:) > 800);
    else
        space_average = mean( image,1 );
        [start_time,end_time] = find_event_start_and_end_time(space_average>2000);
        valid_time = (start_time(2:end)-end_time(1:end-1))>100;
        start_time = start_time([1 valid_time]);
        end_time = end_time(valid_time);
    end
end
