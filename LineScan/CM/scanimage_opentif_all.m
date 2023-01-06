function [header,Aout,imgInfo] = scanimage_opentif_all(varargin)
%% OPENTIF   
% Reads a ScanImage TIFF file
%% Description
% Opens a ScanImage TIF file, extracting its header information and, if specified, stores all of image contents as output array Aout if specified. 
% By default, Aout, if specified for output, is of size MxNxCxFxSxV, where C spans the channel indices, F spans the frame indicies, S spans the 
% slice indices, and V the volume indices.
%
% NOTE: IF the second output argument (Aout) is not assigned to output variable
%     THEN image file is not actually read -- only  header information is extracted
%     
% IMPORTANT: opentif currently only exports the header and sequential image data. Once the tiff header specification reaches a stable 
%	    point, parsing and data organization will be reincorporated ++++
%
%% SYNTAX
%   opentif()
%   opentif(filename)
%   header = opentif(...)
%   [header,Aout] = opentif(...)
%   [header,Aout,imgInfo] = opentif(...)
%		INPUT
%       	filename: Name of TIF file, with or without '.tif' extension. If omitted, a dialog is launched to allow interactive selection.
%       	flagN/flagNArg: Flags (string-valued) and/or flag/value pairs, in any order, specifying options to use in opening specified file
%
%		OUTPUT
%       	header: Structure comprising information stored by ScanImage into TIF header
%       	Aout: MxNxCxFxSxV array, with images of size MxN for C channels, F frames, S slices, and V volumes. Default type is uint16. 
%       	imgInfo: Structure comprising basic information about the structure of the output array Aout
%
% NOTE: IF the second output argument (Aout) is not assigned to output variable
%       THEN image file is not actually read -- only header information is extracted
%
%% FLAGS (case-insensitive)
%
%   WITH ARGUMENTS
%       'channel' or 'channels': Argument specifies subset of channel(s) to extract. Ex: 1,[1 3], 2:4. 
%       'frame' or 'frames': Argument specifies subset of frames present to extract. Use 'inf' to specify all frames above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%       'slice' or 'slices': Argument specifies subset of slices present to extract. Use 'inf' to specify all slices above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%       'volume' or 'volumes': Argument specifies subset of volumes present to extract. Use 'inf' to specify all slices above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%
%% NOTES
%   This function replaces the scim_openTif() function supplied with ScanImage 4.2
%  	
%	In case of errors, the program will attempt to output whatever image data is available to it as an uncategorized stream of images
%	This stream will be an array of the form MxNxImg raw ouput without any post-processing, containing all the frames found within the file, where Img is the number of images
%
%   TODO: Port more advanced features to ScanImage 5 from SI3/4 scim_openTif
%   TODO: Add a flag to discard fastZ-flyback frames if present
%

    % Initialize output variables
    header = [];
    Aout   = [];
    imgInfo = struct();

    % Constants/Inits
    if nargout < 0 || nargout > 3
        warn('Invalid arguments'); 
        return
    end

    % Parse input arguments

    flagNames = {'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'};
    argFlags = {'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'};

    flagIndices = find(cellfun(@(x)ischar(x) && (ismember(lower(x),flagNames) || ismember(lower(x),argFlags)),varargin));

    flags = cellfun(@lower,varargin(flagIndices),'UniformOutput',false);
    if isempty(flags)
        flags = {};
    end

    streamOutput = false;

    % Determine input file
    if isempty(find(flagIndices==1)) && nargin>=1 && ischar(varargin{1})
        fileName = varargin{1};
    else
        fileName = '';
    end

    if isempty(fileName)
        [f, p] = uigetfile({'*.tif;*.tiff'},'Select Image File');
        if f == 0
            warn('Invalid arguments'); 
            return;
        end
        fileName = fullfile(p,f); 
    end

    %Extract filepath for future use
    %[filePath,fileStem,fileExt] = fileparts((fileName));

    % Read TIFF file; extract # frames & image header
    if ~exist(fileName,'file') && ~exist([fileName '.tif'],'file') && ~exist([fileName '.tiff'],'file') 
        error('''%s'' is not a recognized flag or filename. Aborting.',fileName);
    elseif exist([fileName '.tif'],'file') 
        fileName = [fileName '.tif'];
    elseif exist([fileName '.tiff'],'file') 
        fileName = [fileName '.tiff'];
    end

    %warn(['Loading file ' fileName]);

    warning('off','MATLAB:tifflib:TIFFReadDirectory:libraryWarning');
    hTif = Tiff(fileName);

    [fileHeader, frameDescs] = getHeaderData(hTif);

    bErrorFound = false;
    try
        verInfo = getSITiffVersionInfo(fileHeader);
        header = parseFrameHeaders(fileHeader,frameDescs,verInfo);
        si_ver = verInfo.SI_MAJOR;
    catch
        bErrorFound = true;
        si_ver = '';
    end

    numImages = numel(frameDescs);

    %Reincorporate conditional once header spec is stable
    if numImages == 0 || strcmp(si_ver,'')
        bErrorFound = true;
    end

    if bErrorFound
        [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver);
        return;
    end

    hdr = extractHeaderData(header,verInfo);

    % Read image meta-data
    savedChans = hdr.savedChans;

    %Display channel information to user
    %warn(['Matrix of channels saved: ' mat2str(savedChans)]);

    numChans = length(savedChans);
    numPixels = hdr.numPixels;
    numLines = hdr.numLines;
    numSlices = hdr.numSlices;
    numVolumes = hdr.numVolumes;
    numFrames = hdr.numFrames;
    numDiscardFrames = 0;
    discardFlybackframesEnabled = false;

    % If using FastZ, use slices value that contains potential flyback frames
    % for proper organization of output image-array
    if hdr.discardFlybackframesEnabled
        actualNumSlices = hdr.numFramesPerVolume;
    else
        actualNumSlices = hdr.numSlices;
    end

    if actualNumSlices > 1 && numFrames > 1
        warn('Cannot interpret multiple frames and slices simultaneously at this time.');
        [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver);
        return;
    end

    % This section makes sure there are no issues with nextTrigger data
    if numImages ~= numChans*numFrames*actualNumSlices*numVolumes
        % We are working under the assumption that only volumes can have multiple "slices"
        if actualNumSlices > 1
            numVolumes = floor(numImages/numChans/actualNumSlices);
            numFrames = 1;  % This should already be the case
        elseif numFrames > 1
            % In this case there are no volumes, since we only can have 1 frame and multiple slices in a volume
            numVolumes = 1; % This should already be the case
            actualNumSlices = 1;  % This should already be the case
            % We discard the previous value of frames and adjust to what was acquired before the next-trigger came in
            numFrames = floor(numImages/numChans);  
        end

        if numImages ~= numChans*numFrames*actualNumSlices*numVolumes
            warn('Unexpected number of images.');
            [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver);
            return;
        end
    end

    %DEBUG msg
    %warn(['numImages = ' num2str(numImages)]);
    %warn(['numChans = ' num2str(numChans)]);
    %warn(['numFrames = ' num2str(numFrames)]);
    %warn(['numSlices = ' num2str(numSlices)]);
    %warn(['numVolumes = ' num2str(numVolumes)]);
    %warn(' ');

    if ~numFrames || ~numSlices
        warn('Acquisition did not complete a single frame or slice. Aborting.');
        [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver);
        return;
    end

    %VI120910A: Detect/handle header-only operation (don't read data)
    if nargout <= 1
        return;
    end

    % Process Flags

    %Determine channels to extract
    if any(ismember({'channel' 'channels'},flags))
        selectedChans = getArg(varargin,{'channel' 'channels'},flags,flagIndices);

        if ~isempty(setdiff(selectedChans,savedChans))
            selectedChans(find(setdiff(selectedChans,savedChans))) = [];
            warning('Some specified channels to extract not detected in file and, hence, ignored');
            if isempty(selectedChans)
                warning('No saved channels are specified to extract. Aborting.');
                return;
            end
        end
    else
        selectedChans = savedChans;
    end

    %This mode stays given the nature of non-selected channel storage
    %Auxiliary mapping for channel selection to index
    chanKey = num2cell(savedChans);
    chanVal = 1:length(savedChans);   %+++ Change to savedChans for selection if no resizing occurs?
    chanMap = containers.Map(chanKey,chanVal);

    %Determine slices to extract
    if numSlices >= 1 && any(ismember({'slice' 'slices'},flags))
        selectedSlices = selectImages(varargin,{'slice' 'slices'},numSlices, flags, flagIndices);
    else
        %Extract all slices
        selectedSlices = 1:numSlices;
    end

    % RRR Extract all frames for now
    %Determine frames to extract
    if numFrames >= 1 && any(ismember({'frame' 'frames'},flags))
        selectedFrames = selectImages(varargin,{'frame' 'frames'},numFrames, flags, flagIndices);
    else
        %Extract all frames
        selectedFrames = 1:numFrames;
    end


    %Determine volumes to extract
    if numVolumes >= 1 && any(ismember({'volume' 'volumes'},flags))
        selectedVolumes = selectImages(varargin,{'volume' 'volumes'},numVolumes, flags, flagIndices);
    else
        %Extract all frames
        selectedVolumes = 1:numVolumes;
    end


    %Determine if any selection is being made
    forceSelection = any(ismember({'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'volume' 'volumes'},flags));

    % Preallocate image data
    switch hTif.getTag('SampleFormat')
        case 1
            imageDataType = 'uint16';
        case 2
            imageDataType = 'int16';
        otherwise
            assert('Unrecognized or unsupported SampleFormat tag found');
    end

    %Look-up values for faster operation
    lenSelectedFrames = length(selectedFrames);
    lenSelectedChans = length(selectedChans);
    lenSelectedSlices = length(selectedSlices);
    lenSelectedVolumes = length(selectedVolumes);

    lenTotalChans = length(savedChans);
    lenTotalSlices = numSlices;
    lenTotalFrames = numFrames;
    % lenTotalVolumes = numVolumes;

    %HACK! For now there seems to be an issue with the flyback possibly due to mroi
    %still being developed. We need to take only the last section of the following values: 
    %The following also takes care of MROI mode discrepancies, since we don't have access
    %to the properties of MROI captures through the TIFF header at the moment
    numLines = hTif.getTag('ImageLength');
    numPixels = hTif.getTag('ImageWidth');

    Aout = zeros(numLines,numPixels,lenSelectedChans,lenSelectedFrames,lenSelectedSlices,lenSelectedVolumes,imageDataType);    

    % Read image data
    selectedChans = selectedChans';

    if streamOutput
        % This mode is for the case in which the selection parameters cannot be 
        % trusted. For instance, when the number of images is different than 
        % expected, but we would still like to 
        % Checking this mode has priority given that it will always output existing data
        % No postprocessing for data (such as removing discard frames) at this point
        warn('Insufficient or incorrect header data.')

        % Preallocate image data
        Aout = zeros(numLines,numPixels,numImages,imageDataType);    

        for idx = 1:numImages
            hTif.setDirectory(idx);
            Aout(:,:,idx) = hTif.read();
        end

        warn('Returning default, uncategorized stream of Tiff frames')

    elseif forceSelection
        for p = 1:lenSelectedVolumes
            for j = 1:lenSelectedSlices
                for k = 1:lenSelectedFrames
                    for i = 1:lenSelectedChans
                        %SELECTION MODE: (can allow parameter selection)
                        idx = chanMap(selectedChans(i));
                        %Get the tiff-index for the frames
                        idx = lenTotalChans*(selectedFrames(k) - 1) + idx;
                        %Get the tiff-index for the slices
                        idx = lenTotalFrames*lenTotalChans*(selectedSlices(j) - 1) + idx;
                        %Get the tiff-index for the volumes
                        idx = lenTotalSlices*lenTotalFrames*lenTotalChans*(selectedVolumes(p) - 1) + idx;

                        %+++ Test the following expression.
                        if ismember(selectedChans(i), savedChans)
                            hTif.setDirectory(idx);
                            Aout(:,:,i,k,j,p) = hTif.read();
                        end
                    end
                end
            end
        end
    else
        idx = 0;
        for p = 1:lenSelectedVolumes
            for j = 1:lenSelectedSlices
                for k = 1:lenSelectedFrames
                    for i = 1:lenSelectedChans
                        %NO-SELECTION MODE: (more efficient)
                        idx = idx + 1;

                        if ismember(selectedChans(i), savedChans)
                            hTif.setDirectory(idx);
                            Aout(:,:,i,k,j,p) = hTif.read();
                        end
                    end
                end
            end
        end
    end

    % Prepare imgInfo
    imgInfo.numImages = numImages;
    imgInfo.numChans = numChans;
    imgInfo.numPixels = numPixels;
    imgInfo.numLines = numLines;
    imgInfo.numSlices = numSlices;
    imgInfo.numVolumes = numVolumes;
    imgInfo.numFrames = numFrames;
    imgInfo.filename = fileName;	
    imgInfo.si_ver = si_ver;	

end


%--------------------------------------------------------------------------%
% opentif.m                                                                %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

function [fileHeader, frameDescs] = getHeaderData(tifObj)
% Returns a cell array of strings for each TIFF header
% If the number of images is desired one can call numel on frameStringCell or use the 
% second argument (the latter approach is preferrable)
%
    numImg = 0;

    % Before anything else, see if the tiff file has any image-data
    try
        %Parse SI from the first frame
        numImg = 1;
        while ~tifObj.lastDirectory()
            tifObj.nextDirectory();
            numImg = numImg + 1;
        end
    catch
        warning('The tiff file may be corrupt.')
        % numImg will have the last valid value, so we can keep going and 
        % deliver as much data as we can
    end
    tifObj.setDirectory(1);

    %Make sure the tiff file's ImageDescription didn't go over the limit set in 
    %Acquisition.m:LOG_TIFF_HEADER_EXPANSION
    try
        if ~isempty(strfind(tifObj.getTag('ImageDescription'), '<output truncated>'))
            warn('Corrupt header data');
            return;
        end
    catch
        warn('Corrupt or incomplete tiff header');
        return
    end

    frameDescs = cell(1,numImg);

    for idxImg = 1:numImg
        frameDescs{1,idxImg} = tifObj.getTag('ImageDescription');
        if idxImg == numImg; break;end  % Handles last case
        tifObj.nextDirectory();
    end
    
    try
        fileHeaderStr = tifObj.getTag('Software');
    catch
        % legacy style
        fileHeaderStr = frameDescs{1};
    end
    
    try
        if fileHeaderStr(1) == '{'
            s = most.json.loadjson(fileHeaderStr);
            
            %known incorrect handling of channel luts!
            n = size(s.SI.hChannels.channelLUT,1);
            c = cell(1,n);
            for i = 1:n
                c{i} = s.SI.hChannels.channelLUT(i,:);
            end
            s.SI.hChannels.channelLUT = c;
            
            fileHeader.SI = s.SI;
        else
            % legacy style
            fileHeaderStr = strrep(fileHeaderStr, 'scanimage.SI.','SI.');
            rows = textscan(fileHeaderStr,'%s','Delimiter','\n');
            rows = rows{1};
            
            for idxLine = 1:numel(rows)
                if strncmp(rows{idxLine},'SI.',3)
                    break;
                end
            end
            
            fileHeader = decodeHeaderLines(rows(idxLine:end));
        end
    catch
        fileHeader = struct();
    end
end


%--------------------------------------------------------------------------%
% getHeaderData.m                                                          %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

function [verInfo] = getSITiffVersionInfo(fileHeader)
%   Analize a tiff-header frame-string to determine the scanimage version it came from
%   The tags provided by the ScanImage header are insufficient to keep track of released 
%   versions of ScanImage, hence we'll provide a structure called verInfo to help us simplify
%   version detection

    verInfo = struct();
    verInfo.infoFound = false;

    %TODO: Make sure this works for the case where this property doesn't exist?
    try
        verInfo.SI_MAJOR = fileHeader.SI.VERSION_MAJOR;
        verInfo.SI_MINOR = fileHeader.SI.VERSION_MINOR;
        verInfo.TIFF_FORMAT_VERSION = fileHeader.SI.TIFF_FORMAT_VERSION;
        verInfo.infoFound = true;
    catch
        dispError('Cannot find SI and/or Tiff version properties in Tiff header.\n');
        return;
    end

    %% Determine if the scanner is linear or resonant
    try
        verInfo.ImagingSystemType = fileHeader.SI.hScan2D.scannerType;
    catch
        verInfo.ImagingSystemType = fileHeader.SI.imagingSystem;
    end
end


%--------------------------------------------------------------------------%
% getSITiffVersionInfo.m                                                   %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
function s = parseFrameHeaders(s,frameHeaders,verInfo)
    
    numImg = numel(frameHeaders);

    if frameHeaders{1}(1) == '{'
        if verInfo.TIFF_FORMAT_VERSION > 2
            hdrs = cellfun(@(x)most.json.loadjson(strtrim(x)),frameHeaders);
        else
            % legacy. In the old json format (intermediate 2015-2016) the
            % frame varying data was in a section called "FrameHeader"
            hdrs = cellfun(@(x)most.json.loadjson(strtrim(x)).FrameHeader,frameHeaders);
        end
        
        nms = fieldnames(hdrs);
        for nm = nms'
            snm = nm{1};
            
            if ismember(snm, {'epoch' 'I2CData'})
                s.(snm) = {hdrs.(snm)};
            elseif ismember(snm, {'auxTrigger0' 'auxTrigger1' 'auxTrigger2' 'auxTrigger3'})
                s.(snm) = {hdrs.(snm)};
                e = cellfun(@isempty,s.(snm));
                s.(snm)(e) = {[]};
            else
                s.(snm) = [hdrs.(snm)];
            end
        end
    else
        dataEndLine = [];
        nms = {};
        mkCell = [];
        
        for frameIdx = 1:numImg
            rows = textscan(frameHeaders{frameIdx},'%s','Delimiter','\n');
            rows = rows{1};
            
            if isempty(dataEndLine)
                dataEndLine = find(cellfun(@(x)strncmp(x,'SI.',3),rows),1)-1;
            end
            if isempty(dataEndLine)
                dataEndLine = find(cellfun(@(x)strncmp(x,'scanimage.SI.',13),rows),1)-1;
            end
            if isempty(dataEndLine)
                dataEndLine = numel(rows);
            end
            
            for idxLine = 1:dataEndLine
                row = rows{idxLine};
                
                %% replace top-level name with 'obj'
                [nm, valStr] = strtok(row,'=');
                
                nm = strtrim(nm);
                valStr = strtrim(valStr(2:end));
                
                if frameIdx == 1
                    nms{end+1} = matlab.lang.makeValidName(strtrim(nm));
                    mkCell(end+1) = ~isempty(valStr) && ismember(valStr(1), {'[' '{'});
                    
                    if mkCell(end)
                        s.(nms{end}) = cell(1,numImg);
                    else
                        s.(nms{end}) = zeros(1,numImg);
                    end
                end
                
                % Check if there is a value to assign
                if isempty(valStr)
                    % This unassigned parameter value will be set to 0
                    continue;
                end
                
                if mkCell(idxLine)
                    s.(nms{idxLine}){frameIdx} = eval([valStr ';']);
                else
                    valStr = regexp(valStr,'\d+(\.\d+)?|\[\]', 'match');
                    s.(nms{idxLine})(frameIdx) = sscanf(valStr{1},'%f');
                end
            end
        end
    end
        
    if ~isfield(s.SI, 'hScan2D')
        switch verInfo.ImagingSystemType
            case 'Resonant'
                s.SI.hScan2D = s.SI.hResScan;
                
            case 'Linear'
                s.SI.hScan2D = s.SI.hLinScan;
        end
    end
end


%--------------------------------------------------------------------------%
% parseFrameHeaders.m                                                      %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

function [Aout,imgInfo] = streamOutputQuit(hTif,numImages,si_ver)
% This function returns available data and should be followed by an exit call
% The header is assumed to have been set prior to calling this method
%
    %% Preallocate image data
    switch hTif.getTag('SampleFormat')
        case 1
            imageDataType = 'uint16';
        case 2
            imageDataType = 'int16';
        otherwise
            assert('Unrecognized or unsupported SampleFormat tag found');
    end

    numLines = hTif.getTag('ImageLength');
    numPixels = hTif.getTag('ImageWidth');

    Aout = zeros(numLines,numPixels,numImages,imageDataType);    
    imgInfo.numImages = numImages;	% Only the number of images is reliable
    imgInfo.filename = hTif.FileName;	% As well as the filename, of course
    imgInfo.si_ver = si_ver;	% ScanImage version 

    for idx = 1:numImages
        hTif.setDirectory(idx);
        Aout(:,:,idx) = hTif.read();
    end

    warn('Returning default, uncategorized stream of Tiff frames');
    return
end


%--------------------------------------------------------------------------%
% streamOutputQuit.m                                                       %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%


function s = extractHeaderData(header, verInfo)
    if isfield(header,'SI')
        localHdr = header.SI;
    elseif isfield(header.scanimage,'SI')
        localHdr = header.scanimage.SI;
    else
        assert(false);  % We no longer support the original SI5 format
    end

    % If it's any of the currently supported SI2015 versions 
    if verInfo.infoFound
        s.savedChans = localHdr.hChannels.channelSave;
        s.numPixels = localHdr.hRoiManager.pixelsPerLine;
        s.numLines = localHdr.hRoiManager.linesPerFrame;

        if localHdr.hFastZ.enable
            s.numVolumes = localHdr.hFastZ.numVolumes;
            try
                s.numSlices = localHdr.hStackManager.slicesPerAcq;
            catch
                s.numSlices = max(localHdr.hStackManager.numSlices, numel(localHdr.hStackManager.zs));
            end
            s.numFrames = 1;

            % Assuming that we only have discard frames during FastZ acquisitions
            s.discardFlybackframesEnabled = localHdr.hFastZ.discardFlybackFrames;
            s.numDiscardFrames = localHdr.hFastZ.numDiscardFlybackFrames; 
            s.numFramesPerVolume = localHdr.hFastZ.numFramesPerVolume;  %Includes flyback frames
        else
            s.numVolumes = 1;
            s.numFrames = localHdr.hStackManager.framesPerSlice;
            try
                s.numSlices = localHdr.hStackManager.slicesPerAcq;
            catch
                s.numSlices = localHdr.hStackManager.numSlices;
            end
            s.discardFlybackframesEnabled = false;
            s.numDiscardFrames = localHdr.hFastZ.numDiscardFlybackFrames;    
            s.numFramesPerVolume = localHdr.hFastZ.numFramesPerVolume;  %Includes flyback frames
        end

        % NOTE: This assumes you are using tiff files generated on non-simulated
        %       mode. In this case, non-FastZ tiff files seem to differ between these modes
        if s.numSlices > 1
            s.numFrames = 1;
        end
    else
        assert(false);
    end
end



%--------------------------------------------------------------------------%
% extractHeaderData.m                                                      %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
function selection = selectImages(vararguments,selectionFlags, numItems, flags, flagIndices)
    if any(ismember(selectionFlags,flags))
        selection = getArg(vararguments,selectionFlags, flags, flagIndices);
        %Handle 'inf' specifier in slice array
        if find(isinf(selection))
            selection(isinf(selection)) = [];
            if max(selection) < numItems
                selection = [selection (max(selection)+1):numItems];
            end
        end
        if max(selection) > numItems
            error('Frame, slice or volume values specified are not found in file');
        end
    else
        selection = 1:numItems;
    end
end


%--------------------------------------------------------------------------%
% selectImages.m                                                           %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
function fileHeader = decodeHeaderLines(rows)
    for idxLine = 1:numel(rows)
        % deal with nonscalar nested structs/objs
        pat = '([\w]+)__([0123456789]+)\.';
        replc = '$1($2).';
        row = regexprep(rows{idxLine},pat,replc);

        % handle unencodeable value or nonscalar struct/obj
        unencodeval = '<unencodeable value>';
        if strfind(row,unencodeval)
            row = strrep(row,unencodeval,'[]');
        end

        % Handle nonscalar struct/object case
        nonscalarstructobjstr = '<nonscalar struct/object>';
        if strfind(row,nonscalarstructobjstr)
            row = strrep(row,nonscalarstructobjstr,'[]');
        end

        % handle ND array format produced by array2Str
        try
            if ~isempty(strfind(row,'&'))
                equalsIdx = strfind(row,'=');
                [dimArr,rmn] = strtok(row(equalsIdx+1:end),'&');
                arr = strtok(rmn,'&');
                arr = reshape(str2num(arr),str2num(dimArr)); %#ok<NASGU,ST2NM>
                eval([row(1:equalsIdx+1) 'arr;']);
            else
                eval([row ';']);
            end
        catch ME %Warn if assignments to no-longer-extant properties are found
            equalsIdx = strfind(row,'=');
            if strcmpi(ME.identifier,'MATLAB:noPublicFieldForClass')
                warnMsg = sprintf(1,'Property ''%s'' was specified, but does not exist for class ''%s''\n', deblank(row(3:equalsIdx-1)),class(s));
                warn(warnMsg);
            else
                warn('Could not decode header line: %s', row);
            end
            continue;
        end

        % Eval if there is a value to assign
        if ~isempty(row)
            eval(['fileHeader.' row ';']);
        end
    end
end



%--------------------------------------------------------------------------%
% decodeHeaderLines.m                                                      %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
function warn(varargin)
    warnst = warning('off','backtrace');
    warning(varargin{:});
    warning(warnst);
end



%--------------------------------------------------------------------------%
% warn.m                                                                   %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
function dispError(varargin)
% DISPERROR  Show an error to the user without throwing one 
%   The main purpose of this function is to allow itself to be overriden by 
%   a testing framework. 
%   fprintf(2,...) only displays an error but does not throw any, at least on Windows,
%   This function will replace all those instances to allow tests to catch such messages
%   but still allow the user to run most of the code without halting the program.

    assert(~isempty(varargin) && ischar(varargin{1}));
    if isempty(regexp(varargin{1},'\\n$', 'once'));
        varargin{1} = [varargin{1},'\n'];
    end    
    fprintf(2, varargin{:});
end

%--------------------------------------------------------------------------%
% dispError.m                                                              %
% Copyright © 2016 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2016 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%
