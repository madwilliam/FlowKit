function mask = add_rectangle_to_mask(rect,mask,i)
[nx,ny] = size(mask);
rect = num2cell(floor(rect.*[nx,nx,ny,ny]));
[x,y,w,h] = deal(rect{:});
mask(y:y+h,x:x+w) = i;
end

