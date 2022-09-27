function result=get_slope_from_line_scan(radon_image,radon_window_size,radon_function)
    stepsize=floor(.25*radon_window_size);
    nsample = size(radon_image,2);
    nsteps=floor(nsample/stepsize)-3;
    result.locations=zeros(nsteps,1);
    result.slopes=zeros(nsteps,1);
    result.time=NaN*ones(nsteps,1);
    result.windowsize = radon_window_size;
    result.stepsize = stepsize;
    for k=1:nsteps
        result.time(k)=1+(k-1)*stepsize+radon_window_size/2;
        data_chunk=radon_image(:,1+(k-1)*stepsize:(k-1)*stepsize+radon_window_size);
        data_chunk = preprocess_data(data_chunk);
        [theta,radius,~] = radon_function(data_chunk,1:179);
        [result.slopes(k),result.locations(k),~]= get_slope_and_location(radius,theta,size(data_chunk));
        result.locations(k) = result.locations(k)+1+(k-1)*stepsize;
    end
end


