function pmtToTiff( basename, pmt_loc, autoCropDir, save_fulltiff )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&%%%%%%%
% Speak softly and carry a big tiff %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_fullTiff=0;
if nargin<4
    save_fullTiff=1;
end

%-----------------------------------%
%   Getting MetaData information:   %
%-----------------------------------%

meta_text=readtable( append( pmt_loc, basename, '.meta.txt' ) ,'Delimiter','=');

% Spatial Pixels:
spatialPixels=meta_text(endsWith(meta_text.Var1,'SI.hScan2D.lineScanSamplesPerFrame'),:);
spatialPixels=cellfun(@str2num,spatialPixels.Var2);

% Number of Saved Channels
channels=meta_text{endsWith(meta_text.Var1,'SI.hChannels.channelSave'),:};
channels=regexp(channels{1,2},'\d*','Match');
channels=numel(channels);

% Sampling Rate
sampleRate=meta_text(endsWith(meta_text.Var1,'SI.hScan2D.sampleRate'),:);
sampleRate=cellfun(@str2num,sampleRate.Var2);

% Frame Rate
frameRate=meta_text(endsWith(meta_text.Var1,'SI.hRoiManager.scanFrameRate'),:);
frameRate=cellfun(@str2num,frameRate.Var2);
framePeriod=1/frameRate;

% Line Duration & Pixels
lineFunctionsRow=find(contains(meta_text.Var1,'scanimage.mroi.stimulusfunctions.line')==1);
lineDuration=extractBetween(meta_text{lineFunctionsRow+5,1},':',',');
lineDuration=str2num(lineDuration{1,1});
linePixels=lineDuration*sampleRate;

%%

%------------------------------%
%   Creating Matrix from PMT   %
%------------------------------%   
pname= append( pmt_loc, '\', basename,'.pmt.dat');
pDir=dir(pname);
A=fopen( pname, 'r' );
Askip=fread(A,[spatialPixels,(pDir.bytes/(2*spatialPixels))],'*int16',(channels-1)*2);
Askip=im2uint16(Askip);

if size(Askip,1)~=0
    if numel(Askip)*2<(2^31)
        pauseFunctionsRow=find(contains(meta_text.Var1,'stimulusfunctions.pause')==1);
        if pauseFunctionsRow < lineFunctionsRow %i.e. pause occurs 1st, should count these to make sure not more than 1
            cropped=Askip(spatialPixels-(linePixels*.95)+1:spatialPixels-linePixels*.05,:);
        else
            cropped=Askip(linePixels*.05:linePixels*.95,:);
        end
        cropped=imadjust(cropped);
        cropped=medfilt2(cropped);    
        imwrite(cropped,append(autoCropDir, basename,'.tif'));
        zz2Top=1;
    else
        % Add error message: "file too big" to errorLog
        disp(' File too large');
    end    
end
%     delete(gcp('nocreate'));
