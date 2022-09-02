%%
path = '/home/zhw272/code for ben/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(150:end,1:8000);
%%
data = preprocess_data(imageData);
[R,radii]=radon(data,1:179);
%%
LineScanAnnalyzer(imageData,100)
%%
plot_diagnostic(imageData)
%%
path = '/home/zhw272/data/mtar.mat';
image = load(path).out;

marked_data = image(:,1:8000);
figure
imagesc(preprocess_data(imcomplement(imageData(:,1:1000)))>25)

imagesc(edge(imageData))
%%
csvwrite('/home/zhw272/code for ben/pack-071022_08-19-22_vessel1_100ms_50mW_00004.csv',[time,slopes])
%%
[marked_slopes,time]=get_slope_from_line_scan(marked_data,100);
[raw_slopes,time,locations,rval]=get_slope_from_line_scan(imcomplement(imageData),100);
%

[raw_slopes_old,time_old,locations_old,rval_old]=get_slope_from_line_scan(imcomplement(imageData),100);

%%

imagesc(imageData(:,1:100));
imagesc(imcomplement(imageData(:,1:100)));
figure
imagesc(imageData)
imagesc(imcomplement(imageData))

%%
imagesc(imageData)

BW = edge(imageData);
figure
imshow(BW)
%%
width = 800;
figure 
hold on
md = marked_data(:,1:width);
md = bwmorph(md,'thicken',1);
C = imfuse(md,im,'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
imagesc(C)
im = uint16(imageData(1:84,1:width));
im = im-mean(im,'all');

nlines = numel(locations);
x = 1:size(im,2);
for linei = 1:nlines
    loaction = locations(linei);
    slope = raw_slopes(linei);
    intercept = floor(size(im,1)/2)-slope .* loaction;
    y=raw_slopes(linei)*x+intercept;
    plot(x,y,'color','blue','LineWidth',2)
end
ylim([1,size(md,1)])
xlim([1,size(md,2)])


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
%plot all slope detections
Plotter.plot_detected_stripes(marked_data,locations,raw_slopes,time)
%%
[raw_slopes,time,locations]=get_slope_from_line_scan(imcomplement(data_chunk),100);
Plotter.plot_detected_stripes(data_chunk,locations,raw_slopes,time)

%%
std(raw_slopes-marked_slopes)
std(raw_slopes_old-marked_slopes)

mean(abs(raw_slopes-marked_slopes))
mean(abs(raw_slopes_old-marked_slopes))
%%
figure
ax1 = subplot(2,1,1);
imagesc(ax1,imageData)
ax2 = subplot(2,1,2);
hold on
plot(ax2,time,(raw_slopes-marked_slopes)*dx_dt,'color','r')
%%
figure
histogram(raw_slopes-marked_slopes)
%%
[all_slopes,all_locations]=get_slope_from_all_stripes(imageData,100,1:179);

plot(all_locations,all_slopes)
