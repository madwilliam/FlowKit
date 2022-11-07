meta_name = 'C:\Users\dklab\Desktop\rois.txt';
str = read_text(meta_name);
roi = jsondecode(str);

roi.rois(1)

 [hex_uuid,int64_uuid] = LifeTimeROI.make_uuid();

hRoiGroup = scanimage.mroi.RoiGroup();    % create an empty RoiGroup object

hRoi1 = scanimage.mroi.Roi();             % create an empty Roi
hRoiGroup.add(hRoi1);                     % add hRoi1 to hRoiGroup

hRoi2 = scanimage.mroi.Roi();             % create an empty Roi
hRoiGroup.add(hRoi2);                     % add hRoi2 to hRoiGroup

hRoiGroup.clear();   

hSf0 = scanimage.mroi.scanfield.fields.RotatedRectangle();  % create an imaging Scanfield
hSf1 = scanimage.mroi.scanfield.fields.RotatedRectangle();  % create an imaging Scanfield
hSf2 = scanimage.mroi.scanfield.fields.RotatedRectangle();  % create an imaging Scanfield

hRoi = scanimage.mroi.Roi();                                % create an empty Roi

hRoi.add(0,hSf0);                                           % add Scanfield at z = 0
hRoi.add(1,hSf1);                                           % add Scanfield at z = 1
hRoi.add(2,hSf2);                                           % add Scanfield at z = 2

hSf.scanfields                                              % show lists of Scanfields in roi
hSf.zs                                                      % show list of zs

tf = hSf.hit(3)                                             % check if Roi is defined at z=3

tf = hSf.hit(0.5)                                           % check if Roi is defined at z=0.5
hSf_interpolated = hRoi.get(0.5);                           % return interpolated Scanfield at z=0.5

idx = hRoi.idToIndex(hSf0.uuiduint64);                     % find Scanfield with given uuid in Roi
hRoi.removeById(idx);                                      % remove Scanfield from Roi

hRoi.removeByZ(2);  