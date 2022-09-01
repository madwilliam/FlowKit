function data = preprocess_data(data)
    data = data-mean(data,'all');
    mean_data = mean(data,2);
    mean_data = repmat(mean_data,1,size(data,2));
    mean_data = cast(mean_data,class(data));
    data = data-mean_data;
%     data = imgaussfilt(data,10);
%     data = edge(data);
end