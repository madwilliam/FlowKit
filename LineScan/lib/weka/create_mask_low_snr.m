function mask = create_mask_low_snr(tif)
    A = imgaussfilt(tif,[3,3]);
    B = imgaussfilt(tif,[30,500]);
    diff = ((B-A)>0);
    length = min([size(diff,2),1000]);
    chunk = tif(:,1:length);
    chunk_mask = diff(:,1:length);
    if mean(chunk(~chunk_mask))<mean(chunk(chunk_mask))
        diff = ~diff;
    end
    se = strel('disk',3);
    mask = imclose(diff,se);
end 