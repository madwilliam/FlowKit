function lines = get_lines(tiffile,start_frame)
image = imread(tiffile, start_frame) ; 
tmean = mean(image,2);
[peaks,lines] = findpeaks(tmean,'MinPeakProminence',2000);
figure
hold on
plot(tmean)
scatter(lines,peaks)
title('temporal average')
hold off
end