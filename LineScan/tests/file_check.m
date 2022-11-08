nfiles = numel(mat_files);
% duration = [];
for i=1:nfiles
    filei = mat_files(i);
    file_name = FileHandler.strip_extensions(filei.name);
    mat_path = FileHandler.get_file_path(mat_files,file_name);
    load(mat_path,'start_time','end_time','dt_ms');
    nmtim = numel(start_time);
     for stimi = 1: nstimulus
         dura = (end_time(stimi)-start_time(stimi))*dt_ms;
         if dura==0
             dura = dt_ms;
         end
         if dura<0.5
             disp(file_name)
             disp(dt_ms)
             disp(dura)
         end
%              duration = [duration dura];
     end
end
%%
figure 
histogram(duration,20)


to_plot= arrayfun(@(x) x>900 && x<1500,duration);
figure 
histogram(duration(to_plot),20)
1000/  0.2240

figure 
histogram(duration(duration<500),20)

figure 
histogram(duration(duration<0.5),20)