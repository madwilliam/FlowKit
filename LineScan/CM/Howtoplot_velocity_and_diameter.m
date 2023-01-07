% 20181009 CM
%% PART TO EDIT 

OUT_STRUCTURE=OUT_ARB_IX10_00001; % OUT_STRUCTURE containing the data analysed
line_name='line_1'; % name of the line used for velocity
channel_name='ch3'; % name of the imaging channel used for imaging flow
line_name_dia='line_2';
channel_name='ch3';
diam_index=2;
vel_index=1;
time_start=0; % average will be calculated between the tiume start and time end in sec
time_end=19;
filtering_points=50;% number of points to use to median filter the velocity
filtering_points_diameter=filtering_points;% number of points to use to median filter the diameter

%%
figure
subplot (3,1,1)
Velocity=OUT_STRUCTURE{1,vel_index}.([line_name '_' channel_name '_radon_um_per_s']);
Time_axis_Vel=OUT_STRUCTURE{1,vel_index}.([line_name '_time_axis']);

plot(Time_axis_Vel,abs(Velocity),'r');hold on
plot(Time_axis_Vel,abs(medfilt1(Velocity,filtering_points)),'k');
ylabel ('um/sec')
xlabel ('Time (sec)')

xvector=Time_axis_Vel;
yvector=abs(medfilt1(Velocity,filtering_points));
point_start=find (xvector>time_start);
point_start=point_start(1);
point_end=find (xvector<time_end);
point_end=point_end(end);
Average_yvector_Vel=mean(yvector(point_start:point_end));
title (['Mean Velocity is : ' num2str(Average_yvector_Vel) 'um/s between sec ' num2str(time_start) '-' num2str(time_end)]);

subplot (3,1,2)
plot(Time_axis_Vel,abs(medfilt1(Velocity,filtering_points)),'k');
ylabel ('um/sec')
xlabel ('Time (sec)')
subplot (3,1,3)
Diameter=OUT_STRUCTURE{1,diam_index}.([line_name_dia '_' channel_name '_diameter_um']);
Time_axis_dia=OUT_STRUCTURE{1,diam_index}.([line_name_dia '_time_axis']);
plot(Time_axis_dia,Diameter,'g');
hold on
plot (Time_axis_dia,medfilt1(Diameter,filtering_points_diameter),'k')
ylabel ('um')
xlabel ('Time (sec)')

xvector=Time_axis_dia;
yvector=(medfilt1(Diameter,filtering_points_diameter));
point_start=find (xvector>time_start);
point_start=point_start(1);
point_end=find (xvector<time_end);
point_end=point_end(end);
Average_yvector_Dia=mean(yvector(point_start:point_end));
title (['Mean Diameter is : ' num2str(Average_yvector_Dia) 'um between sec ' num2str(time_start) '-' num2str(time_end)]);

%%

