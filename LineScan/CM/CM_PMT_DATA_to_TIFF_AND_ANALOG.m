% CM 201505 allows to extract Data from arbscans from scanimage
%%
% Analog_ST=CM_PMT_DATA_to_TIFF_AND_ANALOG (filename,5000)
function Analog_ST=CM_PMT_DATA_to_TIFF_AND_ANALOG (filename,freq)
%[filename]=CM_SAVE_STK_TO_TIFF_from_ARB(filename,1,'');
% [filename]=CM_SAVE_STK_TO_TIFF_from_ARB(filename,2,'');
[Analog_ST.LFP_DATA, Analog_ST.LFP_TIME, filename]= CM_EXTRACT_ANALOG_SCANIMAGE (filename,3,freq);

%[Analog_ST.ACC_DATA, Analog_ST.ACC_TIME, filename]= CM_EXTRACT_ANALOG_SCANIMAGE (filename,3,freq);
[Analog_ST.LIGHT_DATA, Analog_ST.LIGHT_TIME, filename]= CM_EXTRACT_ANALOG_SCANIMAGE (filename,4,freq);
close all
end


function [filename]=CM_SAVE_STK_TO_TIFF_from_ARB(filename,channel,STK_TO_TIFF)

if (isempty(filename)) % no filename
    [filename,pathname] = uigetfile('*.pmt.dat','Select the linescan file');
    if (isnumeric(filename));end
    
    [pathname,filename,~] = fileparts([pathname filename]);% remove one extension
    filename=[pathname '\' filename];
    [pathname,filename,~] = fileparts([filename]); %  % remove the second extension
    filename=[pathname '\' filename]; % remove one extension
else % filename
    [pathname,filename,~] = fileparts(filename);
    if isempty(pathname) % filename with no pathname
        pathname=cd;
    end
    filename=[pathname '\' filename];
end

if (isempty(channel))
    [FETCHED_STRING]=CM_FETCH_THE_STRING ('channel','');
    channel=round(str2num(FETCHED_STRING));
end

if (isempty (STK_TO_TIFF)) % go and extract
    [header] =readShortHeaderScanDataFiles (filename);
    im_Ch_ind= find(header.acqChannels==channel);
    [header, STK_TO_TIFF, ~, ~] = readLineScanDataFiles_PATHGUI(filename,im_Ch_ind);

end


[pathname,B]=fileparts(filename);
resDir=[pathname '\' 'ARB_tiffs\'];
if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it

fname=[resDir B '_Ch' num2str(channel)];
TiffFileName=[fname '.tif'] ;
TiffFileName_frame=[fname '_FR.tif'] ;
TiffFileName_resliced=[fname '_RESLICED.tif'] ;
offset=(min(STK_TO_TIFF(:)));
% tac=STK_TO_TIFF;
%% STEP 1 get the entire ARBSCAN for 1 channel in one image
%STK_TO_TIFF=tac;
STK_TO_TIFF=squeeze(STK_TO_TIFF);
STK_TO_TIFF=round (STK_TO_TIFF-offset);
STK_TO_TIFF=uint16(STK_TO_TIFF);
STK_TO_TIFF=permute (STK_TO_TIFF, [2 1]);
output_filename = maketiff(STK_TO_TIFF,TiffFileName); % one image for the entire channel straight
figure
subplot (3,1,1)
imagesc(STK_TO_TIFF);figure (gcf)
%% STEP 2 get the entire ARBSCAN 50 times averaged in time in one image
STK_TO_TIFF=permute (STK_TO_TIFF, [2 1 3]);
T=size(STK_TO_TIFF);
STK_TO_TIFF=reshape(STK_TO_TIFF(:,1:(floor(T(2)/50)*50)),T(1),50,floor(T(2)/50));
STK_TO_TIFF=permute (STK_TO_TIFF, [3 1 2]);
resliced_mean=mean(single(STK_TO_TIFF),3);
resliced_mean=uint16(ceil(resliced_mean)-min(resliced_mean(:)));
output_filename = maketiff(resliced_mean,TiffFileName_resliced);
disp (fname);disp 'was saved as ';disp(TiffFileName_resliced);
%% STEP 3 get the entire ARBSCAN in X* 500 * Z frames not average
STK_TO_TIFF=permute (STK_TO_TIFF, [2 3 1]);
T=size(STK_TO_TIFF);
STK_TO_TIFF=(reshape(STK_TO_TIFF,T(1),T(2)*T(3))); % one plane for the entire channel straight
T=size(STK_TO_TIFF);
STK_TO_TIFF=(reshape(STK_TO_TIFF(:,1:(floor(T(2)/500)*500)),T(1),500,floor(T(2)/500)));
STK_TO_TIFF=permute (STK_TO_TIFF, [2 1 3]);% full image in frames of 500 lines
T=size(STK_TO_TIFF);
subplot (3,1,2)
imagesc(resliced_mean (:,:,1));
subplot (3,1,3)
imagesc(STK_TO_TIFF (:,:,1))

output_filename = maketiff(STK_TO_TIFF,TiffFileName_frame);

clear 'STK_TO_TIFF'

end

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

function output_filename = maketiff(varargin)
%this function writes a 3-D image stack as a multi-frame .tif file
%use : maketiff(myvariable, output_filename)
%   this returns the output_filename
%   if output_filname is excluded, a uiputfile gui opens to select a
%   filename
%note, an extra qualifier variable can be added to the end
%   maketiff(myvariable,qualifier) or maketiff(myvariable, output_filename, qualifier)
%the qualifier can be 'transpose', or 'nowb' to either transpose the matrix
%   before writing the tif, or to eliminate the waitbar.
%
%Written by Philbert S. Tsai on 08/03/05
%Last Updated : 06/10/06


nin = nargin;
filename = ' ';
transpose_yn = 0;
waitbar_yn = 1;
input_matrix = varargin{1};
if nin>1,
    qualifier1 = varargin{2};
    switch qualifier1,
        case 'transpose', transpose_yn = 1;
        case 'notranspose', transpose_yn = 0;
        case 'nowb', waitbar_yn = 0;
        otherwise filename = varargin{2};
    end
end


if filename == ' ';
    [filename,pathname,filterindex] = uiputfile('*.tif', 'Save as multiframe tif');
    filename = [pathname,filename];
end

if nin>2,
    qualifier1 = varargin{3};
    if strcmp(qualifier1,'transpose'), transpose_yn = 1; end
    if strcmp(qualifier1,'notranspose'), transpose_yn = 0; end
    if strcmp(qualifier1,'nowb'), waitbar_yn = 0; end
end


mysize = size(input_matrix);
x_size = mysize(1);
y_size = mysize(2);
temp = size(mysize);
if temp(2) == 3,
    z_size = mysize(3);
else
    z_size = 1;
end

current_frame = input_matrix(:,:,1);
if transpose_yn == 1; current_frame = transpose(current_frame);end

finfo = whos('input_matrix');
bitDepth = finfo.class;
switch bitDepth
    case {'uint8'}
        input_matrix = uint8(input_matrix);
    case {'uint16'}
        input_matrix = uint16(input_matrix);
    case {'logical'}
        input_matrix = uint8(input_matrix.*256);
end

current_frame = input_matrix(:,:,1);
imwrite(current_frame,filename,'tiff','Compression','none');

if z_size >1,
    if waitbar_yn == 1, wb = waitbar(0,'Writing multiframe tiff...');end
    for k = 2:z_size,
        current_frame = input_matrix(:,:,k);
        if transpose_yn == 1; current_frame = transpose(current_frame);end
        imwrite((current_frame),filename,'tiff','WriteMode','append','Compression','none');
        if waitbar_yn == 1, waitbar(k/z_size,wb), end
    end
    if waitbar_yn == 1, close(wb); end
end

output_filename = filename;

end


function CM_make_tiff (stk,stk_name)
if(isempty(stk))
    [stk,stk_name]=CM_uigetvar({'int16','int8','uint16','uint8','double'},'STACK');
end

finfo = whos('stk');
bitDepth = finfo.class;
switch bitDepth
    case {'uint8'}
        input_matrix = uint8(input_matrix);
    case {'uint16'}
        input_matrix = uint16(input_matrix);
    case {'logical'}
        input_matrix = uint8(input_matrix.*256);
    case {'int16'}
        stk = uint16(round(stk-min(stk(:))));
    case {'double'}
        stk = uint16(round(stk-min(stk(:))));
end

%current_frame = input_matrix(:,:,1);
%imwrite(current_frame,filename,'tiff','Compression','none');


output_filename = maketiff(stk);
disp (stk_name);disp 'was saved as ';disp(output_filename);
end

% CM april 2017, adapted from 'readLineScanDataFiles'.
% Contrary to the original, only one channel is read.
function [header, pmtData1Ch, scannerPosData, roiGroup] = readLineScanDataFiles_PATHGUI(fileName,im_Ch_ind)
if (isempty(fileName))
    fileName=uigetfile('.pmt.dat');
    fileName=fileName(1:end-8);
end
if  ~isempty(strfind(fileName, '.meta.dat'))
    fileNameStem = fileName(1:end-9);
    metaFileName = fileName;
else
    fileNameStem = fileName;
    metaFileName = [fileName '.meta.txt'];
end

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
roiGroup = scanimage.mroi.RoiGroup.loadobj(rgData.RoiGroups.imagingRoiGroup);

% read and parse pmt data
header.acqChannels = header.SI.hChannels.channelSave;
nChannels = numel(header.acqChannels);
fid = fopen([fileNameStem '.pmt.dat']);
assert(fid > 0, 'Failed to open pmt data file.');

fseek(fid,0,'eof');
total_number_of_samples=ftell(fid)/2;
frewind(fid);

header.samplesPerFrame = header.SI.hScan2D.lineScanSamplesPerFrame;%samples per frame and per channel
header.sampleRate = header.SI.hScan2D.sampleRate;

total_number_of_samples_per_frame=header.samplesPerFrame*nChannels;
number_of_frames=ceil(total_number_of_samples/total_number_of_samples_per_frame);
frame_jump=ceil(number_of_frames/10);
bytes_jump=2*frame_jump*total_number_of_samples_per_frame;

tic
for frame=1:frame_jump:number_of_frames
    
    if (frame+frame_jump<number_of_frames)
        pmtData = fread(fid,bytes_jump,'*int16');
    else
        pmtData = fread(fid,inf,'*int16');
    end
    if (frame==1)
        pmtData1Ch=pmtData(im_Ch_ind:nChannels:end-(nChannels-im_Ch_ind));
    else
        pmtData1Ch=[pmtData1Ch ; pmtData(im_Ch_ind:nChannels:end-(nChannels-im_Ch_ind))];
    end
end
toc

fclose(fid);

% add useful info to header struct

header.numSamples = size(pmtData1Ch,1);
header.numSamples = total_number_of_samples_per_frame;
header.acqDuration = header.numSamples / header.sampleRate;
header.frameDuration = header.samplesPerFrame / header.sampleRate;
header.numFrames = ceil(header.numSamples / header.samplesPerFrame);
N = header.samplesPerFrame * header.numFrames;

pmtData1Ch(end+1:N,:) = nan;
pmtData1Ch = permute(reshape(pmtData1Ch,1,header.samplesPerFrame,[]),[2 1 3]);


%     N2 = header.samplesPerFrame * header.numFrames * nChannels;
%
%     pmtData(end+1:N2,:) = nan;
%    % pmtData = permute(reshape(pmtData,1,header.samplesPerFrame,[]),[2 1 3]);
%     pmtData = permute(reshape(pmtData,nChannels,header.samplesPerFrame,[]),[2 1 3]);


% read and parse scanner position data
fid = fopen([fileNameStem '.scnnr.dat']);
if fid > 0
    dat = fread(fid,inf,'single');
    fclose(fid);
    
    nScnnrs = header.SI.hScan2D.lineScanNumFdbkChannels;
    header.feedbackSamplesPerFrame = header.SI.hScan2D.lineScanFdbkSamplesPerFrame;
    header.feedbackSampleRate = header.SI.hScan2D.sampleRateFdbk;
    header.numFeedbackSamples = size(dat,1)/nScnnrs;
    header.numFeedbackFrames = ceil(header.numFeedbackSamples / header.feedbackSamplesPerFrame);
    
    % pad data if last frame was partial
    N = header.feedbackSamplesPerFrame * header.numFeedbackFrames * nScnnrs;
    dat(end+1:N,:) = nan;
    
    dat = permute(reshape(dat,nScnnrs,header.feedbackSamplesPerFrame,[]),[2 1 3]);
    scannerPosData.G = dat(:,1:2,:);
    if nScnnrs > 2
        scannerPosData.Z = dat(:,3,:);
    end
else
    scannerPosData = [];
end
end

%--------------------------------------------------------------------------%
% readLineScanDataFiles.m                                                  %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%


