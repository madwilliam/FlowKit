path = '/home/zhw272/AutoCropped/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
imageData = read(t);

sim_data=get_test_data();
data_chunk = sim_data(:,1:8000);

data_chunk = double(data_chunk);
imagesc(data_chunk)
imagesc(U*S*V')
imagesc(U*S)
imagesc(S)
imagesc(U)
imagesc(V')

i=1;
img = zeros(100,100);
img = insertShape(img, 'Line', [x1(i)+50, y1(i)+50, x2(i)+50, y2(i)+50], 'LineWidth', 10);
imagesc(img(:,:,1))

theta = 0:0.01:2*pi;
[x1,y1]=pol2cart(theta,200);
[x2,y2]=pol2cart(theta+pi,200);

max_eigen = [];
for i = 1:length(theta)
    img = zeros(100,100);
    img = insertShape(img, 'Line', [x1(i)+50, y1(i)+50, x2(i)+50, y2(i)+50], 'LineWidth', 10);
    [U,S,V] = svd(img(:,:,1));
    max_eigen = [max_eigen  max(diag(S))];
end

figure ;
lin= plot(rad2deg(theta),max_eigen);
xticks([0,90,180,270,360])
% xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'})


[U,S,V] = svd(img(:,:,1));
plot(diag(S))
max(diag(S))


data = double(data_chunk);
curimtitle = {'edm','vdm','sob'}; curcolor = {'b','g','k','r','c','m'};
imgseg(:,:,1) = data(2:end-1,2:end-1)-mean(mean(data(2:end-1,2:end-1))); % subtract mean pixel intensity
imgseg(:,:,2) = bsxfun(@minus,data(2:end-1,2:end-1),mean(data(2:end-1,2:end-1),1)); % subtract time average
imgseg(:,:,3) = filter2([1 2 1; 0 0 0; -1 -2 -1],data,'valid');  % 3x3 vertical Sobel filter, Eq. 5,6

imagesc(imgseg(:,:,3))

imgsegsz = size(imgseg);
firstiter = (thetarange(1):firstthetastep:thetarange(2));
firstiter = firstiter-(firstiter(end)-firstiter(1))/2+1;

segend = segment_height:lineskip:imgsegsz(1);
segstart = segend-segment_height+1;
segn = length(segstart);

angle = nan(segn,9,imgsegsz(3)); % angle = [angle,minstep,loc(pix),dels1,deln,%dv/v,iter,irl,speed(mm/s)]
utheta = cell(segn,imgsegsz(3)); 
uvar = cell(segn,imgsegsz(3));

data_chunk = imageData(:,1:size(imageData,1));
data_chunk = imageData(:,1:800);
mean_data = mean(data_chunk,2);
mean_data = repmat(mean_data,1,size(data_chunk,2));
data_chunk = data_chunk-uint16(mean_data);
data_chunk = imgaussfilt(data_chunk,5);

figure
imagesc(data_chunk)
imagesc(mean_data)

data_chunk = sim_data(:,1:100);

[slopes,time]=get_slope_from_line_scan(data_chunk,100);
slopes = pad_no_detections(slopes);
figure
subplot(2,1,1)
plot(time,-slopes)
subplot(2,1,2)
imagesc(data_chunk)

test_radon_parameters(data_chunk, 1:179, 20, 1, true)

radon(data_chunk)

userpath