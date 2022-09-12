
function [velocity,data,LSPIVresult,badsamples] = LSPIV(data,maxGaussWidth,maxstd,nsample_per_second,window_size,step_size,fft_time_shift)
    if size(data,1)<size(data,2)
        data = data';
    end
    if nargin < 2
        maxGaussWidth = 100;
    end
    if nargin < 3
        maxstd= 3; 
    end
    if nargin < 4
        nsample_per_second= 2600;
    end
    if nargin<5
        window_size= 100;  
    end
    if nargin < 6
        step_size       = 25;  
    end
    if nargin < 7
        fft_time_shift= 5;
    end
    temporal_mean = sum(data,1) / size(data,1);
    data = data - repmat(temporal_mean,size(data,1),1);
    disp('LSPIV begin');
    LSPIVresult = weightedFFT(data,fft_time_shift);
    disp('LSPIV complete');
    [velocity,~,~,~] = get_velocity(LSPIVresult,step_size,window_size,maxGaussWidth,fft_time_shift);
    disp('Find the peaks');
    [badsamples] = evaluate_goodness_of_fit(velocity,nsample_per_second,step_size,maxstd);
end

function LSPIVresult = weightedFFT(data,fft_time_shift)
    transformed_data  = fft(data(1:end-fft_time_shift,:),[],2);
    shifted_fft   = fft(data(fft_time_shift+1:end, 1:end),[],2);
    W      = 1./sqrt(abs(transformed_data)) ./ sqrt(abs(shifted_fft)); % phase only
    LSPIVresultFFT      = transformed_data .* conj(shifted_fft) .* W; 
    LSPIVresult         = ifft(LSPIVresultFFT,[],2);
end

function [q,good] = fit_gaussian(npixels,maxGaussWidth,data_chunk)
    centered_fft   = fftshift(sum(data_chunk,1))/ max(sum(data_chunk,1));
    [~, maxindex] = max(centered_fft(2:end-1));
    pixel_mid = round(npixels/2)-1;
    options = fitoptions('gauss1');
    options.Lower      = [0    npixels/2-pixel_mid   0            0];
    options.Upper      = [1e9  npixels/2+pixel_mid  maxGaussWidth 1];
    options.StartPoint = [1 maxindex 10 .1];
    [q,good] = fit((1:length(centered_fft))',centered_fft','a1*exp(-((x-b1)/c1)^2) + d1',options);
end

function [velocity,amps,sigmas,goodness] = get_velocity(LSPIVresult,step_size,window_size,maxGaussWidth,fft_time_shift)
    index = step_size:step_size:(size(LSPIVresult,1) - window_size);
    npixels = size(LSPIVresult,2);
    velocity  = nan(size(index));
    amps      = nan(size(index));
    sigmas    = nan(size(index));
    goodness  = nan(size(index));
    for i = 1:length(index)
        if mod(index(i),100) == 0
            fprintf('line: %d\n',index(i))
        end
        data_chunk = LSPIVresult(index(i):index(i)+window_size,:);
        [q,good] = fit_gaussian(npixels,maxGaussWidth,data_chunk);
        velocity(i)  = (q.b1 - size(LSPIVresult,2)/2 - 1)/fft_time_shift;
        amps(i)      = q.a1;
        sigmas(i)    = q.c1;
        goodness(i)  = good.rsquare;
    end
end

function [badvals] = evaluate_goodness_of_fit(velocity,nsample_per_second,step_size,maxstd)
    pixel_windowsize = round(nsample_per_second / step_size);
    badpixels = zeros(size(velocity));
    for i = 1:1:length(velocity)-pixel_windowsize
        pmean = mean(velocity(i:i+pixel_windowsize-1)); 
        pstd  = std(velocity(i:i+pixel_windowsize-1));  
        
        pbadpts = find((velocity(i:i+pixel_windowsize-1) > pmean + pstd*maxstd) | ...
                       (velocity(i:i+pixel_windowsize-1) < pmean - pstd*maxstd));
    
        badpixels(i+pbadpts-1) = badpixels(i+pbadpts-1) + 1; 
    end
    badvals  = find(badpixels > 0);  
end

