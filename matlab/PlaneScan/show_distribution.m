function show_distribution(x,y)
ax = scatter(x,y,3,'+k'); 
for i = 1:numel(ax)
    ax(i).MarkerFaceAlpha=0.3;
    ax(i).MarkerEdgeAlpha=0.3;
end