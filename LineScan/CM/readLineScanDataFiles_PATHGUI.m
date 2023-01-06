% CM april 2017, adapted from 'readLineScanDataFiles'.
% Contrary to the original, only one channel is read.
% if im_Ch_ind == 88 the pmtdata will not be extracted
function [header, pmtData1Ch, scannerPosData, roiGroup] = readLineScanDataFiles_PATHGUI(fileName,im_Ch_ind)
if (isempty(fileName))
    fileName=uigetfile('.pmt.dat');
    fileName=fileName(1:end-8);
end
if strcmp(fileName(end-8:end), '.meta.dat')
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
if ~(im_Ch_ind==666) %%when you call to not get pmtdataCh1 out
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
end
toc

fclose(fid);

% add useful info to header struct

%header.numSamples = size(pmtData1Ch,1);
header.numSamples = total_number_of_samples_per_frame;
header.acqDuration = header.numSamples / header.sampleRate;
header.frameDuration = header.samplesPerFrame / header.sampleRate;
header.numFrames = ceil(header.numSamples / header.samplesPerFrame);
N = header.samplesPerFrame * header.numFrames;

if ~(im_Ch_ind==666) %%when you call to not get pmtdataaCh out
    
    pmtData1Ch(end+1:N,:) = nan;
    pmtData1Ch = permute(reshape(pmtData1Ch,1,header.samplesPerFrame,[]),[2 1 3]);
 else
     pmtData1Ch=[];
 end

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
% readLineScanDataFiles.m      modified by Celine Mateo 2017 May - June                                            %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
