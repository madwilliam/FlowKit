classdef TiffHandler
   methods (Static)
       function tiff_stack = load_image_stack(tiffile)
           n_image = TiffHandler.get_number_of_image_in_stack(tiffile);
           tiff_stack = imread(tiffile, 1) ; 
           for ii = 2 : n_image
               waitbar(ii/n_image,f,append('Loading your data (',num2str(ii),'/',num2str(n_image)));
               temp_tiff = imread(tiffile, ii);
               tiff_stack = cat(3 , tiff_stack, temp_tiff);
           end
       end

       function n_image = get_number_of_image_in_stack(tiffile)
           tiff_info = imfinfo(tiffile); 
           n_image = size(tiff_info, 1);
       end

       function image_frames = load_frames(tiffile,frame_numbers,lines,nsample)
           nlines= numel(lines);
           nframes = numel(frame_numbers);
           image_frames = zeros([nframes,nlines,nsample]);
           i=1;
           for framei = frame_numbers
               image = imread(tiffile, framei) ;
               image_frames(i,:,:) = preprocess_po2_data(image,lines);
               i=i+1;
           end
       end

   end
end