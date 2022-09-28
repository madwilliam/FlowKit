imagers = imresize(image, 'bilinear', 'Scale', [1/3,1/3]);

figure
subplot(211)
imagesc(imagers(:,1:333))
subplot(212)
imagesc(image(:,1:1000))

image8 = im2int8(imagers);

load(mat_path,'speed','time_per_velocity_data_s','dt_ms')
sample_per_v_data = time_per_velocity_data_s*1000/dt_ms;
[axes, pos] = tight_subplot(10,1,[.01 .01],[.01 .01],[.01 .01]);
chunk_length = 2000;
for i =1:10
    hold(axes(i),'on')
    start_image = (i-1)*chunk_length+1;
    end_image = i*chunk_length;
    image_chunk = imagers(:,start_image:end_image);
    start_speed = floor(start_image*3/sample_per_v_data)+1;
    end_speed = floor(end_image*3/sample_per_v_data);
    speed_time = linspace(1,chunk_length,(end_speed-start_speed+1));
    imagesc(axes(i),image_chunk)
    plot(axes(i),speed_time,speed(1,start_speed:end_speed)/200,'r')
    set(gca,'XTick',[])
    hold(axes(i),'off')
    xlim(axes(i),[1,size(image_chunk,2)])
    ylim(axes(i),[1,size(image_chunk,1)])
end
% ax.XAxis.Visible = 'on';


for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

sample_per_v_data = time_per_velocity_data_s*1000/dt_ms;

size(speed ,2)*sample_per_v_data/3