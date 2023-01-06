% CM 20170525 extracts analog channels from scanimage linescan (.pmt) files
% issues how to define downsample
% 
function [analog_data, analog_time, filename]= CM_EXTRACT_ANALOG_SCANIMAGE (filename,channel,new_freq)

if (isempty(filename))
    [filename,pathname] = uigetfile('*.pmt.dat','Select the linescan file');
    [pathname,filename,~] = fileparts([pathname filename]);% remove one extension
    filename=[pathname '\' filename]; 
    [pathname,filename,~] = fileparts([filename]); %  % remove the second extension
       filename=[pathname '\' filename]; % remove one extension

else
    [pathname,filename,~] = fileparts(filename);
    if isempty(pathname)
        pathname=cd;
        filename=[pathname '\' filename];
    end
end
if (isempty(filename))
    return
end

if (isempty(channel))
    [FETCHED_STRING]=CM_FETCH_THE_STRING ('channel','');
    channel=round(str2num(FETCHED_STRING));
end
    
[header] =readShortHeaderScanDataFiles (filename);
im_Ch_ind= find(header.acqChannels==channel);
[header, pmt_data, ~, ~] = readLineScanDataFiles_PATHGUI(filename,im_Ch_ind);
sample_time=header.SI.hScan2D.scanPixelTimeMean; % most exact way to determine the time
decimation_factor= (1/sample_time)/new_freq;
decimation_factor=round(decimation_factor);
analog_data=pmt_data (round(decimation_factor/2):decimation_factor:end);
input_range=header.SI.hChannels.channelInputRange {1,channel};
input_range=input_range(2)-input_range(1);
resolution=(input_range/(2^12));
analog_data=(double(analog_data))*resolution;
analog_time=1:1:numel(analog_data);
analog_time=analog_time*(decimation_factor*sample_time);
analog_time=analog_time-(decimation_factor/2)*sample_time;
figure (2467);plot(analog_time,analog_data); figure (gcf);
new_freq=1/(analog_time (2)-analog_time(1))
end



function [FETCHED_STRING]=CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
% this function calls the prompt and returns a string (sAnswer)
disp 'CM_ASK_THE_FIELD'
prompt = {STRING_TO_FETCH};
dlg_title = ['Enter ' STRING_TO_FETCH];
num_lines = 1;
FETCHED_STRING = inputdlg(prompt,dlg_title,num_lines,{defstring});
FETCHED_STRING=FETCHED_STRING(1);
FETCHED_STRING=(FETCHED_STRING{:});
end


function [header] = readShortHeaderScanDataFiles(fileName)
    fileNameStem = fileName;
    metaFileName = [fileName '.meta.txt'];

% read metadata
fid = fopen(metaFileName,'rt');
assert(fid > 0, 'Failed to open metadata file.');
headerStr = fread(fid,'*char')';
fclose(fid);

% parse metadata
if headerStr(1) == '{'
    data = most.json.loadjson(headerStr);
    header = data{1};
    rgData = data{2};
else
    rows = textscan(headerStr,'%s','Delimiter','\n');
    rows = rows{1};
    
    rgDataStartLine = find(cellfun(@(x)strncmp(x,'{',1),rows),1);
    header = scanimage.util.private.decodeHeaderLines(rows(1:rgDataStartLine-1));
    
    rgStr = strcat(rows{rgDataStartLine:end});
    rgData = most.json.loadjson(rgStr);
end
% read and parse pmt data
header.acqChannels = header.SI.hChannels.channelSave;
end