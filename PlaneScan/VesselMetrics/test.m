data = tiffreadVolume('C:\Users\Virginia\Documents\VesselDiameterAnalysis\2022    12    22    12    14    41.tiff');
%%
projection = mean(data,3);
figure
imagesc(projection)
colormap(gray)
[x,y] = getpts();
getVesselDiameter(data,xs,ys,1,3)
%%
data = imcomplement(data);
cross_line_distance = 20;
cross_line_length = 20;
cross_lines = VesselDiameter.makeCrossLines(x,y,20,20);
VesselDiameter.plot_cross_lines(data,x,y,cross_lines)
[meanFwhms,meanFwhmSTDEVs] = VesselDiameter.getVesselDiameter(data,x,y,cross_line_distance,cross_line_length,10);
VesselDiameter.plot_result(meanFwhms,meanFwhmSTDEVs)