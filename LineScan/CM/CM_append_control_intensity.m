function CM_append_control_intensity(vector)

slmax=max(max(vector));
slmin=min(min(vector));
slmean=(slmax-slmin)/2;

hs1_append = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[0.01 0.01],'Value',slmean,...
                'Position',[100 20 105 20]);
hs2_append = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[0.01 0.01],'Value',slmean*1.1,...
                'Position',[100 0 105 20]);
%set(hsl,'Callback',@(hObject,eventdata) caxis ([round(get(hs1,'Value')),round(get(hs2_append,'Value'))])) 
set(hs1_append,'Callback',@(hObject,eventdata) caxis ([min(get(hs1_append,'Value'),get(hs2_append,'Value')),max(get(hs1_append,'Value'),get(hs2_append,'Value'))]))
set(hs2_append,'Callback',@(hObject,eventdata) caxis ([min(get(hs1_append,'Value'),get(hs2_append,'Value')),max(get(hs1_append,'Value'),get(hs2_append,'Value'))]))

     set(gcf,'toolbar','figure');


end