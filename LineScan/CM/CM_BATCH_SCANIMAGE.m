function [files_to_open]=CM_BATCH_SCANIMAGE (files_to_open,Str_ArrayList)

if (~exist ('files_to_open','var') || isempty (files_to_open))
    files_to_open= uipickfiles ('REFilter','\.pmt.dat');
end
if isempty (Str_ArrayList)
[Str_ArrayList] = CM_Choose_multiple_var('cell','Get template Structures');
end
dataStructArray=evalin('base',Str_ArrayList{1});

if isnumeric (files_to_open)
    return
end

for i=1:1:length(files_to_open)
    lname_full=files_to_open{i};
    if(~isempty(strfind(lname_full,'.pmt.dat')))
        [PathName, FileName, C]=fileparts (lname_full);
        [~,FileName, C]=fileparts (FileName); % remove the other extension if there is still one;
        lname_full=[PathName '\' FileName];
        lname_full_analog=[lname_full];
        a=lname_full_analog;
        
    NewDataStruct=CM_Change_STRUCTARRAY_field (dataStructArray,'fullFileNameMpd',a);
    pathAnalysisHelper_SCANIMAGE (NewDataStruct);  
    
   %% evalin('base', ['save(''' tac ''')']);
    end
    
end
end


function [FETCHED_STRING]=CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
% this function calls the prompt and returns a string (sAnswer)
% CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
disp 'CM_ASK_THE_FIELD'
prompt = {STRING_TO_FETCH};
dlg_title = ['Enter ' STRING_TO_FETCH];
num_lines = 1;
FETCHED_STRING = inputdlg(prompt,dlg_title,num_lines,{defstring});
FETCHED_STRING=FETCHED_STRING(1);
FETCHED_STRING=(FETCHED_STRING{:});

end