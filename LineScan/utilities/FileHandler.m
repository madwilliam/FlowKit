classdef FileHandler
   methods (Static)

       function meta_files = get_meta_files(path)
           meta_files = dir(strcat(path,'/**/*.meta.txt'));
       end

       function pmt_file = get_pmt_files(path)
           pmt_file = dir(strcat(path,'/**/*.pmt.dat'));
       end

       function config_file = get_config_files(path)
           config_file = dir(strcat(path,'/**/*.PATH.mat'));
       end

       function tif_file = get_tif_files(path)
           tif_file = dir(strcat(path,'/**/*.tif'));
       end

       function names = get_names(file_paths)
           names = strings(1,numel(file_paths));
           for i = 1:numel(file_paths)
               name = FileHandler.strip_extensions(file_paths(i).name);
               names(i) = name;
           end
       end

       function name = strip_extensions(file_name)
           [~,name,~]=fileparts(file_name);
           [~,name,~]=fileparts(name);
       end

       function file = get_file(files,file_name)
           found = false;
           for i =1:numel(files)
               name = FileHandler.strip_extensions(files(i).name);
               if strcmp(name,file_name)
                   file = files(i);
                   if found
                       disp(append('more than one file found for ',file_name))
                   else
                       found = true;
                   end
               end
           end
       end

       function [shared_experiment,meta_no_tif,tif_no_meta] = get_experiments_with_meta_and_tif(meta_files,tif_files)
           meta_names = FileHandler.get_names(meta_files);
           tif_names = FileHandler.get_names(tif_files);
           shared_experiment = intersect(meta_names,tif_names);
           meta_no_tif = setdiff(meta_names,tif_names);
           tif_no_meta = setdiff(tif_names,meta_names);
       end

       function [SI,RoiGroups] = load_meta_data(meta_files,file_name)
           meta_file = FileHandler.get_file(meta_files,file_name);
           [SI,RoiGroups] = parse_scan_image_meta(fullfile(meta_file.folder, meta_file.name));
       end

       function image = load_image_data(tif_files,file_name)
           tif_file = FileHandler.get_file(tif_files,file_name);
           t = Tiff(fullfile(tif_file.folder, tif_file.name),'r');
           image = read(t);
           if size(image,1)>size(image,2)
               image=image';
           end
       end

       function stimulus = load_stimulus(pmt_files,file_name)
           pmt_file = FileHandler.get_file(pmt_files,file_name);
           fid=fopen([pmt_file.folder '\' pmt_file.name],'r');
           M=fread(fid,'int16=>int16');
           stimulus=M(2:2:end);
           stimulus=int16(stimulus);
       end

       function pmt = load_pmt_file(file_name,npixels,nchannels,channeli)
           file_info=dir(file_name);
           size = [npixels,(file_info.bytes/(2*npixels))];
           fid=fopen(file_name, 'r' );
           fseek(fid,(channeli-1)*2,-1);
           pmt=fread(fid,size,'*int16',(nchannels-1)*2);
           pmt=im2uint16(pmt);
       end

       function pmt = load_pmt_file_full(pmt_file,npixels,channels)
           file_name = fullfile(pmt_file.folder, pmt_file.name);
           file_info=dir(file_name);
           size = [npixels,(file_info.bytes/(2*npixels))];
           A=fopen(file_name, 'r' );
           pmt=fread(A,size,'*int16');
           pmt = pmt(1:channels-1:end);
           pmt=im2uint16(pmt);
       end

       function answer = read_from_end(meta_path)
           meta_text=readtable(meta_path ,'Delimiter','=');
           pauseFunctionsRow=find(contains(meta_text.Var1,'stimulusfunctions.pause')==1);
           lineFunctionsRow=find(contains(meta_text.Var1,'scanimage.mroi.stimulusfunctions.line')==1);
           answer = pauseFunctionsRow < lineFunctionsRow;
       end
       
       function uncropped_tiffs = get_uncropped_tifs(meta_files,tif_files,pmt_files)
           meta_names = FileHandler.get_names(meta_files);
           tiff_names = FileHandler.get_names(tif_files);
           pmt_names = FileHandler.get_names(pmt_files);
           meta_and_pmt = intersect(meta_names,pmt_names);
           uncropped_tiffs = setdiff(meta_and_pmt,tiff_names);
       end

   end
end