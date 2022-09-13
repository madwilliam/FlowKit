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
           for i =1:numel(files)
               name = FileHandler.strip_extensions(files(i).name);
               if strcmp(name,file_name)
                   file = files(i);
                   break
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
           [SI,RoiGroups] = parse_scan_image_meta([meta_file.folder '\' meta_file.name]);
       end
       function image = load_image_data(tif_files,file_name)
           tif_file = FileHandler.get_file(tif_files,file_name);
           t = Tiff([tif_file.folder '\' tif_file.name],'r');
           image = read(t);
           if size(image,1)>size(image,2)
               image=image';
           end
       end

   end
end