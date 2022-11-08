theta = -pi/4+0.1;
[x1,y1]=pol2cart(theta,200);
[x2,y2]=pol2cart(theta+pi,200);
img = zeros(100,1000);
img = insertShape(img, 'Line', [x1+50, y1+50, x2+50, y2+50], 'LineWidth', 10);
img = img(:,:,1);
img = img+rand(size(img))*20;

plot_diagnostic(imageData)

imagesc (img)

%%
path = '/home/zhw272/AutoCropped/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(:,500:700);
%%
imagesc(preprocess_data(imageData))