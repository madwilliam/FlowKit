function [parameters,line_fit] = fit_po2_decay(data_to_fit,time,idx_start,decay_profile_function)
    nsample = numel(time);
    nlines = size(data_to_fit,1);
    line_fit = zeros(nlines,nsample-idx_start+1);
    c0 = [1 40 0];
    options.Algorithm='levenberg-marquardt';
    options.FunctionTolerance=1e-25;
    parameters = cell(nlines,1);
    for i = 1:nlines
        xdata = time(idx_start:end);
        ydata = data_to_fit(i,idx_start:end);
        decay_profile =       @(c) decay_profile_function(c,xdata);
        decay_profile_error = @(c) (ydata - decay_profile(c));
        cAll =  lsqnonlin(decay_profile_error , ...
            c0, [],[],options);
        parameters{i} = cAll;
        line_fit(i,:) = decay_profile(parameters{i});
    end
end