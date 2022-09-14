%%
path = '/home/zhw272/better_data/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(150:end,:);
%%
anna = LineScanAnnalyzer(imageData,100);
%%
[raw_slopes,time,locations,rval]=get_slope_from_line_scan(imcomplement(imageData),100);
Plotter.plot_detected_stripes(imcomplement(imageData),location_per_stripe,slopes_per_stripe,time_per_stripe)
%%
path = '/home/zhw272/data/mtar.mat';
image = load(path).out;
marked_data = image(:,1:8000);
%%
[location_per_stripe,slopes_per_stripe,time_per_stripe] = find_speed_per_cell(locations,raw_slopes,time);
Plotter.plot_detected_stripes(marked_data,location_per_stripe,slopes_per_stripe,time_per_stripe)
[flux,~] = histcounts(location_per_stripe,40);
plot(flux)
%%
figure
ax1 = subplot(311);
ax2 = subplot(312);
ax3 = subplot(313);
img = imcomplement(imageData);
img = img - mean(imcomplement(imageData),'all');
imagesc(ax1,img)
plot(ax2,time,raw_slopes-marked_slopes)
plot(ax3,time,raw_slopes_old-marked_slopes)
title(ax2,'new method detection-manual')
title(ax3,'old method detection-manual')
%%