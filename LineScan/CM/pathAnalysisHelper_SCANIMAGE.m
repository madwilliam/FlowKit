function [OutputSt, structsavename] = pathAnalysisHelper_SCANIMAGE(analysisObjectMulti,output_name)

% Stand-alone function for calculating the diameter, intensity, and radon
% of .scanimage data from two photon scanning
% program is a helper function of arbitrary scan and associated programs
% (PathAnalysisGUI_SCANIMAGE, etc.)
% the analysisObjectMulti is a datastructure, specifying the
% information needed to do an analysis of multiple instances
% CON==1 when you are calling from the GUI directly
%
% results=pathAnalysisHelper_SCANIMAGE(handles.dataStructArray,handles.pmt_data)
% syntax
% analysisObject=datastruct


% to put back

%UPDATE WITH SCAN IMAGE 
pathlocc= which ('pathAnalyzeGUI_SCANIMAGE');
[pathlocc,~,~] = fileparts(pathlocc) ;
if isempty (findstr(pathlocc,'/')) % for PC
  punctuation= '\';
else
  punctuation= '/';
end

addpath([pathlocc punctuation 'private'  punctuation 'Scanimage']);

tic

analysisObject=analysisObjectMulti {1}; % to keep constant for each datastruct in the datastructarray
if nargin==1
    
fullFileNameMpd        = analysisObject.fullFileNameMpd;
[~ , structsavename]   = fileparts(fullFileNameMpd);
structsavename         = strrep(structsavename,' ', '_');
structsavename         = ['OUT_' structsavename];
clear 'analysisObject';
else
    structsavename=output_name;
