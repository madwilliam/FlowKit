% hTif = Tiff(fileName);
% [fileHeader, frameDescs] = getHeaderData(hTif);


function numFrames=get_proper_frame_number(Filename)
tifObj = Tiff(Filename);
[fileHeader, frameDescs] =getHeaderData(tifObj);
numImages=numel(frameDescs);
numChans=size(fileHeader.SI.hChannels.channelSave,1);
numFrames = floor(numImages/numChans);  

end

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

