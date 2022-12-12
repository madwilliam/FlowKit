function plot_diagnostic(data_chunk)
    
    angles = 1:179;
    data_chunk = preprocess_data(data_chunk);
    [R,radius]=radon(data_chunk,angles);
    [slope,~]=get_slope_from_line_scan(data_chunk,size(data_chunk,2));
    theta = mod(floor(atand(1/slope))+180,180);
    [~,max_theta_id] = min(abs(angles-theta));

    max_theta_id = 144;
    [~,max_radius_id] = max(R(:,max_theta_id));
    max_R_id = [max_radius_id,theta];
    [~,intercept] = RadonTools.get_slope_intercept_and_location(radius(max_radius_id),angles(theta),size(data_chunk));
    nplot = 3; 
    figure
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    ax3 = subplot(nplot, 1,3);
    slope = 1/tand(angles(max_theta_id));
    RadonBackPlotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
    RadonBackPlotter.plot_radon(R,flip(max_R_id),ax2)
    plot(ax3,R(:,max_theta_id))
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
    title(ax1,['slope = ' num2str(slope)])
    title(ax3,['kurtosis = ' num2str(kurtosis(R(:,max_theta_id))) 'variance = ' num2str(var(R(:,max_theta_id)))])

figure
t = linspace(pi,4*pi-0.005)';
x1 = square(t);
x2 = x1*3;
hold on 
plot(x1)
plot(x2)


    figure 
    hold on 
    varr = var(R(:,100:170))/max(var(R(:,100:170)));
    kurt = kurtosis(R(:,100:170))/max(kurtosis(R(:,100:170)));
    plot(kurt)
    plot(varr)
    val = varr-kurt;
    plot(val/max(val))
    hold off
end