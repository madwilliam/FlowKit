annalyzer = PassiveLiveRandonAnnalyzer(64,[],100,1,64,100);
data_chunk = DataSimulator.get_simulated_data_feed(1);
data_chunk = reshape(data_chunk,[],100);
imagesc(data_chunk)

annalyzer.add_data(data_chunk);