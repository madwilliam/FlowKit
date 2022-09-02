data = Rgauss;

x = 0:size(data,2)-1;
y = 0:size(data,1)-1;
[X,Y] = meshgrid(x,y); 
meshc(X, Y, data)                              % Mesh Plot
grid on
xlabel('X')
ylabel('Y')
zlabel('Intensity')
colormap(jet)  
[radius_ids, theta_ids]

figure
imagesc(Rgauss)
hold on
for i = 1:numel(radius_ids)
    scatter(theta_ids(i),radius_ids(i))
end
hold off


imagesc(data_chunk)