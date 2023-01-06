

% called by CM_loop
% ALLOWS TO EXTRACT STRUCTURE FROM FILES DUMP THEM INTO THE GLOBAL
% WORKSPACE AFTER RENAMING THEM ACCORDING TO THE NAME OF THE FILE
% The heavy programming comes from a problem in extracting field of a
% structure directly from the file

%example [path_to_use short_path_to_use]=CM_loop_the_data_out_of_STRUCTURE_analog('\.ANALOG.mat','COH_Str_BAND_GAMMA_30_80','.LFP_sig','LFP_BAND_GAMMA_30_80','')
% inputs
% STRUCTURE_name string of the structure (or variable if structure_part is
% empty
% structure_part string starting with a dot and followed by the name of a
% field; it can be left empty if the extraction is done on a variable
% short_vector_name: string to assign the name of the extracted variable
% called or not : if ==1 path_STR will be used to define the path_to_use
% this function can easily run out of memory : check the size of your
% variables before extracting them

function [files_to_open]=CM_loop_the_data_out_of_STRUCTURE_ALL(filter_type,STRUCTURE_name,structure_part,short_vector_name,files_to_open)

if isempty (files_to_open)
    files_to_open= uipickfiles ('REFilter',filter_type);    
end

%%
if ~iscell(files_to_open(1,1))
    return
end

for counter=1:1:length(files_to_open)
    lname_full=files_to_open{counter};
    [~, FileName, C]=fileparts (lname_full);
    FileName=strrep(FileName,'ARB_SCAN','ARB')
        FileName=strrep(FileName,'ARBSCAN','ARB')

    k_start=findstr('ARB', FileName);
    k_end=k_start+5;% used to see the day %to be commetise
    short_fname=FileName (k_start:k_end);
    CM=load (lname_full,STRUCTURE_name);
    assignin('base','CM',CM)
    clear CM
    total_name=['CM.' STRUCTURE_name structure_part];
    if ~(isempty(STRUCTURE_name))
        temp_vector= evalin ('base',total_name);
        assignin('base',[short_fname,'_',short_vector_name]',temp_vector)
        clear temp_vector
        CM=[];
        assignin('base','CM',CM)        
        clear CM
    end
end