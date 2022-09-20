function [stimulus_frames,po2_frames] = get_tiff_stack_information(tiffile,start_frame)
tiff_info = imfinfo(tiffile); % return tiff structure, one element per image
nframes = numel(tiff_info);
stimulus_frames = start_frame:2:nframes;
po2_frames = start_frame+1:2:nframes;
end