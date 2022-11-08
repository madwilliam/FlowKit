classdef LineScanFileNameHandler
   methods(Static)
       function animal_ids = get_animal_id(file_names)
           animal_id_pattern = "Pack-" + digitsPattern(6)|"PACK-" + digitsPattern(6);
           animal_ids = cellfun(@(x) extract(x,animal_id_pattern),file_names,'UniformOutput',false);
       end

       function vessel_ids = get_vessel_id(file_names)
           vessel_pattern = ("Vessel-" +digitsPattern)+'_' | ...
                ("vessel"+digitsPattern+'_')|("vessel-"+digitsPattern+'_')| ...
                ("vessel"+digitsPattern+'and'+digitsPattern+'_')|("vessel-"+digitsPattern+'and'+digitsPattern+'_')| ...
                ("Vessel"+digitsPattern+'and'+digitsPattern+'_')|("vessel_"+digitsPattern+'and'+digitsPattern+'_');
           vessel_ids = cellfun(@(x) extract(x,vessel_pattern),file_names,'UniformOutput',false);
           for i = 1:numel(vessel_ids)
               if i ==19
                   disp(i);
               end
               if ~isempty(vessel_ids{i})
                   name = vessel_ids{i}{1};
                   vessel_ids{i} = name(1:end-1);
               else
                   vessel_ids{i}='';
               end

           end
       end

       function vessel_identifiers = get_vessel_identifyer(file_names)
           date = LineScanFileNameHandler.get_date(file_names);
           vessel_ids = LineScanFileNameHandler.get_vessel_id(file_names);
           rois = LineScanFileNameHandler.get_roi(file_names);
           vessel_identifiers = cell(0);
           for i = 1:numel(vessel_ids)
                if numel(vessel_ids{i})>0
                    if contains(vessel_ids{i},'and')
                        numbers = split(vessel_ids{i},'and');
                        numbers{1} = split(numbers{1},'_');
                        numbers{1} = str2num(numbers{1}{end});
                        numbers{2} = split(numbers{2},'_');
                        numbers{2} = str2num(numbers{2}{1});
                        numbers = cell2mat(numbers);
                        roi = split(rois{i},'_');
                        roi = str2num(roi{end});
                        vessel_id = append(date{i},'_',append('vessel_',num2str(numbers(roi))));
                    else
                        vessel_id = append(date{i},'_',vessel_ids{i});
                    end
                else
                    vessel_id = date{i};
                end
                vessel_identifiers{end+1} = vessel_id;
           end
       end

       function dates = get_date(file_names)
           date_pattern = digitsPattern(2)+"-" +digitsPattern(2)+"-" +digitsPattern(2) ;
           dates = cellfun(@(x) extract(x,date_pattern),file_names);
       end

       function all_powers = get_power(file_names)
           power_pattern = digitsPattern+"-" +digitsPattern+"mW"|digitsPattern+"mW";
           powers = cellfun(@(x) extract(x,power_pattern),file_names,'UniformOutput',false);
           empty = cellfun(@isempty,powers);
           if any(empty)
               powers = powers(~empty);
           end
           powers = cellfun(@(x) x{1}(1:end-2),powers,'UniformOutput',false);
           powers = cellfun(@(x) split(x,'-'),powers,'UniformOutput',false);
           powers = cellfun(@(x) strjoin(x,'.'),powers,'UniformOutput',false);
           powers = cellfun(@str2num,powers);
           all_powers = zeros(numel(file_names),1);
           all_powers(~empty) = powers;
       end
       
       function rois = get_roi(file_names)
           roi_pattern = 'roi_'+digitsPattern;
           rois = cellfun(@(x) extract(x,roi_pattern),file_names,'UniformOutput',false);
       end
   end
end