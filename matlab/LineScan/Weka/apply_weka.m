loadedModel = wekaLoadModel('/net/dk-server/bholloway/Zhongkai/ML/RBCs.model');

analysis_path = '/net/dk-server/bholloway/Zhongkai/FoG';
tif_files = FileHandler.get_tif_files(analysis_path );
tif_path = fullfile(analysis_path ,tif_files(1).name);
image = FileHandler.load_image_data(tif_path);

relation    = 'rbc data';
attributes  = arrayfun(@(x) {['attribute_' num2str(x)]}, 1:size(image,2));
weka_image = matlab2weka(relation,attributes,image);

[~,Y] = wekaClassify(test, gmModel);

MATLAB.PRF