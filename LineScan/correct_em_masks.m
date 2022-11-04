weka_root = '/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed_mask/'; %ML output
mat_root = '/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed/'; %original mat file locations
weka_files = FileHandler.get_tif_files(weka_root);
ogtifs = FileHandler.get_tif_files(mat_root);
nfiles = numel(ogtifs);
for filei = 1:nfiles
    weka_file = ogtifs(filei);
    filename = FileHandler.strip_extensions(weka_file.name);
    tif_path = FileHandler.get_file_path(ogtifs,filename);
    mask_path = FileHandler.get_file_path(weka_files,filename);
    images = FileHandler.load_image_data(tif_path);
    mask = FileHandler.load_image_data(mask_path);
    ones = mean(images(mask==1));
    zeros = mean(images(mask==0));
    if zeros > ones
        mask = 1-mask;
        t = Tiff(mask_path,'w');
        tagstruct.ImageLength     = size(data,1);
        tagstruct.ImageWidth      = size(data,2);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.RowsPerStrip    = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct)
        t.write(uint32(mask));
    end
end
