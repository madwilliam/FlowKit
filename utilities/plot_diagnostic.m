function plot_diagnostic(data_chunk)
    figure
    angles = 1:179;
    [R,radius]=radon(data_chunk,angles);
    [~,max_angle_id] = max(var(R));
    [~,max_radius_id] = max(R(:,max_angle_id));
    max_R_id = [max_radius_id,max_angle_id];
    [~,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(max_angle_id),size(data_chunk));
    [slope,~]=get_slope_from_line_scan(data_chunk,size(data_chunk,2));
    nplot = 2; 
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
    Plotter.plot_radon(R,flip(max_R_id),ax2)
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
end