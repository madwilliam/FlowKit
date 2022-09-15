path = 'Y:\Data and Analysis\Data\Two Photon Directory';
files = FileHandler.get_tif_files(path);
meta_files = FileHandler.get_meta_files(path);
names = FileHandler.get_names(files);
ids = {};
for namei = names
    found = find(names == namei);
    if length(found) >1
        ids{end+1} =found;
    end
end

lenid = cellfun(@numel,ids);

more_than_two = arrayfun(@(x) x>2,lenid);
ids_more_than_two = ids(more_than_two);
ndup = numel(ids_more_than_two);
for i=1:ndup
    fs = files(ids_more_than_two{i});
    nms = arrayfun(@(x) fullfile(x.folder,x.name),fs,'UniformOutput',false);
    disp(nms)
end