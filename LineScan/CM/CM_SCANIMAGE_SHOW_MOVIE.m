
function [rgbImage2,montage_im_AVG_PROJ]=CM_SCANIMAGE_SHOW_MOVIE  (full_name,AON,SON,SON_AVG,SHON,SHON_AVG,RGB_CODE)
% AON : average or not
% SON : save or not
% SON_AVG : save or not the AVG
% SHON : show or not
% SHON_AVG : show or not the average
% RGB_CODE : for example [3 2 1 4] for the set up channel 3 is red/2 green/ 1/blue

% find the file
rgbImage2=0;
montage_im_AVG_PROJ=0;
if isempty (full_name)
[Filename , Pathname]=uigetfile('*.tif');[Pathname Filename];
else
[Pathname , Filename, ext]=fileparts(full_name);
Pathname=[Pathname '/'];
Filename=[Filename  ext];
end
if isempty(Filename)
    return
end
tic
if (SON) % prepares the folder to save the tiffs out
    [~,name,~] = fileparts(Filename);
    resDir = [Pathname 'Tiffs\'];
    if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it
    saving_tiff_name=[resDir name];
end

% opens the file with scanimage util to get the header
[header,~,~] = scanimage_opentif_all([Pathname Filename]);
numSlices=header.SI.hStackManager.numSlices;
framesPerSlice=header.SI.hStackManager.framesPerSlice;
channel_order=header.SI.hChannels.channelSave;

% Creates object
tiffob=tiffMap ([Pathname Filename]); % Creates image object
nb_Channel=tiffob.framesize(3);
numframes=tiffob.numframes;
montage_im=zeros(tiffob.framesize(1),tiffob.framesize(2)*nb_Channel);% Initialize image frame

% Establish the stack pattern
if (header.SI.hStackManager.numSlices)==1 % This is not a stack
    AON=0;% no average
    nb_of_show=numframes;
else
    if (AON==1)
        nb_of_show=numSlices; % shows only the averages
    else
        nb_of_show=numframes; % shows all frames
    end
end
if framesPerSlice==1 && AON;AON=0;end % nothing to average if there is only one frame per slice

pause_time=1/nb_of_show; % to keep the read time constant regardless of the size of the file

if SHON
    figure('position',[50,80,1200,600]) % Set up the figure
    set(gcf,'color','k');
end

average_counter=0;
first_image_to_save=0;


% FRAME PER FRAME START
stk=tiffob([1 2 3],tiffob.numframes);

for i=1:1:tiffob.numframes %% goes through frames    
    if nb_Channel>1
        for ch_counter=1:1:nb_Channel % ltiffob through the channels to make the montage
            montage_im(:,((ch_counter-1)*tiffob.framesize(2))+1:ch_counter*tiffob.framesize(2))=tiffob(ch_counter,i);
        end
    else
        montage_im=tiffob(1,i); % only one channel
    end
    
    if (i==1)
        montage_im_AVG_PROJ=single(montage_im)/tiffob.numframes;% initialisation of the avg
    else
        montage_im_AVG_PROJ=montage_im_AVG_PROJ+single(montage_im)/tiffob.numframes; % append to AVG
    end
    
    if framesPerSlice>1 && AON % averages the repetited planes
        if average_counter==0
            plane_AVG=single(montage_im); % initialize slice frame avg
        else
            plane_AVG=single(plane_AVG+single(montage_im)); % append to slice frame avg
        end
        average_counter=average_counter+1;
    end
    
    if mod(i,framesPerSlice)==0 && framesPerSlice>1 % when we get at the end of a slice
        first_image_to_save=first_image_to_save+1;
        plane_AVG=plane_AVG/framesPerSlice ;
        if (SHON) % to display
            imagesc(plane_AVG);axis image
            axis image;colormap ('gray');caxis ([-100 2000])
        end
        average_counter=0;
    end
    
    if AON==0 % show all frames
        first_image_to_save=first_image_to_save+1;
        average_counter=0;
        if SHON;imagesc(montage_im);axis image;colormap ('gray');caxis ([-100 2000]);end
    end
    
    if (SON && average_counter==0) % allows to save only the local slice frame average
        if(AON==1)
            for ch_counter=1:1:nb_Channel
                if(first_image_to_save)==1
                    current_frame=plane_AVG(:,((ch_counter-1)*tiffob.framesize(2))+1:ch_counter*tiffob.framesize(2));
                    current_frame=uint16(round(current_frame+3000));
                    imwrite(current_frame,[saving_tiff_name '_Ch_' num2str(channel_order(ch_counter)) '.tiff'],'tiff','Compression','none');
                else
                    current_frame=plane_AVG(:,((ch_counter-1)*tiffob.framesize(2))+1:ch_counter*tiffob.framesize(2));
                    current_frame=uint16(round(current_frame+3000));
                    imwrite(current_frame,[saving_tiff_name '_Ch_' num2str(channel_order(ch_counter)) '.tiff'],'tiff','WriteMode','append','Compression','none');
                end
            end
        else
            for ch_counter=1:1:nb_Channel
                if(first_image_to_save)==1
                    current_frame=tiffob(ch_counter,1);
                    current_frame=uint16(round(current_frame+3000));
                    imwrite(current_frame,[saving_tiff_name '_Ch_' num2str(channel_order(ch_counter)) '.tiff'],'tiff','Compression','none');
                else
                    current_frame=tiffob(ch_counter,i);
                    current_frame=uint16(round(current_frame+3000));
                    imwrite(current_frame,[saving_tiff_name '_Ch_' num2str(channel_order(ch_counter)) '.tiff'],'tiff','WriteMode','append','Compression','none');
                    
                end
            end
        end
    end
    
    if (SHON)
        figure (gcf)
        pause (pause_time)
    end
end

% FRAME PER FRAME START

if SHON_AVG
    % Shows the average
    figure('position',[50,80,1200,600])
    set(gcf,'color','k');
    imagesc([montage_im_AVG_PROJ]);axis image
    axis image;colormap ('gray');%caxis ([-100 2000])
    figure (gcf)
    
    for ch_counter=1:1:nb_Channel
        temp_im =montage_im_AVG_PROJ(:,((ch_counter-1)*tiffob.framesize(2))+1:ch_counter*tiffob.framesize(2));
        if (SON_AVG) 
            imwrite(uint16(round(temp_im+3000)),[resDir 'AVG_' name '_Ch_' num2str(channel_order(ch_counter)) '.tiff'],'Compression','none');
        end
        temp_im=temp_im-min(temp_im(:));
        temp_im=temp_im/max(temp_im(:));
        rgbImage (:,:,ch_counter)=temp_im;
    end
    if (nb_Channel>2)
        rgbImage2 = cat(3, rgbImage(:, :, RGB_CODE(1)), rgbImage(:, :, RGB_CODE(2)), rgbImage(:, :, RGB_CODE(3)));
        figure;
        set(gcf,'color','k');
        imshow (rgbImage2)
        
        if (SON_AVG)
            imwrite(rgbImage2,[resDir 'COMPOSITE_' name '.png'],'Compression','none');
        end
    end
    
end
toc
end

