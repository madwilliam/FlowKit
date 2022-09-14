function stimulus = get_stimulus(channels,pmt_files,file_name,nsample,n_data)
    sample_per_data = nsample/n_data;
    if channels(end) == 4
        pmt_file = FileHandler.get_file(pmt_files,file_name);
        fid=fopen([pmt_file.folder '\' pmt_file.name],'r');
        M=fread(fid,'int16=>int16');
        M=M(2:2:end);
        M=int16(M);
        n = numel(M)/n_data;
        stimulus = M(1 : floor(n) : end);
        stimulus=int16(stimulus(1:n_data));
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