mat_path = "C:\Users\Montana\Documents\Server_Data and Analysis\AutorunOutput\";
mat_struct = dir( strcat( mat_path, '/**/*.mat' ) );
lout = []
for i=1:numel( mat_struct )
    
    mat = load( (append( mat_path, '\', mat_struct(i).name) ) );
    numStims = numel( mat.start_time );  
    
    for m=1:numStims %for each stimulation:
        
        %get stimulation durations in ms
        stim_dur_ms = mat.dt_ms * ( mat.end_time(m) - mat.start_time(m) );
        if stim_dur_ms > 0 && stim_dur_ms < 1
            stim_dur_ms = 0.1;
        elseif stim_dur_ms > .9 && stim_dur_ms < 1.25
            stim_dur_ms = 1;
        elseif stim_dur_ms > 9 && stim_dur_ms < 12.5
            stim_dur_ms = 10;
        elseif stim_dur_ms > 90 && stim_dur_ms < 125
            stim_dur_ms = 100;
        elseif stim_dur_ms > 900 && stim_dur_ms < 1250
            stim_dur_ms = 1000;
        else
            disp("non-ten base stim");
        end
        
        %get RBCv for xSec before and after ***need to scale start/end_time and xSec to 'speed' time       
        analFrame_sec = 10; analFrame_speed = analFrame_sec / mat.time_per_velocity_data_s; offset_sec = 0.5; offset = offset_sec/ mat.time_per_velocity_data_s;
        stim_start_speedIndex = mat.start_time(m) * mat.dt_ms / 1000 / mat.time_per_velocity_data_s;
        stim_end_speedIndex = mat.end_time(m) * mat.dt_ms/ 1000 / mat.time_per_velocity_data_s;
        
        analPrior = ( stim_start_speedIndex - analFrame_speed - offset ); 
        if analPrior < 1
            analPrior = 1;
        end
        
        speed_prior = mat.speed( analPrior : stim_start_speedIndex - offset );
        
        analPost = stim_end_speedIndex + offset + analFrame_speed;
        if analPost > numel( mat.speed )
            analPost = numel( mat.speed - 1);
        end
        
        speed_post = mat.speed( (stim_end_speedIndex + offset ) : ( analPost ) );
        
        speed_prior_mean = mean( speed_prior( isfinite( speed_prior ) ) );
        speed_post_mean = mean( speed_post( isfinite( speed_post ) ) );
        mT = num2str( m );
        newName = append( {mat_struct(i).name}, " stim_", mT );
        
        lout = [ lout; newName, stim_dur_ms, speed_prior_mean, speed_post_mean, speed_post_mean / speed_prior_mean ];
    end
    
end
