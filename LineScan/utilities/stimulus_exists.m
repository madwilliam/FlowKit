function has_stimulus = stimulus_exists(image,channels,pmt_files,file_name)
    if channels(end) == 4
        stimulus = FileHandler.load_stimulus(pmt_files,file_name);
        stimulus=int16(stimulus);
        has_stimulus=true;
        if max(stimulus)-min(stimulus) < 500
            has_stimulus=false;
        end
    else
        space_average = mean( image,1 );
        n_max_index = sum( (space_average == intmax(class(image)) ) );
        if n_max_index ~= 0
            has_stimulus=true;
        else
            has_stimulus=false;
        end
    end
end
