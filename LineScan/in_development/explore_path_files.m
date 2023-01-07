directory = '/net/dk-server/bholloway/Data and Analysis/Data/Two Photon Directory/CBF/';
[common_names,files]=FileHandler.find_common_names({'meta','path'},directory);
meta_files = files{1};
path_files = files{2};
%%
file = common_names(1);
meta_file = FileHandler.get_file(meta_files,file_name);
path_file = FileHandler.get_file(path_files,file_name);
path_path = FileHandler.file_to_path(path_file);
mat = load(path_path);
meta_path = FileHandler.file_to_path(meta_file);
[SI,RoiGroups] = parse_scan_image_meta(meta_path);
%%
center = RoiGroups.imagingRoiGroup.rois(2).scanfields.centerXY;
size = RoiGroups.imagingRoiGroup.rois(2).scanfields.sizeXY;
bounds = [center-size,center+size];
xbounds = sort(bounds(1,:));
ybounds = sort(bounds(2,:));

scan_path = mat.ST.pathFov.G;
figure
hold on 
line(xbounds,[ybounds(1),ybounds(1)])
line(xbounds,[ybounds(2),ybounds(2)])
line([xbounds(1),xbounds(1)],ybounds)
line([xbounds(2),xbounds(2)],ybounds)
scatter(scan_path(1:end,1),scan_path(1:end,2))
hold off
