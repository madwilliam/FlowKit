dx = 0.1606; %um/pix
dt = 0.24; %ms
raw_data = get_raw_data();
raw_size = numel(raw_data);
nsteps = floor(npixel*nframes/raw_size);
nsample_to_show=20;
radon_chunk_size = 100;
slope_data = zeros(1,nsample_to_show);
display_time = zeros(1,nsample_to_show);
data_chunk = reshape(raw_data,nline,[]);
data_range = [1 nline];
nsample = size(data_chunk,2);
data_per_chunk = (nsample-radon_chunk_size)/floor(radon_chunk_size*0.25)+1;
display_data = zeros(data_range(2)-data_range(1)+1,floor(nsample_to_show/data_per_chunk*radon_chunk_size));
ndisplay = size(display_data,2);
[ax1,ax2,btn]=create_ui_panel();
while true
    raw_data = get_raw_data();
    data_chunk = reshape(raw_data,nline,[]);
    data_chunk = data_chunk(data_range(1):data_range(2),:);
    try
        [slopes,time]=get_slope_from_line_scan(data_chunk,radon_chunk_size);
        n_new_points = length(slopes);
        assert(n_new_points<nsample_to_show)
        slope_data = circshift(slope_data,-n_new_points);
        display_time = circshift(display_time,-n_new_points);
        display_data = circshift(display_data,-nsample,2);
        display_time(end-n_new_points+1:end) = time+display_time(end-n_new_points);
        slope_data(end-n_new_points+1:end) = slopes;
        display_data(:,end-nsample+1:end) = data_chunk;
        
        plot(ax1,slope_data*dx/dt)
        imagesc(ax2,display_data,'XData', [0 0], 'YData', [0 0])
        xlim(ax2,[0,size(display_data,2)])
        ylim(ax2,[0,size(display_data,1)])
    catch
        disp('error')
    end
    pause(1)
end