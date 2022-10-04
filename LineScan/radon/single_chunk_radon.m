function result = single_chunk_radon(data_chunk,radon_function)
    data_chunk = preprocess_data(data_chunk);
    [theta,radius,~] = radon_function(data_chunk,1:179);
    [result.slopes,result.locations,~]= get_slope_and_location(radius,theta,size(data_chunk));
end

