mov = VideoReader('/net/dk-server/bholloway/Pack-081122_09-29-22_vessel-4_00014_vid_fixed.avi');
all_frame = read(mov);

imagesc(average_frame(:,:,3))

average_frame = mean(all_frame,4);
average_frame = average_frame./max(average_frame);
size(average_frame)

imagesc(frame)
imagesc(frame-average_frame)
imagesc(average_frame(:,:,1)>0.5)
%%
filt = imgaussfilt(average_frame,30);
mask = (average_frame-filt)>0.1;
vessel_mask = bwareaopen(mask,LB);
vessel_mask = vessel_mask(:,:,1);
vessel_mask = bwmorph(vessel_mask,'majority');
vessel_mask = bwmorph(vessel_mask,'majority');
vessel_mask = bwmorph(vessel_mask,'majority');
vessel_mask = bwmorph(vessel_mask,'majority');
imagesc(vessel_mask)
%%
vessel_mask_path = bwskel(vessel_mask);
vessel_mask_path_index = find(vessel_mask_path);
[x,y] = ind2sub(size(vessel_mask),vessel_mask_path_index);
hold on
imagesc(vessel_mask)
scatter(y,x,500,1:numel(x),'.')
%%
img = imagesc(framei);
for i =1:1000
    framei = double(all_frame(:,:,1,i));
    framei = framei-average_frame(:,:,1);
    framei(find(~vessel_mask))=0;
    img.CData = framei;
    pause(1/24)
end
%%
vessel_mask = bwmorph(vessel_mask,'majority');
vessel_mask = bwmorph(vessel_mask,'majority');
vessel_mask = bwmorph(vessel_mask,'majority');
%%

B = bwskel(vessel_mask);
imagesc(B)

%%
xy = [x(:), y(:)]; 
distance = pdist2(xy,xy);
distance(find(eye(size(distance))))=max(distance);
[~,id] = max(max(mink(distance,2,1),[],1));
idx =  1:numel(x); 
yIdx = [id,nan(size(y)-1)]; 
xy(id,:) = NaN; 
idx = [id, nan(1, numel(x))]; 
counter = 0; 
while any(isnan(idx))
    counter = counter+1; 
    [~, idx(counter+1)] = min(pdist2(xy,[x(idx(counter)), y(idx(counter))])); 
    xy(idx(counter+1),:) = NaN; 
end

figure()
subplot(1,2,1)
plot(x,y,'r-o')
axis square
grid on
title('Original scattered coordinates')
subplot(1,2,2)
idx = idx(1:end-1);
plot(x(idx), y(idx), 'r-o')
axis square
grid on
title('Sorted coordinates')
%%
figure
hold on
imagesc(vessel_mask)
scatter(y(idx),x(idx),500,(1:numel(idx))/5,'.')
%%
x = x(idx);
y = y(idx);
npoints = numel(x);
for pointi = 1:npoints
    ...
end
%%

nframes = size(all_frame,4);
scan_result = [];
for framei = 1:nframes
    frame = double(all_frame(:,:,:,framei));
    frame = frame./max(frame);
    difference = frame-average_frame;
    difference = difference(:,:,1);
    difference(find(~vessel_mask))=0;
    values = [];
    for i = 1:npoints
        id = y(i);
        column = vessel_mask(:,x(i));
        ids = find(diff(sign(column)))+1;
        [~,neighbor_ids] = mink(abs(ids-id),2);
        y_start_and_end = sort(ids(neighbor_ids));
        data = difference(x(i),y_start_and_end(1):y_start_and_end(2));
        values = [values sum(data)];
    end
    scan_result = [scan_result values'];
end
%%
imagesc(scan_result)
%%
all_difference = [];
for framei = 1:nframes
    frame = double(all_frame(:,:,:,framei));
    frame = frame./max(frame);
    difference = frame-average_frame;
    difference = difference(:,:,1);
    difference(find(~vessel_mask))=0;
    all_difference = [all_difference difference];
end