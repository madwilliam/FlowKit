boxes = hSI.hBeams.powerBoxes;
nbox = numel(boxes);

image = hSI.hDisplay.lastAveragedFrame{3};
[ny,nx] = size(image);
mask = zeros(ny,nx);
for i =1:nbox
    rect = boxes(i).rect;
    rect = num2cell(floor(rect.*[nx,nx,ny,ny]));
    [x,y,w,h] = deal(rect{:});
    mask(y:y+h,x:x+w) = i;
end

C = imfuse(image,mask,'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
imshow(C)
