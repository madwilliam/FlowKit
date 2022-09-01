function plot_diagnostic(data_chunk)
    figure
    angles = 1:179;
    data_chunk = preprocess_data(data_chunk);
    [R,radius]=radon(data_chunk,angles);
    [slope,~]=get_slope_from_line_scan(data_chunk,size(data_chunk,2));
    theta = mod(floor(atand(1/slope))+180,180);
    [~,max_theta_id] = max(max(R));
    [~,max_radius_id] = max(R(:,max_theta_id));
    max_R_id = [max_radius_id,theta];
    [~,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(theta),size(data_chunk));
    nplot = 2; 
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
    Plotter.plot_radon(R,flip(max_R_id),ax2)
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
    title(ax1,['slope = ' num2str(slope)])
end