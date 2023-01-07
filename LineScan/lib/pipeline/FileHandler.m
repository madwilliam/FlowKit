classdef FileHandler
   methods (Static)

       function meta_files = get_meta_files(path)
           meta_files = dir(strcat(path,'/**/*.meta.txt'));
       end

       function common_names = find_experiment_names_in_folder(directory)
            mat_files = FileHandler.get_mat_files(directory);
            pmt_files = FileHandler.get_pmt_files(directory);
            meta_files = FileHandler.get_meta_files(directory);
            mat_names = {mat_files.name};
            mat_names = cellfun(@FileHandler.strip_extensions,mat_names,'UniformOutput',false);
            mat_names = cellfun(@(x) x(1:end-5),mat_names,'UniformOutput',false);
            pmt_names = {pmt_files.name};
            meta_names = {meta_files.name};
            meta_names = cellfun(@FileHandler.strip_extensions,meta_names,'UniformOutput',false);
            pmt_names = cellfun(@FileHandler.strip_extensions,pmt_names,'UniformOutput',false);
            common_names = intersect( mat_names,pmt_names);
            common_names = intersect( common_names,meta_names);
       end

       function common_names = find_experiment_names_in_analysis_folder(directory)
            mat_files = FileHandler.get_mat_files(directory);
            tif_files = FileHandler.get_tif_files(directory);
            mat_names = {mat_files.name};
            mat_names = cellfun(@FileHandler.strip_extensions,mat_names,'UniformOutput',false);
            tif_names = {tif_files.name};
            tif_names = cellfun(@FileHandler.strip_extensions,tif_names,'UniformOutput',false);
            common_names = intersect( mat_names,tif_names);
       end

       function pmt_file = get_pmt_files(path)
           pmt_file = dir(strcat(path,'/**/*.pmt.dat'));
       end

       function config_file = get_config_files(path)
           config_file = dir(strcat(path,'/**/*.PATH.mat'));
       end

       function names = get_pmt_or_mat_names(files)
           names = {files.name};
           names = cellfun(@FileHandler.strip_extensions,names,'UniformOutput',false);
           names = cellfun(@(x) x(1:end-5),names,'UniformOutput',false);
       end

       function names = get_meta_tif_or_pmt_names(files)
            names = {files.name};
            names = cellfun(@FileHandler.strip_extensions,names,'UniformOutput',false);
       end

       function path_files  = get_path_files(folder)
           path_files = dir(fullfile(folder,'**','*PATH.mat'));
       end

       function [file_function,name_function] = file_type_to_functions(type)
            if strcmp(type,'mat')
                file_function = @FileHandler.get_mat_files;
                name_function = @FileHandler.get_pmt_or_mat_names;
            elseif strcmp(type,'tif')
                file_function = @FileHandler.get_tif_files;
                name_function = @FileHandler.get_meta_tif_or_pmt_names;
            elseif strcmp(type,'pmt')
                 file_function = @FileHandler.get_pmt_files;
                 name_function = @FileHandler.get_meta_tif_or_pmt_names;
            elseif strcmp(type,'meta')
                 file_function = @FileHandler.get_meta_files;
                 name_function = @FileHandler.get_meta_tif_or_pmt_names;
            elseif strcmp(type,'path')
                 file_function = @FileHandler.get_path_files;
                 name_function = @FileHandler.get_pmt_or_mat_names;
            end
       end

       function [common_names,all_files]=find_common_names(types,folder)
           ntypes = numel(types);
           all_files = cell(ntypes,1);
           for i = 1:ntypes
               [file_function,name_function] = FileHandler.file_type_to_functions(types{i});
               files = file_function(folder);
               all_files{i} = files;
               names = name_function(files);
               if i ==i
                   common_names = names;
               else
                   common_names = intersect( common_names,names);
               end
           end
       end
       
       function path = file_to_path(file)
           path = fullfile(file.folder,file.name);
       end

       function tif_file = get_tif_files(path)
           tif_file = dir(strcat(path,'/**/*.tif'));
       end

       function mat_file = get_mat_files(path)
           mat_file = dir(strcat(path,'/**/*.mat'));
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
               if contains(name,file_name)
                   file = files(i);
                   if found
                       disp(append('more than one file found for ',file_name))
                   else
                       found = true;
                   end
               end
           end
       end
       
       function file_path = get_file_path(files,file_name)
           file = FileHandler.get_file(files,file_name);
           file_path = fullfile(file.folder, file.name);
       end

       function [shared_experiment,type1_no_2,type2_no_1] = get_shared_experiments(filetype1,filetype2)
           names1 = FileHandler.get_names(filetype1);
           names2 = FileHandler.get_names(filetype2);
           shared_experiment = intersect(names1,names2);
           type1_no_2 = setdiff(names1,names2);
           type2_no_1 = setdiff(names2,names1);
       end

       function [SI,RoiGroups] = load_meta_data(meta_file)
           [SI,RoiGroups] = parse_scan_image_meta(meta_file);
       end

       function image = load_image_data(tif_file)
           t = Tiff(tif_file,'r');
           image = read(t);
           if size(image,1)>size(image,2)
               image=image';
           end
       end

       function [height,width] = get_image_size(tif_file)
            info = imfinfo(tif_file);
            height = info.Height;
            width = info.Width;
       end

       function pmt = load_pmt_file(file_name,npixels,nchannels,channeli)
           file_info=dir(file_name);
           size = [npixels,(file_info.bytes/(2*npixels))];
           fid=fopen(file_name, 'r' );
           fseek(fid,(channeli-1)*2,-1);
           pmt=fread(fid,size,'*int16',(nchannels-1)*2);
       end

       function pmt = load_pmt(pmt_path,meta_path)
            [SI,~] = parse_scan_image_meta(meta_path);
            total_pixels = SI.hScan2D.lineScanSamplesPerFrame;
            n_channels = numel(SI.hChannels.channelSave);
            pmt = FileHandler.load_pmt_file(pmt_path,total_pixels,n_channels,1);
       end

      function stimulus = load_stimulus(pmt_files,file_name)
           pmt_file = FileHandler.get_file_path(pmt_files,file_name);
           fid=fopen(pmt_file,'r');
           M=fread(fid,'int16=>int16');
           stimulus=M(1:2:end);
           stimulus=int16(stimulus);
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