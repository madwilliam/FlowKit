function plot_diagnostic(data_chunk,chunk_size)
    angles = 1:179;
%     processed_data_chunk = preprocess_data(data_chunk);
    [R,radius]=radon(data_chunk,angles);
%     result=get_slope_from_line_scan(data_chunk,size(data_chunk,2),@two_step_radon);
    result=get_slope_from_line_scan(data_chunk,size(data_chunk,2),@max_and_variance_radon);
    theta = mod(floor(atand(1/result.slopes))+180,180);
    [~,max_theta_id] = min(abs(angles-theta));
    [~,max_radius_id] = max(R(:,max_theta_id));
    max_R_id = [max_radius_id,theta];
    nplot = 3; 
    figure
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    ax3 = subplot(nplot, 1,3);
    if ~isnan(result.slopes)
        [~,intercept] = RadonTools.get_slope_and_intercept(radius(max_radius_id),angles(theta),size(data_chunk));
        Plotter.plot_line(data_chunk,1:size(data_chunk,2),result.slopes,intercept,ax1)
        Plotter.plot_radon(R,flip(max_R_id),ax2)
        plot(ax3,R(:,max_theta_id))
        title(ax3,['kurtosis = ' num2str(kurtosis(R(:,max_theta_id))) 'var = ' num2str(var(R(:,max_theta_id)))])
    else
        imagesc(ax1,data_chunk)
        imagesc(ax2,R)
        plot(ax3,var(R),'color','r')
        plot(ax3,max(R),'color','b')
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
    title(ax1,['slope = ' num2str(slope)])
    end
end