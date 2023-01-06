function CM_PATH_ANALYSIS_PLOT_FROM_STR(STRC)

if ~isempty(STRC)
    figure;
else
    return
end
imax=size(STRC,2);
max_plot=(imax*3);
index_subplot=2:3:max_plot;

for i=1:1:imax
    
    tac=STRC{i};
    local_info=tac.dataStructArray{1,i};
    time_vector_field=[local_info.assignName '_time_axis'];
    
    if (i==1)
        [~,figure_title]=fileparts(local_info.fullFileNameMpd);

        set(gcf,'Name',figure_title,'NumberTitle','off')
        set (gcf,'position',  [200   50   1000   600]);gcf; %[left bottom width height]
        clf
        indexes=1:3:max_plot;
        
        scanData=local_info.scanData;
        imageCh=(local_info.imageCh);
        subplot(imax,3,indexes);
        scanData.im=scanData.im(:,:,imageCh);
        ColorSet=jet(size(scanData.scanCoords,2)/2);
        ColorSet=ColorSet-0.2;
        ColorSet(ColorSet<0)=0;
        try
        CM_GENERATE_IMAGE_PATH(scanData)
        axis image
        catch
        end
        titleof=local_info.assignName;
        local_fig_title=strrep(figure_title,'_','-');
        title (local_fig_title);
                axis image

    end
    local_subplot=index_subplot(i);
    oops(i)=subplot(imax,3,[local_subplot,local_subplot+1]); % takes 2 columns
    
color_index=(str2num(strrep(local_info.assignName,'line_','')));
    if strcmp(local_info.analysisType,'diameter')
        yvectorname= [local_info.assignName '_' 'ch' num2str(local_info.imageCh) '_diameter_um'];
        ylabelStr='Diameter (um)';
    elseif strcmp(local_info.analysisType,'radon')
        yvectorname= [local_info.assignName '_' 'ch' num2str(local_info.imageCh) '_radon_um_per_s'];
        ylabelStr='Velocity (um per sec)';
    else
        yvectorname= [local_info.assignName '_' 'ch' num2str(local_info.imageCh) '_Mean_int'];
        ylabelStr='Brightness (0 to 2048)';
    end
    
    plot(tac.(time_vector_field),tac.(yvectorname),'Color',ColorSet(color_index,:))
    ylabel(ylabelStr);
    titleof=local_info.assignName;
    titleof=strrep(titleof,'_','-');
    title (titleof,'Color',ColorSet(i,:));
    
end
xlabel('Time(s)')
linkaxes(oops','x');
xlim([0 tac.(time_vector_field)(end)])
%legend(legend250','location','south','box','off','Orientation','horizontal');
figure (gcf);

end



function CM_GENERATE_IMAGE_PATH(scanData)
imagesc(scanData.axisLimCol,scanData.axisLimRow,scanData.im); axis on; axis tight;colormap('gray')
CM_append_control_intensity(scanData.im)
line_counter=[];
hold on
plot (scanData.path(:,1),(scanData.path(:,2)),'Marker','.','Color',[0.8711 0.922 0.98])
ColorSet=jet((size (scanData.scanCoords,2))/2);
ColorSet=ColorSet-0.2;
ColorSet(ColorSet<0)=0;
for i=1: size (scanData.scanCoords,2)
    line_number=i;
    %     Xi = [scanData.scanCoords(line_number).startPoint(1),scanData.scanCoords(line_number).startPoint(1)];
    %     Yi = [scanData.scanCoords(line_number).startPoint(2),scanData.scanCoords(line_number).startPoint(2)];
    line_X=[scanData.scanCoords(line_number).startPoint(1),scanData.scanCoords(line_number).endPoint(1)];
    line_Y=[scanData.scanCoords(line_number).startPoint(2),scanData.scanCoords(line_number).endPoint(2)];
    number_position =[mean(line_X(:)), mean(line_Y(:)) ];
    text_name=scanData.scanCoords(line_number).name;
    
    if ~strcmp(scanData.scanCoords(i).scanShape,'pause')
        if isempty(line_counter)
            line_counter=1;
        else
            line_counter=line_counter+1;
        end
        text_name=strrep(text_name,'line_','');
        plot(line_X,line_Y,'r', 'LineWidth', 3,'Color',ColorSet(line_counter,:))
        text(number_position (1),number_position (2),[text_name],...
            'HorizontalAlignment','right',...
            'FontSize',8,'Color',ColorSet(i,:))
    end
    
end
set(gcf,'toolbar','figure');

axis image
caxis ([50,950])
end

function CM_append_control_intensity(vector)

slmax=max(max(vector));
slmin=min(min(vector));
slmean=((slmax-slmin)/2)+slmin;

hs1_append = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.01 0.01],'Value',slmean,...
    'Position',[100 20 105 20]);
hs2_append = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.01 0.01],'Value',slmean*1.1,...
    'Position',[100 0 105 20]);
%set(hsl,'Callback',@(hObject,eventdata) caxis ([round(get(hs1,'Value')),round(get(hs2_append,'Value'))]))
set(hs1_append,'Callback',@(hObject,eventdata) caxis ([min(get(hs1_append,'Value'),get(hs2_append,'Value')),max(get(hs1_append,'Value'),get(hs2_append,'Value'))]))
set(hs2_append,'Callback',@(hObject,eventdata) caxis ([min(get(hs1_append,'Value'),get(hs2_append,'Value')),max(get(hs1_append,'Value'),get(hs2_append,'Value'))]))
end