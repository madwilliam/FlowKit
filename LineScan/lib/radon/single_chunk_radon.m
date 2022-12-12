function result = single_chunk_radon(data_chunk,radon_function)
    data_chunk = preprocess_data(data_chunk);
    [theta,radius,~] = radon_function(data_chunk,1:179);
    [result.slopes,~,result.locations]= RadonTools.get_slope_intercept_and_location(radius,theta,size(data_chunk));
end

