function [data,downsample_factor] = preprocess_data(data,windowsize)
    [data,downsample_factor] = down_sample_pixels(data,windowsize);
    data = data-mean(data,'all');
    mean_data = mean(data,2);
    mean_data = repmat(mean_data,1,size(data,2));
    mean_data = cast(mean_data,class(data));
    data = data-mean_data;
end

function [data,downsample_factor] = down_sample_pixels(data,windowsize)
    npixel=size(data,1);
    size_factor = npixel/windowsize;
    if size_factor> 1.5
        downsample_factor = ceil(size_factor);
        data = data(1:downsample_factor:end,:);
    else
        downsample_factor=1;
    end
end

function data = fancy_processing(data)%,ax4,ax5)
    data = imgaussfilt(data,5);
    [f,xi] = ksdensity(double(reshape(data,[],1))); 
    [~,peak_location,~,peak_prominance] = findpeaks(f);
    if numel(peak_prominance)>=2
        [~,pid] = sort(peak_prominance);
        top_peaks = sort(peak_location(pid(end-1:end)));
        [~,through_location,~,~] = findpeaks(-f);
        location = [];
        for loci = through_location
            if loci>top_peaks(1)&&loci<top_peaks(2)
                location = [location loci];
            end
        end
        through_location = location;
        [~,through_id] = min(abs(through_location-top_peaks(2)));
        threshold = xi(through_location(through_id));
    else
        threshold = xi(peak_location(1));
    end
    data = data>threshold;
end