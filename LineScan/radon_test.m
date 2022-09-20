%%
path = 'Y:\Test\Test\';
files = dir([path '*.tif']);
filei = [path,files(3).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = imcomplement(all_data(1:end,:));
%%
path = 'Y:\Test\Test\';
file_name = 'PACK-050522-NoCut_05-17-22_Vessel1_CBF_00004';
meta_files = FileHandler.get_meta_files(path);
tif_files = FileHandler.get_tif_files(path);
pmt_files = FileHandler.get_pmt_files(path);
meta_file = FileHandler.get_file(meta_files,file_name);
[SI,RoiGroups] = FileHandler.load_meta_data(meta_file);
[dx,dt] = get_dxdt(SI,RoiGroups);
%%
anna = LineScanAnnalyzer(imageData(1:end,1:8000),100);
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