
images = DataSimulator.generate_radon_test(10);

plot_diagnostic(images{i})

for i = 8
    data_chunk = images{i};
    angles = 1:179;
    [R,radius]=radon(data_chunk,angles);
    [max_variance_angle,max_angle_id] = max(var(R));
    [max_radius,max_radius_id] = max(R(:,max_angle_id));
    max_R_id = [max_radius_id,max_angle_id];
    [slope,~]=get_slope_from_line_scan(data_chunk,size(data_chunk,2));
    nplot = 2; 
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
    Plotter.plot_radon(R,flip(max_R_id),ax2)
    [slopes,time]=get_slope_from_line_scan(data_chunk,size(data_chunk,2));
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
%     imagesc(images{i})
    pause(1)
end


i = 8;
data_chunk = images{i};
angles = 1:179;
[R,radius]=radon(data_chunk,angles);
[max_variance_angle,max_angle_id] = max(var(R));
[max_radius,max_radius_id] = max(R(:,max_angle_id));
max_R_id = [max_radius_id,max_angle_id];
[slope,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(max_angle_id),size(data_chunk));
nplot = 2; 
ax1 = subplot(nplot, 1,1);
title('max variance')
ax2 = subplot(nplot, 1,2);
title('')
Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
Plotter.plot_radon(R,flip(max_R_id),ax2)
set(ax1,'YDir','normal')
set(ax2,'YDir','normal')


i = 8;
data_chunk = images{i};
angles = 1:179;
[R,radius]=radon(data_chunk,angles);
[max_val_per_angle,max_id_per_angle] = max(R);
[max_R,max_angle_id] = max(max_val_per_angle);
max_radius_id = max_id_per_angle(max_angle_id);
max_R_id = [max_radius_id,max_angle_id];
[slope,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(max_angle_id),size(data_chunk));
nplot = 2; 
ax1 = subplot(nplot, 1,1);
title('max value')
ax2 = subplot(nplot, 1,2);
Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
Plotter.plot_radon(R,flip(max_R_id),ax2)
set(ax1,'YDir','normal')
set(ax2,'YDir','normal')


figure
histogram(R(:,max_angle_id))
title_Str = {['Integration along max value direction'],[' Variance = ' num2str(var(R(:,max_angle_id)))]};
title(title_Str)

plot(R(:,max_angle_id))
