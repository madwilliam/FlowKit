function [angle,theta,R_value] = hybrid_radon(data,showimg,saveimg,dx,dt,image_height,line_step_size,xrange)
    function [image_width,imgtitle] = parse_arguments()
        imsize = size(data);
        data = double(data);
        if exist('showimg','var') && ~isempty(showimg) && showimg, showimg = 1; else showimg = 0; end
        if exist('saveimg','var') && ~isempty(saveimg) && saveimg, saveimg = 1; showimg = 1; else saveimg = 0; end
        if exist('dx','var') && ~isempty(dx) && dx, else dx = 1; end
        if exist('dt','var') && ~isempty(dt) && dt, else dt = 1; end
        if exist('segment_height','var') && ~isempty(image_height) && image_height, else image_height = imsize(1)-2; end
        if exist('lineskip','var') && ~isempty(line_step_size) && line_step_size, else line_step_size = image_height; end
        if exist('xrange','var') && ~isempty(xrange) && length(xrange)<3
        if length(xrange)==1
            image_width = xrange; xrange = [1 image_width];
        else
            if xrange(1)>imsize(2)-1
                xrange(1)=1;
            end
            if xrange(2)>imsize(2)-1
                xrange(2)=imsize(2)-2;
            end
            if xrange(2)<xrange(1)
                xrange = [xrange(1) xrange(2)];
            end
            image_width = xrange(2)-xrange(1)+1;
        end
        else
            image_width = imsize(2)-2; xrange = [1 image_width];
        end
        if showimg
            imgtitle = {inputname(1);['HybridVel-' datestr(now,30)]};
        end
    end
    function show_image()
        figure(1496);
        % linescan plot with angle
        subplot(1,nmodality*2,modalityi+nmodality);
        imagesc(image(:,:,modalityi)); axis image; title(image_title{modalityi});
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        hold on;
        for segmenti=1:nsegments
        [xp,yp] = pol2cart(mod(angle(segmenti,1,modalityi)*pi/180-pi/2,pi),image_width/2);
        line(xrange(1)+image_width/2+[-xp xp],angle(segmenti,3,modalityi)-[-yp yp],'Color','black','LineWidth',anglineth,'EraseMode','xor');
        end
        hold off;
        if modalityi==1
            ylabel({'processed image';...
                ['\Deltax = ' num2str(dx) ' \mum/pixel' ', \Deltat = ' num2str(dt) ...
                ' ms/line, h = ' num2str(npixel) ' pixels']});
            xlabel(['w = ' num2str(nsample)]);
        end
        % angle plot
        subplot(2,nmodality*2,+(1:nmodality))
        plot(angle(:,3,modalityi)*dt,angle(:,1,modalityi),['-o' plot_color{modalityi} ]); hold on;
        if modalityi==nmodality
            legend(image_title{1:modalityi}); 
            xlabel('time (ms)'); ylabel('\theta (^o)'); hold off
            title (imgtitle);
        end
        % velocity plot
        subplot(2,nmodality*2,nmodality*2+(1:nmodality))
        plot(angle(:,3,modalityi)*dt,angle(:,9,modalityi),['-o' plot_color{modalityi} ]); hold on;
        if modalityi==nmodality
            legend(image_title{1:modalityi}); 
            xlabel('time (ms)'); ylabel('v (mm/s)'); hold off
        end
        if saveimg && modalityi==nmodality
            savepath = 'D:\lab stuff\savedRadonImages\';
            saveas(gca,fullfile(savepath,['hybridvel' strcat(imgtitle{:}) 'img' num2str(modalityi) '.eps']), 'psc2');
            saveas(gca,fullfile(savepath,['hybridvel' strcat(imgtitle{:}) 'img' num2str(modalityi) '.fig']));
            saveas(gca,fullfile(savepath,['hybridvel' strcat(imgtitle{:}) 'img' num2str(modalityi) '.jpg']));
            saveas(gca,fullfile(savepath,['hybridvel' strcat(imgtitle{:}) 'img' num2str(modalityi) '.ai']));
        end
    end
    function angular_resolution_lower_limit = get_angular_resolution_limit()
        streak_width = min(image_width,ceil(image_height*abs(tand(current_max_angle))));
        streak_height = min(image_height,ceil(image_width*abs(cotd(current_max_angle)))); % Eq. 14
        max_number_of_streaks = floor(image_width*dx/min_streak_distance)*(streak_height==image_height)+((image_height*dx*streak_width)/(min_streak_distance*streak_height))*(streak_width==image_width); % Eq. 13
        single_streak_angular_resolution = abs(atand(streak_width/streak_height)-atand((streak_width-1)/streak_height)*(streak_width>streak_height)-atand(streak_width/(streak_height-1))*(streak_width<=streak_height)); % Eq. 12
        angular_resolution_lower_limit = single_streak_angular_resolution/max_number_of_streaks; % Eq. 11
    end
    anglineth = .1; 
    dvov = 0.1/100; % dv/v to determine minimum step-size
    rough_theta_step_size = 45; theta_start_and_stop = [0 179];
    min_streak_distance = 100; % 4 um streak distance
    [image_width,imgtitle] = parse_arguments();
    image_title = {'edm','vdm','sob'}; plot_color = {'b','g','k','r','c','m'};
    image(:,:,1) = data(2:end-1,2:end-1)-mean(mean(data(2:end-1,2:end-1))); % subtract mean pixel intensity
    image(:,:,2) = bsxfun(@minus,data(2:end-1,2:end-1),mean(data(2:end-1,2:end-1),1)); % subtract time average
    image(:,:,3) = filter2([1 2 1; 0 0 0; -1 -2 -1],data,'valid');  % 3x3 vertical Sobel filter, Eq. 5,6
    [npixel,nsample,nmodality] = size(image);
    theta_steps = (theta_start_and_stop(1):rough_theta_step_size:theta_start_and_stop(2));
    theta_steps = theta_steps-(theta_steps(end)-theta_steps(1))/2+1;
    segend = image_height:line_step_size:npixel;
    segstart = segend-image_height+1;
    nsegments = length(segstart);
    angle = nan(nsegments,9,nmodality); 
    theta = cell(nsegments,nmodality); 
    R_value = cell(nsegments,nmodality);
    for modalityi = 1:nmodality
        for segmenti = 1:nsegments
            iterative_radon_level = 1; % iterative radon level
            current_max_angle = 0; alltheta = []; allvar = []; iter = 0; theta_step_size = rough_theta_step_size; current_max_R = 0;
            data_chunk = image(xrange(1):xrange(2),segstart(segmenti):segend(segmenti),modalityi);
            if modalityi==1
                data_chunk = data_chunk-mean(data_chunk(:)); % element-wise demean
            end
            if modalityi==2
                data_chunk = bsxfun(@minus,data_chunk,mean(data_chunk,1)); % vertical demean
            end
            while True
                iter = iter+1;
                if iter==1
                    theta = theta_steps;
                else
                    theta_step_size = theta_step_size/2;
                    theta = (-3*theta_step_size+current_max_angle):theta_step_size*2:(3*theta_step_size+current_max_angle);
                end
                theta = mod(theta+90,180)-90; % ensures angle range of [-90,+90)
                R = radon(data_chunk,theta); % Eq. 7
                R(R==0) = nan; % avoids influence of non-participant pixels
                curvar = nanvar(R);
                alltheta = [alltheta theta];
                allvar = [allvar curvar];
                [max_R,max_R_id] = max(curvar);
                if max_R>current_max_R
                    current_max_angle = theta(max_R_id); % Eq. 8
                    current_max_R = max_R;
                end
                angular_resolution_lower_limit = get_angular_resolution_limit();
                if theta_step_size<1 % angle resolution less than 1 deg
                    angular_resolution = abs(atand((dvov+1)*tand(current_max_angle))-current_max_angle); % Eq. 17
                    if theta_step_size<angular_resolution % Eq. 17
                        current_dvov = abs(tand(theta_step_size+current_max_angle)/tand(current_max_angle)-1)*100; % Eq. 16
                        if dvov>current_dvov/100
                            break
                        end
                    end
                else
                if theta_step_size<angular_resolution_lower_limit
                    break
                end
                end
            end
            current_dvov = abs(tand(theta_step_size+current_max_angle)/tand(current_max_angle)-1)*100; % Eq. 16
            angle(segmenti,:,modalityi) = [current_max_angle theta_step_size segstart(segmenti)+image_height/2 single_streak_angular_resolution angular_resolution_lower_limit current_dvov iter iterative_radon_level tand(current_max_angle)*dx/dt];
            [theta{segmenti,modalityi},sort_id] = sort(alltheta);
            R_value{segmenti,modalityi} = allvar(sort_id);
        end
        if showimg
            show_image()
        end    
end