classdef WekaAnnalyzer
   methods(Static)
       function grouped_result = group_results_by_stimulation(all_results)
            stimulations = unique([all_results.duration_ms]);
            grouped_result = {};
            for i = stimulations
                is_stimulationi = [all_results.duration_ms]==i;
                stimi_result = all_results(is_stimulationi);
                grouped_result{end+1} = stimi_result;
            end
       end

       function [stimi_result,all_file_info] = get_result_of_stimulationi(all_results,stimulationi)
            is_stimulationi = [all_results.duration_ms]==stimulationi;
            stimi_result = all_results(is_stimulationi);
            all_file_info = WekaPlotter.organize_file_information(stimi_result);
       end

       function [p,tbl,stats] = population_annova_per_trace(all_results)
            stimulations = unique([all_results.duration_ms]);
            all_delta = cell(numel(stimulations),1);
            anaova_deltas = [];
            anaova_groups = [];
            i=1;
            for stimi = stimulations
                is_stimulationi = [all_results.duration_ms]==stimi;
                group = ones(sum(is_stimulationi),1)*i;
                stimi_result = all_results(is_stimulationi);
                all_file_info = WekaPlotter.organize_file_information(stimi_result);
                delta = [stimi_result.delta_mean];
                all_delta{i} = delta;
                if size(delta,2)>1
                    delta = delta';
                end
                anaova_deltas = [anaova_deltas delta'];
                anaova_groups = [anaova_groups group'];
                i=i+1;
            end
            [p,tbl,stats] = anova1(anaova_deltas,anaova_groups);
       end

       function all_delta = group_delta_by_stimulation(all_results)
            grouped_result = WekaAnnalyzer.group_results_by_stimulation(all_results);
            all_delta = cellfun(@(x)[x.delta_mean],grouped_result,'UniformOutput',false);
       end

       function [p,tbl,stats] = population_annova_per_vessel(all_results)
           ...
       end

       function all_delta = get_mean_delta_per_vessel(all_results)
            stimulations = unique([all_results.duration_ms]);
            all_delta = {};
            i=1;
            for stimi = stimulations
                all_delta{i}=[];
                is_stimulationi = [all_results.duration_ms]==stimi;
                stimi_result = all_results(is_stimulationi);
                file_info = WekaPlotter.organize_file_information(stimi_result);
                vessels = unique({file_info.vessel_id});
                for vesseli = vessels
                    is_vesseli = arrayfun(@(x) strcmp(x.vessel_id,vesseli),file_info);
                    vessel_result = stimi_result(is_vesseli);
                    vessel_info = file_info(is_vesseli);
                    delta = [vessel_result.delta_mean];
                    all_delta{i} = [all_delta{i} mean(delta)];
                end
                i=i+1;
            end
       end

       function [p,tbl,stats] = uneven_annova(data)
            anaova_deltas = [];
            anaova_groups = [];
            ngroups = numel(data);
            for i = 1:ngroups
                delta = data{i};
                group = ones(1,numel(delta))*i;
                anaova_deltas = [anaova_deltas delta];
                anaova_groups = [anaova_groups group];
            end
            [p,tbl,stats] = anova1(anaova_deltas,anaova_groups);
       end
   end
end