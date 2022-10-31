classdef CSVTools
   methods(Static)
       function cell2csv(all_data,csv_path)
            max_length = max(cellfun(@numel,all_data));
            ncol = numel(all_data);
            for i = 1:ncol
                data = all_data{i};
                if i==1
                    dlmwrite(csv_path,data,'delimiter',',');
                else
                    dlmwrite(csv_path,data,'delimiter',',','-append');
                end
            end
       end
   end
end