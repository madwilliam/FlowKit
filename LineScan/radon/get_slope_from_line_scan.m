function result=get_slope_from_line_scan(data,windowsize,radon_function)
    stepsize=.25*windowsize;
    nsample = size(data,2);
    nsteps=floor(nsample/stepsize)-3;
    result.locations=zeros(nsteps,1);
    result.slopes=zeros(nsteps,1);
    result.time=NaN*ones(nsteps,1);
    result.windowsize = windowsize;
    result.stepsize = stepsize;
    for k=1:nsteps
        result.time(k)=1+(k-1)*stepsize+windowsize/2;
        data_chunk=data(:,1+(k-1)*stepsize:(k-1)*stepsize+windowsize);
        [data_chunk,result.downsample_factor] = preprocess_data(data_chunk,windowsize);
        [theta,radius,~] = radon_function(data_chunk,1:179);
        [result.slopes(k),result.locations(k),~]= get_slope_and_location(radius,theta,size(data_chunk));
        result.locations(k) = result.locations(k)+1+(k-1)*stepsize;
    end
end


