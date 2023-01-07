

function [files_to_open]=CM_BATCH_SCANIMAGE_FILES (files_to_open)

if (isempty (files_to_open))
    files_to_open= uipickfiles ('REFilter','\_DataStAr.mat');
end
if isnumeric (files_to_open)
    return
end
for i=1:1:length(files_to_open)
    lname_full=files_to_open{i};
    analyse_and_save_file(lname_full);
end
end

function analyse_and_save_file(lname_full)

load (lname_full);
pathAnalysisHelper_SCANIMAGE (dataStructArray);
if(~isempty(strfind(lname_full,'.mat')))
    [pathName, fileName, C]=fileparts (lname_full);
    [~,fileName, C]=fileparts (fileName); % remove the other extension if there is still one;
    lname_full=[pathName '\' fileName];
    fileName=strrep(fileName,'_DataStAr','');
    newfileName=[fileName '_win_' num2str((dataStructArray{1,1}.windowSize)*1000) 'ms_winstep' num2str((dataStructArray{1,1}.windowStep)*1000) 'ms'];
    resDir = fullfile(pathName,'CM_GUI_ANALYZED');
    if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it
    fullfilename=fullfile(resDir,newfileName);
    evalin('base', ['save(''', fullfilename ''')']);
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