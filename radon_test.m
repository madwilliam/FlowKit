%%
path = '/home/zhw272/code for ben/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(150:end,218000:end);
[nline,nframes] = size(imageData);
start = 1;
data_chunk = all_data(150:end,100:200);
% sim_data=get_test_data();
% data_chunk = sim_data(:,1:8000); 
data_chunk = imcomplement(data_chunk);
mean_data = mean(data_chunk,2);
mean_data = repmat(mean_data,1,size(data_chunk,2));
mean_data = cast(mean_data,class(data_chunk));
data_chunk = data_chunk-mean_data;
%     data_chunk = imgaussfilt(data_chunk,5);

%%
figure 
imagesc(data_chunk)
theta = RadonTools.two_lev
el_radon(data_chunk,@RadonTools.get_max_variance_angle);
theta = RadonTools.two_level_radon(data_chunk,@RadonTools.get_max_value_angle);

angles = 1:179;
[R,radius]=radon(data_chunk,angles);
[max_val_per_angle,max_id_per_angle] = max(R);
[max_R,max_angle_id] = max(max_val_per_angle);
max_radius_id = max_id_per_angle(max_angle_id);
max_R_id = [max_radius_id,max_angle_id];
[slope,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(max_angle_id),size(data_chunk));

figure;
nplot = 2; 
ax1 = subplot(nplot, 1,1);
ax2 = subplot(nplot, 1,2);
Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
Plotter.plot_radon(R,flip(max_R_id),ax2)
set(ax1,'YDir','normal')
set(ax2,'YDir','normal')

1/tand(theta)


%%
start = 1;
chunk = all_data(150:end,100:200);
figure

chunk = imcomplement(chunk);

imagesc(chunk)
% chunk = imgaussfilt(chunk,5);

[slopes,time]=get_slope_from_line_scan(chunk,100);


mean_data = mean(chunk,2);
mean_data = repmat(mean_data,1,size(chunk,2));
mean_data = cast(mean_data,class(chunk));
dat = chunk-mean_data;
test_radon_parameters(dat,1:179,10,1,true);
