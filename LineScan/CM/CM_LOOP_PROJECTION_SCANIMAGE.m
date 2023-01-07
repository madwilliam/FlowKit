function files_to_open=CM_LOOP_PROJECTION_SCANIMAGE(files_to_open)

files_to_open= uipickfiles ('REFilter','\.tif');
for file_counter=1:1:length(files_to_open)
    lname_full=files_to_open{file_counter};
    
    if(~isempty(strfind(lname_full,'.tif')))||(~isempty(strfind(lname_full,'.TIF')))
        [A,B,C]=fileparts (lname_full);
        [rgbImage2,montage_im_AVG_PROJ]=CM_SCANIMAGE_SHOW_MOVIE(lname_full,1,1,1,0,1,[3 2 1 4]);
        HyperProjStack(file_counter).rgbImage2=rgbImage2;
        HyperProjStack(file_counter).montage_im_AVG_PROJ=montage_im_AVG_PROJ;
        HyperProjStack(file_counter).fname=lname_full;
               
        keep5('files_to_open','file_counter','HyperProjStack')
        pause (2)
        
    end
    
    
end
figure('name','ALL_PROJ');
nb_graph=size(HyperProjStack,2);
for file_counter=1:1:nb_graph
    subplot(ceil(nb_graph)/2,2,file_counter)
    imagesc(HyperProjStack(1,file_counter).rgbImage2)
    axis image
    set(gca,'fontsize',8)
    title (['MEAN ' HyperProjStack(file_counter).fname],'fontsize',8)
end

figure (gcf)
end


