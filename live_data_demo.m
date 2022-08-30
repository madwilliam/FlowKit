%%
path = '/home/zhw272/code for ben/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(150:end,218000:end);
[nline,nframes] = size(imageData);

%%
raw_size = nline*100;
nsteps = floor(npixel*nframes/raw_size);
raw_data = imageData(1:raw_size);
data_chunk = reshape(raw_data,nline,[]);
nsample_to_show=20;
chunk_size = 100;
slope_data = zeros(1,nsample_to_show);
display_time = zeros(1,nsample_to_show);
data_chunk = reshape(raw_data,nline,[]);
data_range = [1 nline];
%     lastStripe=hSI.hDisplay.stripeDataBuffer{hSI.hDisplay.stripeDataBufferPointer};
%     data_chunk = reshape(lastStripe.rawData,nline,[]);
nsample = size(data_chunk,2);
data_per_chunk = (nsample-chunk_size)/floor(chunk_size*0.25)+1;
display_data = zeros(data_range(2)-data_range(1)+1,floor(nsample_to_show/data_per_chunk*chunk_size));
ndisplay = size(display_data,2);
%%
fig = uifigure;
btn = uibutton(fig,'push',...
               'Position',[630, 50, 50, 22],...
               'Text', 'Sample',...
               'ButtonPushedFcn', @(btn,event) sample_data(btn,ax));
xstart = 10;
ystart = 270;
width = 600;
height = 250;
p1 = uipanel(fig,'Position',[xstart ystart width height]);
ax1 = uiaxes(p1,'Position',[10 10 width-10 height-10]);

xstart = 10;
ystart = 10;
width = 600;
height = 250;
p2 = uipanel(fig,'Position',[xstart ystart width height]);
ax2 = uiaxes(p2,'Position',[10 10 width-10 height-10]);
%%
dx = 0.1606; %um/pix
dt = 0.24; %ms

dx/dt;

%%
for i = 1:nsteps
    raw_data = imageData((i-1)*raw_size+1:i*raw_size);
%     data_chunk = reshape(lastStripe.rawData,nline,[]);
    data_chunk = reshape(raw_data,nline,[]);
    data_chunk = data_chunk(data_range(1):data_range(2),:);
    data_chunk = imcomplement(data_chunk);
    try
        [slopes,time]=get_slope_from_line_scan(data_chunk,chunk_size);
        n_new_points = length(slopes);
        assert(n_new_points<nsample_to_show)
        slope_data = circshift(slope_data,-n_new_points);
        display_time = circshift(display_time,-n_new_points);
        display_data = circshift(display_data,-nsample,2);
        display_time(end-n_new_points+1:end) = time+display_time(end-n_new_points);
        slope_data(end-n_new_points+1:end) = slopes;
        display_data(:,end-nsample+1:end) = data_chunk;
%         subplot(2,1,1,'Parent', fig)
        plot(ax1,slope_data*dx/dt)
%         subplot(3,1,2)
%         plot(imgaussfilt(slope_data,1))
%         subplot(2,1,2,'Parent', fig)
        imagesc(ax2,display_data,'XData', [0 0], 'YData', [0 0])
        xlim(ax2,[0,size(display_data,2)])
        ylim(ax2,[0,size(display_data,1)])
%         set(ax2,'YDir','normal') 
    catch
        disp('error')
    end
    pause(1)
end