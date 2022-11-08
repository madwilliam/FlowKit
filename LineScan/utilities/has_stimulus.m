function has_stimulus(channels,pmt_files,file_name,nsample,n_data)
    sample_per_data = nsample/n_data;
    if channels(end) == 4
        stimulus = FileHandler.load_stimulus(pmt_files,file_name);
    else
        space_average = mean( image,1 );
        [ ~, stimulation_start ] = max( space_average );
        n_max_index = sum( (space_average == intmax(class(image)) ) );
        if n_max_index ~= 0
            [start_time,end_time] = find_event_start_and_end_time(space_average == intmax(class(image)));
            id = find(start_time==stimulation_start);
            stimulation_end = end_time(id);
            stimulus = zeros(1 , n_data);
            stimulation_start = floor(stimulation_start/sample_per_data);
            stimulation_end = floor(stimulation_end/sample_per_data);
            stimulus(stimulation_start:stimulation_end)=1;
        else
            stimulus = NaN;
        end
    end
end