function plot_diagnostic(data_chunk)
    angles = 1:179;
    result = single_chunk_radon(data_chunk,@double_max_radon);
    preprocessed = preprocess_data(data_chunk);
    [R,radius]=radon(preprocessed,angles);
    theta = mod(floor(atand(1/result.slopes))+180,180);
    [~,max_theta_id] = min(abs(angles-theta));
    [~,max_radius_id] = max(R(:,max_theta_id));
    max_R_id = [max_radius_id,theta];
    nplot = 3; 
    figure
    ax1 = subplot(nplot, 1,1);
%     ax4 = subplot(nplot, 2,2);
    ax2 = subplot(nplot, 1,2);
    ax3 = subplot(nplot, 1,3);
    if ~isnan(result.slopes)
        [~,intercept] = RadonTools.get_slope_intercept_and_location(radius(max_radius_id),angles(theta),size(preprocessed));
        RadonBackPlotter.plot_line(preprocessed,1:size(preprocessed,2),result.slopes,intercept,ax1)
%         RadonBackPlotter.plot_line(data_chunk,1:size(preprocessed,2),result.slopes,intercept,ax4)
        RadonBackPlotter.plot_radon(R,flip(max_R_id),ax2)
        plot(ax3,R(:,max_theta_id))
        title(ax3,['kurtosis = ' num2str(kurtosis(R(:,max_theta_id))) 'var = ' num2str(var(R(:,max_theta_id)))])
    else
        imagesc(ax1,preprocessed)
        imagesc(ax2,R)
        plot(ax3,var(R),'color','r')
        plot(ax3,max(R),'color','b')
    end
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
%     set(ax4,'YDir','normal')
    title(ax1,['slope = ' num2str(result.slopes)])
end