end
exists_already = evalin('base',['exist(''' structsavename ''')']);
if (exists_already)
    [structsavename]=CM_FETCH_THE_STRING ('the structure already exists, get a new name',structsavename);
end

for dataStruct_counter = 1:length(analysisObjectMulti)
    analysisObject=analysisObjectMulti {dataStruct_counter}; % keep the analysed file constant for each datastruct in the datastructarray
    fullFileNameMpd        = analysisObject.fullFileNameMpd;
    
    % specific for each datastruct
    firstIndexThisObject   = analysisObject.firstIndexThisObject;
    lastIndexThisObject    = analysisObject.lastIndexThisObject;
    assignName             = analysisObject.assignName;
    windowSize             = analysisObject.windowSize;
    windowStep             = analysisObject.windowStep;
    analysisType           = analysisObject.analysisType;
    imageCh                = analysisObject.imageCh;
    im_Ch_ind              = analysisObject.im_Ch_ind;
    scanData               = analysisObject.scanData;
    dt                     = scanData.dt;                % pixel clock
    [~, pmt_data, ~, ~]    = readLineScanDataFiles_PATHGUI(fullFileNameMpd,im_Ch_ind);
    nPointsPerLine         = size(pmt_data,1);                      % points (pixels) each scan line

    
    nLines                 = size(pmt_data,3);    % total number of lines in data
    UmPerDegree            = analysisObject.UmPerDegree;
    assignName(assignName == ' ') = '_';
    assignName(assignName == '-') = '_';
    if strcmp (analysisType,'diameter')
        DiamSmoothing          = analysisObject.DiamSmoothing;
        DiaTypeAnalysis        = analysisObject.DiaTypeAnalysis;
        DiaInvertImage         = analysisObject.DiaInvertImage;
        ThresholdRatio         = analysisObject.ThresholdRatio;
        SaturationLevel        = analysisObject.SaturationLevel; % =2000
        SaturationPercent      = analysisObject.SaturationPercent; % =0.5;
        SaturationCorrection   = analysisObject.SaturationCorrection;
        im_Correction_Ch_ind   = analysisObject.im_Correction_Ch_ind;
        
        if (SaturationCorrection==1)
            if ~(im_Correction_Ch_ind==0)
                [~,analog_4, ~, ~] = readLineScanDataFiles_PATHGUI(fullFileNameMpd,im_Correction_Ch_ind); % CM added to check
              % figure;plot(analog_4 (:))
%                analog_4(analog_4>-10)=4000;
%                 analog_4(analog_4<=-10)=0;
                analog_4(analog_4>-10)=4000;
                analog_4(analog_4<=-10)=0;
                pmt_data=pmt_data+analog_4;
                clear analog_4
            end
        end
    end
    
    pmt_data                = squeeze(pmt_data)'; % saves only the channel in use
    format long
    timePerLine            = nPointsPerLine * dt            % time spent scanning each line
    thetaRange             = [0:179.5];
    
    degPerCol = (analysisObject.scanVelocity)* dt;           % in (deg/s)* (s/pix) = deg/pix
    
    %% creating time blocks to analyse
    disp(['calculating ' analysisType '(displaying percent done) ...'])
    
    nLinesPerBlock             = round(windowSize / (nPointsPerLine * dt));   % how many lines in each block?
    windowStartPoints          = round(1:windowStep / (nPointsPerLine * dt) : nLines-nLinesPerBlock);  % where do the windows start (in points?)
    
    if strcmp(analysisType,'radon')
        AnalysisDataTheta      = 0*windowStartPoints;
        AnalysisDataSep        = 0*windowStartPoints;  % holds the separation (only needed for Radon)
    end
    
    if strcmp(analysisType,'diameter')
        point1_vector          = 0*windowStartPoints;% create space to hold data for the left limit of the vessel
        point2_vector          = 0*windowStartPoints;% create space to hold data for the right limit of the vessel
        AnalysisDataDiam       = 0*windowStartPoints;
    end
    
    Dark_Max                   = 0*windowStartPoints;
    DarkMeanInt                = 0*windowStartPoints;
    Max_intensityData          = 0*windowStartPoints;
    AnalysisIntensity          = 0*windowStartPoints;
    %% loop through the data, calculating relevant variable creating blocks to analyse
    nchar=fprintf('it starts:');
    
    for i = 1:length(windowStartPoints)
        if ~mod(i,round(length(windowStartPoints)/50))
            fprintf(repmat('\b',1,nchar))
            string_to_display = ['' num2str(round(100*i/length(windowStartPoints))),' percent ', num2str(windowStartPoints(i)) ' lines out of ' num2str(windowStartPoints(end))];
            nchar             = fprintf(string_to_display);
        end
        
        w = windowStartPoints(i);         % which line to start this window?
        LineMin                 = w;
        LineMax                 = w-1+nLinesPerBlock;
        blockData_to_use        = pmt_data(LineMin:LineMax,:);
        blockDataMean_lat       = mean(blockData_to_use',1); % replaces  blockDataMean_lat= mean(blockData_to_use,2) to be 40 times faster     CM_20161208
        blockDataMean_lat       = blockDataMean_lat';% replaces  blockDataMean_lat= mean(blockData_to_use,2) to be 40 times faster     CM_20161208
        Max_intensityData (i)   = max(blockDataMean_lat(:));   % take the max (of the mean per line)

        blockDataCut            = pmt_data(LineMin:LineMax,firstIndexThisObject:lastIndexThisObject);
        
        blockDataMean           = mean(blockDataCut,1);   % take mean of several lines imageCh == 1
        AnalysisIntensity(i)    = mean(blockDataMean(:));
        DarkMeanInt (i)         = mean(blockDataMean(1:min(10,size(blockDataCut,2))));
        Dark_Max(i)             = max(max(blockDataCut(:,1:min(10,size(blockDataCut,2)))));
        
        if strcmp(analysisType,'diameter')
            if (SaturationCorrection==1)
                        % for selection on the entire line
                        temp_block         = CM_transform_in_NAN(blockData_to_use,SaturationLevel,SaturationPercent/100);
                        temp_block         = temp_block (:,firstIndexThisObject:lastIndexThisObject);
                        % Correction only for the small portion
                       %  temp_block         = CM_transform_in_NAN(blockDataCut,SaturationLevel,SaturationPercent/100);
                       % temp_block         = CM_transform_in_NAN(temp_block,SaturationLevel,SaturationPercent/100);
                         Max_intensityData (i)   = max(temp_block(:));   % take the max (of the mean per line)

                if (i==10411)
                    %figure;imagesc(temp_block)
                end
                temp_block_mean    = nanmean(temp_block,1);
            end
        end
        if(i==1)
            assignin('base','b1',blockDataCut);
        end
        
        if strcmp(analysisType,'diameter')
            if (DiaInvertImage)
                ratio_block = -1;
            else
                ratio_block = 1;
            end
            
            if (SaturationCorrection==1)
                %                  if (i>1210)
                %
                %             end
                [AnalysisDataDiam(i), point1_vector(i) , point2_vector(i), block]  = calcFWHMScanimage(ratio_block.*temp_block_mean,DiamSmoothing,ThresholdRatio,DiaTypeAnalysis); %CM 20131206 to work with light
            else
                [AnalysisDataDiam(i) , point1_vector(i) , point2_vector(i), block] = calcFWHMScanimage(ratio_block.*blockDataMean,DiamSmoothing,ThresholdRatio,DiaTypeAnalysis);
            end
            if w==1
                BigMatrix   = zeros (length(windowStartPoints),size(block,2));
            end
            
            BigMatrix (i,:) = block;
            
        elseif strcmp(analysisType,'radon')
            % blockDataCut=(double(blockDataCut+min(blockDataCut(:)))).^2;
            
            thetaAccuracy       = .01;
            temp_correction     = mean(blockDataCut,1);
            if analysisObject.CorrectAverageVelocity
                tempblockDataCut      =double(blockDataCut)-repmat(temp_correction,(size(blockDataCut,1)),1); % useful in case of bright lines
                [theta , sep]         = radonBlockToTheta(tempblockDataCut,thetaAccuracy,thetaRange);
            else
                [theta , sep]         = radonBlockToTheta(blockDataCut,thetaAccuracy,thetaRange);
            end
            AnalysisDataTheta(i)      = theta;
            AnalysisDataSep(i)        = sep;  % look around previous value for theta
            % this speeds things up, but can also cause the data to "hang"
            % on incorrect values
            %thetaRange = [theta-10:theta+10];
        end
    end
    
    
    %% post-processing, if necessary
    time_axis                               = windowSize/2 + windowStep*(0:length(AnalysisIntensity)-1);    % make a time axis that matcheds the diameter info
    OutputSt {dataStruct_counter}.([assignName '_time_axis'])    = time_axis;
    OutputSt {dataStruct_counter}.dataStructArray                = analysisObjectMulti;
    OutputSt {dataStruct_counter}.scanData                       = scanData; 
    
    
    if strcmp(analysisType,'radon')
        % convert this to a more usable form
        %   (timePerLine) holds vertical spacing info
        %   (scanVelocity*1e3) is distance between pixels (in ROIs), in mV
        %    note that theta is actually reported angle from vertical, so
        %    vertical lines (stalls) have theta of zero
        %    horizontal lines (very fast) have theta of 90
        %    (angle is measured ccw from vertical)
        %  degPerColis related to distance ran between 2 pixel
        %
        %            cols    degPerCol     row          deg
        %  tand() =  ---- * --------  * ----------  =  ---
        %            row      col       timePerLine     sec
        %
        % the units of deg/sec can be converterd into a speed by noting that mv
        % corresponds to a distance
        
        % speedData = (tand(analysisData)) * mvPerCol / secsPerRow;    % note this is taken in degrees
        speedData_pix = (tand(AnalysisDataTheta)) / timePerLine;    % note this is taken in degrees
        speedData = (tand(AnalysisDataTheta)) * degPerCol / timePerLine;    % note this is taken in degrees
        
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_radon_pix_per_s'])=speedData_pix;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_radon_deg_per_s'])=speedData;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_radon_um_per_s'])=speedData*UmPerDegree;
        
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_radon_theta'])=AnalysisDataTheta;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_radon_sep'])=AnalysisDataSep;
        figure (999); plot (time_axis,speedData*UmPerDegree)
        xlabel ('Time (sec)')%
        ylabel ('Velocity (um/sec)')%

    elseif strcmp(analysisType,'diameter')
        figure (999); plot (time_axis,AnalysisDataDiam*degPerCol*UmPerDegree)
        xlabel ('Time (sec)')%
        ylabel ('Diameter (um)')%
        AnalysisDataDiam       = AnalysisDataDiam ;     % convert units (currently in pixels) to millivolts
        midline                = (point2_vector+point1_vector)/2;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_diameter_pix'])=AnalysisDataDiam;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_diameter_deg'])=AnalysisDataDiam*degPerCol;   % mv / second
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_diameter_um'])=AnalysisDataDiam*degPerCol*UmPerDegree;   % mv / second
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_MAX_int'])=Max_intensityData;   % mv / second
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_point1_vector']) =point1_vector;   % index/sec
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_point2_vector'])=point2_vector;   % index/sec
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_midline_vector'])=midline;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Mean_int'])=AnalysisIntensity;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Dark_Mean_int'])=DarkMeanInt;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Dark_Max_Int'])=Dark_Max;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_big_matrix'])=BigMatrix;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_SaturationCorrection'])=SaturationCorrection;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_SaturationLevel'])=SaturationLevel;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_SaturationPercent'])=SaturationPercent;
        
    else
        figure (999); plot (time_axis,AnalysisIntensity)
        xlabel ('Time (sec)')%
        ylabel ('Brightness')%
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_MAX_int'])=Max_intensityData;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Mean_int'])=AnalysisIntensity;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Dark_Mean_int'])=DarkMeanInt;
        OutputSt {dataStruct_counter}.([assignName '_' 'ch' num2str(imageCh) '_Dark_Max_Int'])=Dark_Max;
    end
           
    disp ' ... DONE'
    pause(.001);  % short pause is needed to show the variables that were put on the base space
end

CM_PATH_ANALYSIS_PLOT_FROM_STR(OutputSt);
CM_PATH_ANALYSIS_PLOT_FROM_STR_CTR(OutputSt)
assignin ('base',structsavename,OutputSt); 
CM_STR_ARRAY_TO_WS (OutputSt);
disp (['BATCH DONE saved as ' structsavename])

toc



function [width, point1 , point2 , data] = calcFWHMScanimage(data,smoothing,threshold_ratio,method)
% function which takes data and calculates the full-width, half max value
% half-max values are found looking in from the sides, i.e., the program will work
% even if the data dips to a lower value in the middle

point1 = []; point2 = [];

data = double(data);
if smoothing > 1
    data            = conv(data,rectwin(smoothing)./ smoothing);
    baseline_to_sub = min(data(smoothing:(length(data)-smoothing)));
else
    baseline_to_sub = min(data(:));
end

data = data-baseline_to_sub;

if isempty(threshold_ratio)
    threshold_ratio = 3;% changed from 2 to 4
end
threshold   = max(data)/threshold_ratio; % changed from 2 to 4 BY

if strcmp (method, 'From sides')
aboveI      = find(data > threshold);    % all the indices where the data is above half max
if isempty(aboveI) % nothing was above threshold!
    width = 0;point1=0;point2=0;
    return
end
firstI  = aboveI(1);                 % index of the first point above threshold
lastI   = aboveI(end);                % index of the last point above threshold

    if (firstI-1 < 1) | (lastI+1) > length(data)
        width = 0;point1=0;point2=0;
        return
    end
    
    point1offset = (threshold-data(firstI-1)) / (data(firstI)-data(firstI-1)); % linear interp
    point2offset = (threshold-data(lastI)) / (data(lastI+1)-data(lastI));
    point1       = firstI-1 + point1offset;
    point2       = lastI + point2offset;
    width        = point2-point1;
    
    
end
%%

if strcmp (method, 'From center')
    aboveI      = find(data < threshold);    % all the indices where the data is above half max
    vessel_mid_to_look   = length(data)/2;     % put a condition to make sure that there are point above and below
    data_right           = aboveI(find (aboveI>vessel_mid_to_look));
    data_left            = aboveI(find (aboveI<vessel_mid_to_look));
    
    if (isempty(data_left) | isempty(data_right))
        width = 0; point1 = 0; point2 = 0;
        return
    else
        lastI    = data_right(1) ;                % index of the first point above threshold
        firstI   = data_left(end);               % index of the last point above threshold
    end
    
    if (firstI-1 < 1) | (lastI+1) > length(data)
        width = 0;point1 = 0; point2 = 0;
        return
    end
    
    if (data(firstI+1)>threshold)&&(data(firstI-1)<data(firstI))
        point1offset = (threshold-data(firstI+1)) / (data(firstI)-data(firstI+1));
    else
        point1offset=0;
    end
    if (data(lastI)<threshold)&&(data(lastI-1)>data(lastI))
        point2offset = (threshold-data(lastI)) / (data(lastI)-(data(lastI-1)));
    else
        point2offset = 0;
    end
       
    point1  = firstI+1- point1offset;
    point2  = lastI+ point2offset;
    width   = point2-point1;
end


function CM_structure_to_vector(STRUCTURE_NAME)
names=fieldnames(STRUCTURE_NAME);
for i=1:size(names,1)
    f=getfield(STRUCTURE_NAME,char(names(i)));
    assignin('base',[char(names(i))],f);
end

function [theta sep] = radonBlockToTheta(block,thetaAccuracy,thetaRange)
% function takes a block of data (typically a stack of linescans across the relevant part of a vessel)
% and returns the angle (theta, in degrees) from vertical of the streaks in that block
%   vertical lines will have a theta of 0, and
%   horizontal lines will have a theta of 90
%   (the radon transform is in degrees)
%
% sep is the separability, which is defined as the (max variance)/(mean variance)
% over the thetaRange
%
% uniformity correction
%  if the block of data is not uniform (i.e., brigher to one side or the other)
%  the Radon transform will tend to see this as a stack of vertical lines
%  the solution is to fit a low-order polynomial (typically 2nd order) to
%  the mean intensity along the horizonatal axis, and subtarct this from
%  the image
uniformityCorr = 3;     % 0 is none, 1 through 4 are polynomial degrees, and -1 uses the mean

% set a value for the range of thetas, if one was not passed in
if ~exist('thetaRange','var')
    thetas = 1:179;
else
    thetas = min(thetaRange):max(thetaRange);
end

% set a value for the accuracy, if one was not passed in
if ~exist('thetaAccuracy','var')
    thetaAccuracy = .05;
end

% check to make sure size is correct
if ndims(block) ~= 2 || size(block,1) < 2 || size(block,2) < 2
    error 'function radonBlockToTheta only works with 2d matrices'
end

block = double(block);              % make sure this is a double
block = block - mean(block(:));     % subtract off mean

degree = uniformityCorr;

blockMean = mean(block,1);
xaxis = 1:length(blockMean);

if degree == -1
    blockMeanFit = mean(block,1);         % use the mean
elseif degree == 0
    blockMeanFit = 0*xaxis;               % don't subtract anything out
else
    % use a polynomial
    p = polyfit(xaxis,blockMean,degree);
    if degree == 1
        blockMeanFit = p(1)*xaxis + p(2);   % first order correction
    elseif degree == 2
        disp 'gets to here'
        blockMeanFit = p(1)*xaxis.^2 + p(2)*xaxis + p(3);  % second order correction
    elseif degree == 3
        blockMeanFit = p(1)*xaxis.^3 + p(2)*xaxis.^2 + p(3)*xaxis + p(4);  % second order correction
    elseif degree == 4
        blockMeanFit = p(1)*xaxis.^4 + p(2)*xaxis.^3 + p(3)*xaxis.^2 + p(4)*xaxis + p(5);  % second order correction
    end
end

% remove
for i = 1:size(block,1)
    block(i,:) = block(i,:) - blockMeanFit;
end

block = block - mean(block(:));  % make sure mean is still zero

%% now, do the radon stuff
% initial transform, over entire theta range
rb = radon(block,thetas);            % take radon transform

vrb = var(rb);                       % look at the variance

%plot(vrb)
%plot(blockMeanFit)
%pause

vrbMean = mean(vrb);                 % the mean of the variance, used for sep

maxVarIndex = find(vrb==max(vrb));   % find where the max took place
% note this could be more than one place!

thetaInitial = thetas(round(mean(maxVarIndex)));        % theta, accuarate to within 1 degree

% we now have a rough idea of the angle, search with higher accuracy around this point
searchAroundDegrees = 1.5;                              % number of degrees to search around answer
thetas_highRes = thetaInitial-searchAroundDegrees: ...
    thetaAccuracy: ...
    thetaInitial+searchAroundDegrees;              % new set of thetas - smaller range, more accurate

rb_highRes = radon(block,thetas_highRes);
vrb_highRes = var(rb_highRes);                          % look at the variance

maxVarIndex_highRes = find(vrb_highRes==max(vrb_highRes));      % find the indices of the max - could be more than one!
theta = mean(thetas_highRes(maxVarIndex_highRes));              % theta, high accuracy

sep = mean(vrb_highRes(maxVarIndex_highRes)) / vrbMean;



function [FETCHED_STRING]=CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
% this function calls the prompt and returns a string (sAnswer)
% CM_FETCH_THE_STRING (STRING_TO_FETCH,defstring)
prompt = {STRING_TO_FETCH};
dlg_title = ['Enter ' STRING_TO_FETCH];
num_lines = 1;
FETCHED_STRING = inputdlg(prompt,dlg_title,num_lines,{defstring});
FETCHED_STRING=FETCHED_STRING(1);
FETCHED_STRING=(FETCHED_STRING{:});

   % CM 20131206 code to detect the lines that have more than x saturated
   % pixel and extract set the lines to nan
   % 65535 for images from 
function temp_block=CM_transform_in_NAN(block,threshold_saturation,fraction_of_saturating_pix)
        tac_nan=block>threshold_saturation;
        block_width=size(block,2);
        tac_sum = full(sum(sparse(tac_nan),2)); % logical vector CM change to sparse 20140401
       
        number_of_saturated_pixel=fraction_of_saturating_pix*(block_width);
        
        tac_nan=tac_sum>=number_of_saturated_pixel;
        temp_block=double(block);
        temp_block(tac_nan,:)=nan;
        
%         size (block,1)
%         tac_rep=repmat(1,size(block,2));
%         temp_block= block+tac_rep;

