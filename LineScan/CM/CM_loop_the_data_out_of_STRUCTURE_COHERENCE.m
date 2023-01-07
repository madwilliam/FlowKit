

% ALLOWS TO EXTRACT STRUCTURE FROM FILES DUMP THEM INTO THE GLOBAL
% WORKSPACE AFTER RENAMING THEM ACCORDING TO THE NAME OF THE FILE
% The heavy programming comes from a problem in extracting field of a
% structure directly from the file

%example [files_to_open]=CM_loop_the_data_out_of_STRUCTURE_COHERENCE('COH_ARB_','COH','')
% short_vector_name: string to assign the name of the extracted variable
% part_of_fieldname='COH_ARB_'; % only select the fields containing the
% part_of_fieldname string
% short_vector_name gives the added name to the saved structure
function [files_to_open]=CM_loop_the_data_out_of_STRUCTURE_COHERENCE(part_of_fieldname,short_vector_name,files_to_open)

if isempty (files_to_open)
    files_to_open= uipickfiles ('REFilter','.mat');    
end

%%
if ~iscell(files_to_open(1,1))
    return
end

for counter=1:1:length(files_to_open)
    lname_full=files_to_open{counter};
    [~, FileName,~]=fileparts (lname_full);
    short_fname=FileName(1:17);
    CM=load (lname_full);
    names = fieldnames(CM);
    CM_new={};
    for i=1:1:size(names,1)
        name_of_the_field=char(names (i));
        if ~isempty(strfind (name_of_the_field,part_of_fieldname))
            CM_new.(char(name_of_the_field))=CM.(char(name_of_the_field));
        end
    end
    clear CM
    if ~(isempty(CM_new))
        assignin('base',[short_fname,'_',short_vector_name]',CM_new)
        clear CM_new
    end
end