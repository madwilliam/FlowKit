weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
train_root = '/net/dk-server/bholloway/Zhongkai/train_sample/';
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
tif_files = FileHandler.get_tif_files(mat_root);
nfiles = numel(weka_files);
parfor filei = 1:nfiles
    weka_file = weka_files(filei);
    weka_path = fullfile(weka_root,weka_file.name);
    file_name = FileHandler.strip_extensions(weka_file.name);
    mat_path = fullfile(weka_root,append(file_name,'.mat'));
    tif_path = fullfile(mat_root,append(file_name,'.tif'));
    image = FileHandler.load_image_data(weka_path);
    tiff_image = FileHandler.load_image_data(tif_path);
    stripe_coordinates = WekaAnalyzer.crop_stripes(image);
    for stripei = 1:numel(stripe_coordinates)
        stripe = stripe_coordinates{stripei};
        [x,y] = ind2sub(size(image),stripe);
        minx = min(x)-1;
        x = x-min(x)+1;
        maxx = max(x)+2;
        chunk = zeros(size(image,1),maxx+1);
        for i = 1:numel(x)
            chunk(x(i),y(i)) = 1;
        end
        image_chunk = tiff_image(:,minx+1:minx+1+maxx);
        imwrite(image_chunk,[train_root file_name '_stripe_' num2str(stripei) '_image.tiff'],'tiff');
        imwrite(chunk,[train_root file_name '_stripe_' num2str(stripei) '_mask.tiff'],'tiff');
    end
end