function data = get_simulated_data_feed(counter)
    data = DataSimulator.get_test_line_scan_data_chunk([counter*100,(counter+1)*100]);
    data = reshape(data,[],1);
    data = data+rand(size(data));
end