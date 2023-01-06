function [files_to_open]=CM_LOOP_PMT_DATA_to_TIFF_AND_ANALOG (files_to_open,freq)

if (~exist ('files_to_open','var') || isempty (files_to_open))
    files_to_open= uipickfiles ('REFilter','\.pmt.dat');
end

if isnumeric (files_to_open)
    return
end

if nargin<2
[FETCHED_STRING]=CM_FETCH_THE_STRING ('Frequency Analog','5000');
freq=str2num(FETCHED_STRING);
end

for i=1:1:length(files_to_open)
    lname_full=files_to_open{i};
    if(~isempty(strfind(lname_full,'.pmt.dat')))
        [PathName, FileName, C]=fileparts (lname_full);
        [~,FileName, C]=fileparts (FileName); % remove the other extension if there is still one;
        lname_full=[PathName '\' FileName];
        Analog_ST=CM_PMT_DATA_to_TIFF_AND_ANALOG (lname_full,freq);
        lname_full_analog=[lname_full '_ANALOG.mat'];
        save(lname_full_analog,'Analog_ST')
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