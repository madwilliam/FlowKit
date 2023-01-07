data = tiffreadVolume('C:\Users\Virginia\Documents\VesselDiameterAnalysis\2022    12    22    12    14    41.tiff');
data = imcomplement(data);

%%
projection = mean(data,3);
figure
imagesc(projection)
colormap(gray)
[x,y] = getpts();
%%
cross_line_distance = 20;
cross_line_length = 20;
cross_lines = VesselDiameter.makeCrossLines(x,y,cross_line_distance,cross_line_length);
% VesselDiameter.plot_cross_lines(data,x,y,cross_lines)
[meanFwhms,meanFwhmSTDEVs] = VesselDiameter.getVesselDiameter(data,x,y,cross_line_distance,cross_line_length,10);
VesselDiameter.plot_result(meanFwhms,meanFwhmSTDEVs)

%%
roi = ReadImageJROI('C:\Users\Virginia\Desktop\1.roi');
x = roi.mnCoordinates(1:end,1);
y = roi.mnCoordinates(1:end,2);
cross_lines = VesselDiameter.makeCrossLines(x,y,20,20);
VesselDiameter.plot_cross_lines(data,x,y,cross_lines)

%%
l = improfile(data(1:end,1:end,1),[300,300],[380,400]);
plot(data(380:400,300,1))

%%
mat = load('C:\Users\Virginia\Downloads\errList.mat')
x = [23,28];
y = [225,243];
cross_line_distance = 2;
cross_line_length = 20;
cross_lines = VesselDiameter.makeCrossLines(x,y,cross_line_distance,cross_line_length);
VesselDiameter.plot_cross_lines(data,x,y,cross_lines)
[meanFwhms,meanFwhmSTDEVs] = VesselDiameter.getVesselDiameter(data,x,y,cross_line_distance,cross_line_length,10);
