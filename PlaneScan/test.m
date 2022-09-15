boxes = hSI.hBeams.powerBoxes;
nbox = numel(boxes);

image = hSI.hDisplay.lastAveragedFrame{3};
[ny,nx] = size(image);
mask = zeros(ny,nx);
for i =1:nbox
    mask = add_rectangle_to_mask(boxes(i).rect,mask,i);
end

C = imfuse(image,mask,'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
imshow(C)


