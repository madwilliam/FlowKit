function varargout = pathAnalyzeGUI_SCANIMAGE(varargin)
% Celine Mateo 2017 GUI to analyse the data scanned with SCANIMAGE
% previously improved for MPSCOPE2, now adapted for Scanimage Vidrio by
% Based on previous GUI Jon Driscoll, Pat Drew, Phil Tsai

% To add
% path from scanimage
% plot path
% plot output

% Last Modified by GUIDE v2.5 02-Jun-2017 14:53:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @pathAnalyzeGUI_SCANIMAGE_OpeningFcn, ...
    'gui_OutputFcn',  @pathAnalyzeGUI_SCANIMAGE_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pathAnalyzeGUI_SCANIMAGE is made visible.
function pathAnalyzeGUI_SCANIMAGE_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;  % Choose default command line output for pathAnalyzeGUI

% user code here ...
handles.scanData = [];            % data from MATLAB, initialize to empty
handles.scanResult3d = [];        % data from mpscope, initialize to empty
handles.scanResult2d = [];        % data from mpscope, initialize to empty
handles.scanResult1d = [];        % data from mpscope, initialize to empty

handles.syst_check= which ('pathAnalysisHelper_SCANIMAGE');

if isempty (findstr(handles.syst_check,'/')) % for PC
    handles.punctuation= '\';
else
    handles.punctuation= '/';
end
handles.fileDirectory = ['.' handles.punctuation];     % initial file directory
%handles.fileDirectory = '';     % initial file directory CM_changed 20190724 for MAC
handles.fileNameMat = '';         % holds name of Matlab file
handles.fileNameMpd = '';         % holds name of Mpd file
% handles.imageCh = 1;              % holds imaging channel to load
% selected with pop-up, but default to 1
% handles.imageChMap = 1;              % holds imaging channel to load
% selected with pop-up, but default to 1

% handles.analyseLater = false;
handles.analyseLaterFilename = '';     % fid to write structures to analyse later
handles.displaymode='Show_continuous_Callback';

set(gcf,'name','pathAnalyzeExtraGUI_Scanimage v0.4')
set(gcf,'toolbar','figure');
set(gcf,'menubar','figure');
pathlocc= which ('pathAnalyzeGUI_SCANIMAGE');
[pathlocc,~,~] = fileparts(pathlocc) ;
addpath([pathlocc handles.punctuation 'private'  handles.punctuation 'Scanimage']);

guidata(hObject, handles); % Update handles structure


% UIWAIT makes pathAnalyzeGUI_SCANIMAGE wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = pathAnalyzeGUI_SCANIMAGE_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;


%% PUSH BUTTONS

% --- BUTTON - Draw Scan Path
function pushButtonDrawScanPath_Callback(hObject, eventdata, handles)
% check to make sure data was loaded
if isempty( handles.scanResult1d )
    warndlg( 'oops, it appears that a .mpd (MpScope) file was not loaded ...')
    return
end

if isempty( handles.scanData )
    warndlg( 'oops, it appears that a .mat (MATLAB) file was not loaded ...')
    return
end

sr1 = handles.scanResult1d;          % 'scan result 1d'
path = handles.scanData.path;        % 'scan path'

if size(sr1,1) ~= size(path,1)
    warndlg( 'oops - path length from matlab and MPD file do not match!')
    return
end

% plot the scan path here ...
set(handles.figure1,'CurrentAxes',handles.axesMainImage)
nPoints = size(path,1);
hold on

% scale the scan result for 0 to 1
sr1scaled = sr1;
sr1scaled = sr1scaled - min(sr1scaled);
sr1scaled = sr1scaled ./ max(sr1scaled);

%colormap(reverse(gray))
%colormap('default')
%colormap(gray);

%C = flipud(colormap);
%C = flipup(get(gca,'colormap'));
%colormap(C);
%set(gca,'colormap',C')

drawEveryPoints = 100;

set(handles.figure1,'CurrentAxes',handles.axesMainImage)

for i = 1:drawEveryPoints:nPoints      % skip points, if the user requests
    
    %color = hsv2rgb([i/nPoints,1,1]);
    %color = hsv2rgb([0,0,sr1scaled(i)]);        % plot intensity, black and white
    %color = [sr1scaled(i),0,0]                   % plot intensity as RED
    %color = [sr1scaled(i)/3 , sr1scaled(i) , sr1scaled(i)/3]                  % plot intensity as RED
    
    color = 'white';
    plot(path(i,1),path(i,2),'.','markersize',4,'color',color)
    drawnow
end

% find the values from the image and the ideal path
nRows = size(handles.scanData.im,1);
nCols = size(handles.scanData.im,2);

sr1im = 0*sr1;      % will hold the scan result, scanning ideal path across image

% scale voltage coordinates to matrix coordinates
xMinV = handles.scanData.axisLimCol(1);
xMaxV = handles.scanData.axisLimCol(2);
yMinV = handles.scanData.axisLimRow(1);
yMaxV = handles.scanData.axisLimRow(2);

% Ilya's corrections for scaling
%the +1 term is to account that we start at 1st pixel (not 0) but we end at
% nCol-1+1 pixel. Same for row. Checked with 512x512, 400x400, and 400x256
pathImCoords(:,1) = (nCols-1)*(path(:,1)-xMinV)/(xMaxV- xMinV)+1;
pathImCoords(:,2) = (nRows-1)*(path(:,2)-yMinV)/(yMaxV- yMinV)+1;

imMarked = handles.scanData.im (:,:,handles.imageCh);
markIntensity = max(imMarked(:)) * 1.1;

for i = 1:nPoints
    try
        c = round(pathImCoords(i,1));   %jd - note c comes before r!
        r = round(pathImCoords(i,2));
        imMarked(r,c) = markIntensity;
        sr1im(i) = handles.scanData.im(r,c,handles.imageCh);
    catch
        if ~isnan(r*c)
            disp('Point out of bounds');
        end
    end
end

% scale so that data from image matches data acquired from arbs scan ... generally not needed
sr1im = sr1im/mean(sr1im) * mean(sr1);

% plot some values

figure

plot( [sr1im sr1] )
legend('from image','from arb scan')

guidata(hObject, handles);         % Update handles structure (save the image)

pathImCoords(:,1) = path(:,1) * (nRows-1)/(xMaxV- xMinV) + 1 - (nRows-1)/(xMaxV - xMinV)*xMinV;
pathImCoords(:,2) = path(:,2) * (nCols-1)/(yMaxV- yMinV) + 1 - (nCols-1)/(yMaxV - yMinV)*yMinV;

imMarked = handles.scanData.im;
markIntensity = max(imMarked(:)) * 1.1;

% for i = 1:nPoints
%     c = round(pathImCoords(i,1));   %jd - note c comes before r!
%     r = round(pathImCoords(i,2));
%
%     imMarked(r,c) = markIntensity;
%
%     sr1im(i) = handles.scanData.im(r,c);
% end

% scale so that data from image matches data acquired from arbs scan ... generally not needed
sr1im = sr1im/mean(sr1im) * mean(sr1);

% plot some values

%     figure % commented CM 20130627
%     subplot(2,2,1:2)
%     plot( [sr1im sr1] )
%     legend('from image','from arb scan')

guidata(hObject, handles);         % Update handles structure (save the image)


% --- BUTTON - Reset Image
function pushButtonResetImage_Callback(hObject, eventdata, handles)

if~isfield(handles, 'scanData')
    return
end
set(handles.figure1,'CurrentAxes',handles.axesMainImage)
cla
%% SII_ include_theCHANNEL % Channel set to 1 for the moment
if (isfield(handles, ('scanData')))
    if (isfield(handles.scanData, ('im')))
        imagesc(handles.scanData.axisLimCol,handles.scanData.axisLimRow,handles.scanData.im (:,:,handles.imageChMap));
        set(gca,'fontsize',6)
        axis on
        axis image
        colormap (handles.Colorscale);
        disp 'Image reset'
    end
end

% --- BUTTON - Rename
function pushButtonRename_Callback(hObject, eventdata, handles)
newName = inputdlg('type in new name (or enter to keep old name)');  % newName is a cell

if isempty(newName)
    return   % nothing to rename
end

elementIndex = get(handles.listboxScanCoords,'Value');
handles.scanData.scanCoords(elementIndex).name = newName{1};

%% populate listbox
strmat = [];
for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));

guidata(hObject, handles);                                   % Update handles structure


% --- BUTTON - Diameter Transform
function pushButtonDiameterTransform_Callback(hObject, eventdata, handles)
% Calculate the velocity, using the radon transform

elementIndex            = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject    = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject    = allIndicesThisObject(1);
lastIndexThisObject     = allIndicesThisObject(end);

% let the user change the points, if desired
[firstIndexThisObject, lastIndexThisObject] = ...
    selectLimit(handles,firstIndexThisObject,lastIndexThisObject);

dataStruct                         = [];
dataStruct.fullFileNameMpd         = [handles.fileDirectory handles.fileNameMpd];
dataStruct.firstIndexThisObject    = firstIndexThisObject;
dataStruct.lastIndexThisObject     = lastIndexThisObject;
dataStruct.assignName              = handles.scanData.scanCoords(elementIndex).name;
dataStruct.windowSize              = handles.windowSize;
dataStruct.windowStep              = handles.windowStep;
dataStruct.analysisType            = 'diameter';
dataStruct.scanVelocity            = handles.scanData.scanVelocity(elementIndex);
dataStruct.imageCh                 = handles.imageCh;
dataStruct.im_Ch_ind               = handles.im_Ch_ind;
dataStruct.DiamSmoothing           = handles.DiamSmoothing;
dataStruct.DiaTypeAnalysis         = handles.DiaTypeAnalysis;
dataStruct.ThresholdRatio          = handles.ThresholdRatio;
dataStruct.DiaInvertImage          = handles.DiaInvertImage;
dataStruct.SaturationLevel         = handles.SaturationLevel;
dataStruct.SaturationPercent       = handles.SaturationPercent;
dataStruct.SaturationCorrection    = handles.SaturationCorrection;
dataStruct.scanData                = handles.scanData;
dataStruct.UmPerDegree             = handles.UmPerDegree;
dataStruct.CorrectionChannelString = handles.CorrectionChannelString;

if ~isempty(str2num(handles.CorrectionChannelString)) % if same
    handles.im_Correction_Ch_ind   = find(handles.pmt_header.acqChannels==str2num(handles.CorrectionChannelString));
    if isempty (handles.im_Correction_Ch_ind)
            handles.im_Correction_Ch_ind   = 0;
    end
else
    handles.im_Correction_Ch_ind   = 0;
end
dataStruct.im_Correction_Ch_ind    = handles.im_Correction_Ch_ind;
handles.dataStruct                 = dataStruct;

if handles.analyseLater
    handles.dataStructArray=writeForLater(dataStruct,handles);
    guidata (hObject,handles)
else
    dataStructArray{1}=dataStruct;
    pathAnalysisHelper_SCANIMAGE(dataStructArray) %,handles.pmt_data);
end

%  --- BUTTON - Diameter Transform pushButtonIntensity.
function pushButtonIntensity_Callback(hObject, eventdata, handles)

elementIndex  = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject   = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject   = allIndicesThisObject(1);
lastIndexThisObject    = allIndicesThisObject(end);

% let the user change the points, if desired
%if get(handles.allowResize,'Value')==1 % removed from the GUI 20170601 CM
[firstIndexThisObject, lastIndexThisObject , handles] = ...
    selectLimit(handles,firstIndexThisObject,lastIndexThisObject);
%end

dataStruct=[];
dataStruct.fullFileNameMpd            = [handles.fileDirectory handles.fileNameMpd];
dataStruct.firstIndexThisObject       = firstIndexThisObject;
dataStruct.lastIndexThisObject        = lastIndexThisObject;
dataStruct.assignName                 = handles.scanData.scanCoords(elementIndex).name;
dataStruct.windowSize                 = handles.windowSize;
dataStruct.windowStep                 = handles.windowStep;
dataStruct.analysisType               = 'intensity';
dataStruct.scanVelocity               = handles.scanData.scanVelocity(elementIndex);
dataStruct.imageCh                    = handles.imageCh;
dataStruct.im_Ch_ind                  = handles.im_Ch_ind;
dataStruct.scanData                   = handles.scanData;
dataStruct.UmPerDegree                = handles.UmPerDegree;
handles.dataStruct                    = dataStruct;

if handles.analyseLater
    handles.dataStructArray=writeForLater(dataStruct,handles);
    guidata (hObject,handles)
else
    dataStructArray{1}=dataStruct;
    pathAnalysisHelper_SCANIMAGE(dataStructArray);
end


% --- BUTTON - Radon Transform
function pushButtonRadonTransform_Callback(hObject, eventdata, handles)
% Calculate the velocity, using the radon transform
elementIndex                     = get(handles.listboxScanCoords,'Value');    % grab the selected element

% based on the item selected in the listbox, and the pathObjNum, find
% the start and end indices
allIndicesThisObject             = find(handles.scanData.pathObjNum == elementIndex);
firstIndexThisObject             = allIndicesThisObject(1);
lastIndexThisObject              = allIndicesThisObject(end);

% let the user change the points, if desired
[firstIndexThisObject , lastIndexThisObject , handles] = ...
    selectLimit(handles,firstIndexThisObject,lastIndexThisObject);

dataStruct=[];
dataStruct.fullFileNameMpd            = [handles.fileDirectory handles.fileNameMpd];
dataStruct.firstIndexThisObject       = firstIndexThisObject;
dataStruct.lastIndexThisObject        = lastIndexThisObject;
dataStruct.assignName                 = handles.scanData.scanCoords(elementIndex).name;
dataStruct.windowSize                 = handles.windowSize;
dataStruct.windowStep                 = handles.windowStep;
dataStruct.analysisType               = 'radon';
dataStruct.scanVelocity               = handles.scanData.scanVelocity(elementIndex);
dataStruct.imageCh                    = handles.imageCh;
dataStruct.im_Ch_ind                  = handles.im_Ch_ind;
dataStruct.scanData                   = handles.scanData;
dataStruct.CorrectAverageVelocity     = handles.CorrectAverageVelocity;
dataStruct.UmPerDegree                = handles.UmPerDegree;
handles.dataStruct                    = dataStruct;

if handles.analyseLater
    handles.dataStructArray=writeForLater(dataStruct,handles);
    guidata (hObject,handles)
else
    dataStructArray{1}=dataStruct;
    pathAnalysisHelper_SCANIMAGE(dataStructArray);
end

% --- BUTTON - Draw Scan Regions
function pushButtonDrawScanRegions_Callback(hObject, eventdata, handles)
% note - this code is copied straight from pathGUI, could be a separate function ...
% plot the start and endpoints on the graph, and place text

for i = 1:length(handles.scanData.scanCoords)
    sc = handles.scanData.scanCoords(i);     % copy to a structure, to make it easier to access
    scanpath=handles.scanData.path;
    if strcmp(sc.scanShape,'blank')
        break                       % nothing to mark
    end
    
    % mark start and end point
    set(handles.figure1,'CurrentAxes',handles.axesMainImage)
    hold on
    
    
    % draw a line or box (depending on data structure type)
    if ~strcmp(sc.scanShape,'pause')
        plot(sc.startPoint(1),sc.startPoint(2),'g*')
        plot(sc.endPoint(1),sc.endPoint(2),'r*')
        tt=[sc.indices(1):1:sc.indices(2)];
        
        % plot(scanpath(tt,1),scanpath(tt,2),'r')
        plot(scanpath(tt,1),scanpath(tt,2),'r')
        
    elseif strcmp(sc.scanShape,'pause')
        tt=[sc.indices(1):1:sc.indices(2)];
        plot(scanpath(tt,1),scanpath(tt,2),'w.')
        
        
        % line([sc.startPoint(1) sc.endPoint(1)],[sc.startPoint(2) sc.endPoint(2)],'linewidth',2)
    elseif strcmp(sc.scanShape,'box')
        % width and height must be > 0 to draw a box
        %         boxXmin = min([sc.startPoint(1),sc.endPoint(1)]);
        %         boxXmax = max([sc.startPoint(1),sc.endPoint(1)]);
        %         boxYmin = min([sc.startPoint(2),sc.endPoint(2)]);
        %         boxYmax = max([sc.startPoint(2),sc.endPoint(2)]);
        %
        %         rectangle('Position',[boxXmin,boxYmin, ...
        %             boxXmax-boxXmin,boxYmax-boxYmin], ...
        %             'EdgeColor','green');
    end
    
    % find a point to place text
    placePoint = sc.startPoint + .1*(sc.endPoint-sc.startPoint);
    text_to_add=strrep (sc.name,'line ','L');
    text(placePoint(1)-.1,placePoint(2)+.05,text_to_add,'color','yellow','FontSize',7)
    
end

colormap (handles.Colorscale)

% --- BUTTON - Look ...allows to see the box shape
function pushButtonLook_Callback(hObject, eventdata, handles)
% take the radon transform, would need to call Patrick's code ...
elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element

% the data is held in:
%   handles.scanData.scanResult3d
% marks for what part of the path corresponds to what are in:
%   handles.scanData.pathObjNum

% for the item selected in the listbox, find the start and end indices, and cut out data

% find the indices of this scan object, subject to the constraint that the subObjectNum is non-zero
% subOjectNum being non-zero has no effect for lines, but will cut out turn regions for boxes
%indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);
indices = (handles.scanData.pathObjNum  == elementIndex);

% cut out data, and image first frame ...
%lineData = handles.scanResult3d(:,firstIndexThisObject:lastIndexThisObject,1);
lineData = handles.scanResult3d(:,indices,1);

figure
subplot(4,2,1:4)
imagesc(lineData)

% image projection of first frame
subplot(4,2,5:6)
lineData = mean(lineData,1);
plot(lineData)
a = axis;
axis( [1 length(lineData) a(3) a(4)] )

% cut out only the sub-object portion, and plot this

% find the indices of this scan object, subject to the constraint that the subObjectNum is non-zero
% subOjectNum being non-zero has no effect for lines, but will cut out turn regions for boxes
%indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);
indices = (handles.scanData.pathObjNum  == elementIndex & handles.scanData.pathObjSubNum > 0);

% cut out data, and image first frame ...
%lineData = handles.scanResult3d(:,firstIndexThisObject:lastIndexThisObject,1);
lineData = handles.scanResult3d(:,indices,1);

%
subplot(4,2,7:8)
lineData = mean(lineData,1);
plot(lineData)
a = axis;
axis( [1 length(lineData) a(3) a(4)] )

% --- Executes on button press in allowResize.
function allowResize_Callback(hObject, eventdata, handles)
% hObject    handle to allowResize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- BUTTON--- Executes on button press in PickDatFile.
function PickDatFile_Callback(hObject, eventdata, handles)
% hObject    handle to PickDatFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pmt_data=0;
if ~isfield(handles, 'fileDirectory');handles.fileDirectory = '';end;
[handles.fileNameMpd,handles.fileDirectory] = uigetfile([handles.fileDirectory '*.pmt.dat'],'open file - MATLAB (*.pmt.dat)'); % open file
if isequal(handles.fileNameMpd,0);return;end    % check to make sure a file was selected
handles.fullFileNameMpd     = [handles.fileDirectory,handles.fileNameMpd];
fileExt                     = handles.fileNameMpd(end-7:end);       % make sure selected file was right type
if ~strcmpi(fileExt,'.pmt.dat')
    errordlg('Oops - needs to be an .pmt.dat file')  % not an .dat file
    return
end
handles.fileNameMpd                          = strrep (handles.fileNameMpd,'.pmt.dat','');
fullFileNameMpd                              = strrep (fullfile (handles.fileDirectory,handles.fileNameMpd),'.pmt.dat','');
set(handles.figure1,'Name',['pathAnalyzeGUI ' handles.fileNameMpd]);
%[handles.fileNameTif,handles.fileDirectoryTif] = uigetfile([handles.fileDirectory '*.tif'],'open template image - MATLAB (*.tif)'); % open file
[handles.fileNameTif,handles.fileDirectoryTif] = uigetfile([handles.fileDirectory '*.tif'],'open template image (*.tif)'); % open file
handles.fullfileNameTif                      = [handles.fileDirectoryTif,handles.fileNameTif];
disp ' Loading Data...'
[scanData]                                   = loadpmtdatatostruct_to_scan_data(fullFileNameMpd,handles.fullfileNameTif); % build scan data from header of the file
handles.scanData                             = scanData;                            % place scan data in handles

if isfield(handles,'pmt_data')
handles.pmt_data=[];
end
[handles.pmt_header, handles.pmt_data,handles.scannerPosData, ~] = scanimage.util.readLineScanDataFiles(fullFileNameMpd); % loads the entire data
%handles.scannerPosData=evalin ('base','pathFov');
if isempty(handles.pmt_data)
    warndlg( 'oops, it appears that a .pmt.dat (ScanImage) file was not loaded ...')
    return
end

handles.nPoints                              = handles.pmt_header.numSamples;
handles.nLines                               = handles.pmt_header.numFrames;
handles.nPointsPerLine                       = handles.pmt_header.samplesPerFrame;
handles.timePerLine                          = handles.pmt_header.samplesPerFrame * handles.scanData.dt;
handles.dataMpd.Header.PixelClockSecs        = 1/handles.pmt_header.sampleRate;
handles.im_Ch_ind                            = find(handles.pmt_header.acqChannels==handles.imageCh);

if ~isempty(str2num(handles.CorrectionChannelString)) % if same
    handles.im_Correction_Ch_ind   = find(handles.pmt_header.acqChannels==str2num(handles.CorrectionChannelString));
    if isempty (handles.im_Correction_Ch_ind)
            handles.im_Correction_Ch_ind   = 0;
    end
else
    handles.im_Correction_Ch_ind   = 0;
end

set(handles.figure1,'Name',['pathAnalyzeGUI     ' handles.fileNameMpd]);
set(handles.minWin,'String',num2str(round(handles.timePerLine*1e4)/10));    %round minimum window duration (or time per line) to tenths of ms

if (isempty(handles.im_Ch_ind))
    warndlg('Oops - empty image channel in pmt data file')
    guidata(hObject, handles); % Update handles structure
    return
end
% if ~(isempty(handles.scannerPosData))
% [x,y]=CM_build_path(size(handles.pmt_data,1),handles.scannerPosData);
% handles.scanData.path=[x y];
%    path = handles.scanData.path;        % 'scan path'
% end


% display some stuff for the user ...
disp(['  total scan time (s): ' num2str(handles.nPoints * handles.scanData.dt)])
disp(['  time per line (ms): ' num2str(handles.nPointsPerLine * handles.scanData.dt * 1000)])
disp(['  scan frequency (Hz): ' num2str(1 / (handles.nPointsPerLine * handles.scanData.dt))])
disp(['  distance between pixels (in ROIs) (degree): ' num2str(handles.scanData.scanVelocity)])
disp(['  time between pixels (us): ' num2str(1e6*handles.scanData.dt)])
disp(['  total number of lines: ' num2str(handles.nPoints/handles.nPointsPerLine)])
disp ' '


Show_alternate_Callback(hObject, eventdata, handles);
pushButtonResetImage_Callback(hObject, eventdata, handles);  % draw image
disp ' initialize completed successfully '


%guidata(hObject, handles); % Update handles structure


% ---BUTTON---- Executes on button press in Show_alternate.
function Show_alternate_Callback(hObject, eventdata, handles)
% hObject    handle to Show_alternate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.im_Ch_ind=find(handles.pmt_header.acqChannels==handles.imageCh);

if(isempty(handles.im_Ch_ind))
    warndlg('Oops - empty image channel in pmt data file')
    
    return
end
handles.scanDataLines_to_show=squeeze(handles.pmt_data(:,handles.im_Ch_ind,1:handles.Altlines:end))';    % take the 1d data as a projection of this (first 1000 lines)...
handles.scanResult1d = mean(handles.scanDataLines_to_show);   % average collapse to a single line
handles.scanResult1d = handles.scanResult1d(:);  % make a column vector
sr1 = handles.scanResult1d;          % 'scan result 1d'
%%% populate listbox
strmat = [];
for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)% draw first frame, in axesSingleFrame
imagesc(handles.scanDataLines_to_show);
set(gca,'XTickLabel','')
%set(gca,'YLabel','String',['Every ' num2str(handles.Altlines) ' lines']);
set( get(gca,'YLabel'), 'String', ['Every ' num2str(handles.Altlines) ' lines'] );

colormap (handles.Colorscale)
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrame,'horizontal');
set(handles.figure1,'CurrentAxes',handles.axesSingleFrameProjection)% draw a projection, in axesSingleFrameProjection
cla

CM_plot_lines(handles.scanData);
plot(sr1)
colormap(handles.Colorscale);
set(gca,'xlim',[1 length(sr1)])
set(gca,'ylim',[-200 max(sr1(:))])
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrameProjection,'horizontal');
linkaxes ([handles.axesSingleFrameProjection,handles.axesSingleFrame],'x')
set (handles.axesSingleFrame,'FontSize',7)
set (handles.axesSingleFrameProjection,'FontSize',7)
set (handles.axesMainImage,'FontSize',7)
handles.displaymode='Show_alternate_Callback';
guidata(hObject, handles); % Update handles structure

% ---BUTTON----
function Show_continuous_Callback(hObject, eventdata, handles)
% hObject    handle to Show_continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.im_Ch_ind                 = find(handles.pmt_header.acqChannels==handles.imageCh);
if(isempty(handles.im_Ch_ind))
    warndlg('Oops - empty image channel in pmt data file')
    return
end

if isnan(handles.Ltoshow)
    handles.Ltoshow               = size(handles.pmt_data,3);
    set(handles.editLtoshow, 'String', num2str(handles.Ltoshow));
end

handles.scanDataLines_to_show     = squeeze(handles.pmt_data(:,handles.im_Ch_ind,1:handles.Ltoshow))';
handles.scanResult1d              = mean(handles.scanDataLines_to_show);   % average collapse to a single line
handles.scanResult1d              = handles.scanResult1d(:);  % make a column vector
sr1                               = handles.scanResult1d;          % 'scan result 1d'
%%% populate listbox
strmat = [];

for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)% draw first frame, in axesSingleFrame
imagesc(handles.scanDataLines_to_show);
CM_append_control_intensity(handles.scanDataLines_to_show)
set(gca,'XTickLabel','')
set( get(gca,'YLabel'), 'String', ['First ' num2str(handles.Ltoshow) ' lines'] );

colormap (handles.Colorscale)
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrame,'horizontal');
set(handles.figure1,'CurrentAxes',handles.axesSingleFrameProjection)% draw a projection, in axesSingleFrameProjection
cla

CM_plot_lines(handles.scanData)
plot(sr1)

colormap (handles.Colorscale)
set(gca,'xlim',[1 length(sr1)])
set(gca,'ylim',[-200 max(sr1(:))])
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrameProjection,'horizontal');
linkaxes ([handles.axesSingleFrameProjection,handles.axesSingleFrame],'x')
set (handles.axesSingleFrame,'FontSize',7)
set (handles.axesSingleFrameProjection,'FontSize',7)
set (handles.axesMainImage,'FontSize',7)
handles.displaymode='Show_continuous_Callback';
guidata(hObject, handles); % Update handles structure

% --- BUTTON- Show the selected element in the map
function PushButtonShowElement_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonShowElement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.im_Ch_ind                 = find(handles.pmt_header.acqChannels==handles.imageCh);
if(isempty(handles.im_Ch_ind))
    warndlg('Oops - empty image channel in pmt data file')
    return
end


elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element
allIndicesThisObject = find(handles.scanData.pathObjNum == elementIndex);
autoStartPoint = allIndicesThisObject(1);
autoEndPoint = allIndicesThisObject(end);
figure(handles.figure1)
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
set (gca,'xlim',[autoStartPoint-100 autoEndPoint+100]); % commented CM 20150401 to allow the zoom to not be reset
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrameProjection,'horizontal');
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrame,'horizontal');
hold off
guidata(hObject, handles);   % Update handles structure

% ---BUTTON- to dezoom the wide frame
function PushButtonDezoom_Callback(hObject, eventdata, handles)
% hObject    handle to PushButtonDezoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(handles.figure1)
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
set (gca,'xlim',[1 size(handles.scanDataLines_to_show,2)]); % commented CM 20150401 to allow the zoom to not be reset

% --- BUTTON---Display according to time
function pushbuttonDisplayScanFrom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplayScanFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.im_Ch_ind=find(handles.pmt_header.acqChannels==handles.imageCh);
if isnan(handles.Ltoshow)
    handles.Ltoshow=size(handles.pmt_data,3);
    set(handles.editLtoshow, 'String', num2str(handles.Ltoshow));
end

start_line=ceil(handles.ShowTimeParams(1)./handles.timePerLine);
if (start_line==0);start_line=1;end
end_line=ceil(handles.ShowTimeParams(2)./handles.timePerLine);

if (end_line>size(handles.pmt_data,3))
    end_line=size(handles.pmt_data,3);
    handles.ShowTimeParams(2)=end_line*handles.timePerLine;
    new_string=[num2str(handles.ShowTimeParams(1)) ',' num2str(handles.ShowTimeParams(2)) ',' num2str(handles.ShowTimeParams(3))];
    set(handles.editShowTimeParams,'String', new_string);
end


handles.ShowTimeParams(2)=end_line*handles.timePerLine;
handles.scanDataLines_to_show=squeeze(handles.pmt_data(:,handles.im_Ch_ind,start_line:handles.ShowTimeParams(3):end_line))';
handles.scanResult1d = mean(handles.scanDataLines_to_show);   % average collapse to a single line
handles.scanResult1d = handles.scanResult1d(:);  % make a column vector
sr1 = handles.scanResult1d;          % 'scan result 1d'
%%% populate listbox
strmat = [];
for s = 1:length(handles.scanData.scanCoords)
    strmat = strvcat(strmat,handles.scanData.scanCoords(s).name);
end
set(handles.listboxScanCoords,'String',cellstr(strmat));
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)% draw first frame, in axesSingleFrame
imagesc([1,size(handles.scanDataLines_to_show,2)],[(start_line-1)*handles.timePerLine,end_line*handles.timePerLine],handles.scanDataLines_to_show);

set(gca,'XTickLabel','')
set( get(gca,'YLabel'), 'String', ['seconds'] );

colormap (handles.Colorscale)
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrame,'horizontal');
set(handles.figure1,'CurrentAxes',handles.axesSingleFrameProjection)% draw a projection, in axesSingleFrameProjection
cla

CM_plot_lines(handles.scanData)
plot(sr1)

colormap (handles.Colorscale)
set(gca,'xlim',[1 length(sr1)])
set(gca,'ylim',[-200 max(sr1(:))])
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrameProjection,'horizontal');
linkaxes ([handles.axesSingleFrameProjection,handles.axesSingleFrame],'x')
set (handles.axesSingleFrame,'FontSize',7)
set (handles.axesSingleFrameProjection,'FontSize',7)
set (handles.axesMainImage,'FontSize',7)
handles.displaymode='pushbuttonDisplayScanFrom_Callback';
guidata(hObject, handles); % Update handles structure


% --- BUTTON -- PlotAnalysedElement
function pushbuttonPlotAnalysedElement_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotAnalysedElement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataStructArray=CM_uigetvar ('cell','Get DST Structure to analyse');
if isempty(dataStructArray)
    return
end
CM_PATH_ANALYSIS_PLOT_FROM_STR(dataStructArray);
CM_PATH_ANALYSIS_PLOT_FROM_STR_CTR(dataStructArray);


%% LISTS

% --- LIST_BOX Executes on selection change in listboxScanCoords.
function listboxScanCoords_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns listboxScanCoords contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxScanCoords

elementIndex = get(handles.listboxScanCoords,'Value');    % grab the selected element
handles.scanData.scanCoords(elementIndex);


% --- LIST_BOX Executes during object creation, after setting all properties.
function listboxScanCoords_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% EDITS

%--- EDIT (enter) - Window Size (in milliseconds)
function editWindowSizeMs_Callback(hObject, eventdata, handles)
handles.windowSize = 1e-3*str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure

% --- EDIT (creation) - Window Size (in milliseconds)
function editWindowSizeMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editWindowSizeMs_Callback(hObject, eventdata, handles)   % execute, to read initial value


%--- EDIT (enter) - Window Step (in milliseconds)
function editWindowStepMs_Callback(hObject, eventdata, handles)
handles.windowStep = 1e-3*str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure


% --- EDIT (creation) - Window Step (in milliseconds)
function editWindowStepMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editWindowStepMs_Callback(hObject, eventdata, handles)   % execute, to read initial value

% --- EDIT (enter) - Ltoshow (timestart,timeend,everynlines)
function editLtoshow_Callback(hObject, eventdata, handles)
% hObject    handle to editLtoshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLtoshow as text
%        str2double(get(hObject,'String')) returns contents of editLtoshow as a double
handles.Ltoshow = str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure

% --- EDIT (creation) - Executes during object creation, after setting all properties.
function editLtoshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLtoshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editLtoshow_Callback(hObject, eventdata, handles)   % execute, to read initial value

% --- EDIT --- (enter) Altlines
function editAltlines_Callback(hObject, eventdata, handles)
% hObject    handle to editAltlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAltlines as text
%        str2double(get(hObject,'String')) returns contents of editAltlines as a double
handles.Altlines = str2double(get(hObject,'String'));  % store as seconds
guidata(hObject, handles);   % Update handles structure

% --- EDIT --- (creation) Altlines
function editAltlines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAltlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editAltlines_Callback(hObject, eventdata, handles)

% --- EDIT --- (enter) DiamSmoothing
function editDiamSmoothing_Callback(hObject, eventdata, handles)
% hObject    handle to editDiamSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDiamSmoothing as text
%        str2double(get(hObject,'String')) returns contents of editDiamSmoothing as a double
handles.DiamSmoothing = str2double(get(hObject,'String'));
guidata(hObject, handles); % Update handles structure


% --- EDIT --- (creation) DiamSmoothing
function editDiamSmoothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDiamSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editDiamSmoothing_Callback(hObject, eventdata, handles)

% --- EDIT --- (enter) ThresholdRatio
function editThresholdRatio_Callback(hObject, eventdata, handles)
% hObject    handle to editThresholdRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editThresholdRatio as text
%        str2double(get(hObject,'String')) returns contents of editThresholdRatio as a double
handles.ThresholdRatio=str2double(get(hObject,'String'));
guidata(hObject, handles); % Update handles structure



% ---EDIT --- (creation) ThresholdRatio
function editThresholdRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThresholdRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editThresholdRatio_Callback(hObject, eventdata, handles)

% ---EDIT --- (enter) SaturationLevel
function editSaturationLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editSaturationLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaturationLevel as text
%        str2double(get(hObject,'String')) returns contents of editSaturationLevel as a double
handles.SaturationLevel=str2double(get(hObject,'String'));
guidata(hObject, handles); % Update handles structure


% ---EDIT --- (creation) SaturationLevel
function editSaturationLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaturationLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editSaturationLevel_Callback(hObject, eventdata, handles)

% ---EDIT --- (enter) SaturationLevel

function editSaturationPercent_Callback(hObject, eventdata, handles)
% hObject    handle to editSaturationPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSaturationPercent as text
%        str2double(get(hObject,'String')) returns contents of editSaturationPercent as a double
handles.SaturationPercent=str2double(get(hObject,'String'));
guidata(hObject, handles); % Update handles structure


% ---EDIT --- (creation) SaturationPercent
function editSaturationPercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaturationPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editSaturationPercent_Callback(hObject, eventdata, handles)


% --- EDIT --- (enter) PlotAnalysedElement
function editShowTimeParams_Callback(hObject, eventdata, handles)
% hObject    handle to editShowTimeParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ShowTimeParams= str2num(get(hObject,'String')) ;% returns contents of editShowTimeParams as a double
guidata(hObject, handles); % Update handles structure

% --- EDIT --- (creation) ShowTimeParams
function editShowTimeParams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editShowTimeParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editShowTimeParams_Callback(hObject, eventdata, handles)


%% CHECKBOXES

% --- CHECKBOX - Queue Values (analyse later.
function checkboxQueueValues_Callback(hObject, eventdata, handles)
value = get(handles.checkboxQueueValues,'Value');

if value == true
    handles.dataStructArray=[];
    handles.analyseLater = true;
    %
    %
    %     c = clock;  % elements are year, month, day, hour, minute, seconds
    %     s = '_'; % the space character, goes between the elements of the data
    %     c = [num2str(c(1)) s num2str(c(2)) s num2str(c(3)) s num2str(c(4)) s num2str(c(5)) s num2str(round(c(6)))];
    %     tp_name=strrep (handles.fileNameMpd(1,:),'.MPD','');
    %     tp_name=strrep (tp_name,' ','_');
    %
    %     tp_name=[tp_name '_CDPG'];
    %     handles.analyseLaterFilename =[tp_name '.m'];
    %     handles.analyseLater = true;
    %
    %     % write the header info
    %     delete(handles.analyseLaterFilename);
    %
    %     fid = fopen(handles.analyseLaterFilename,'w');
    %     fprintf(fid,['%% analysis file for ' handles.fileNameMat ' ' handles.fileNameMpd '\n']);
    %     fprintf(fid,['%% created ' num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) '\n']);
    %
    %     fprintf(fid,'dataStructArray = []; \n\n');
    %     clipboard('copy', (strrep(handles.fileNameMpd,'.MPD','')))
    %     fclose(fid);
else
    handles.analyseLater = false;
    pushbuttonSaveDataStructArray_Callback (hObject, eventdata, handles); % when unchecked saves the datastructure
    handles.dataStructArray=[];
    
end

guidata(hObject, handles);   % Update handles structure

% --- CHECK BOX--- checkSaturationCorrection
function checkSaturationCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to checkSaturationCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSaturationCorrection

handles.SaturationCorrection=get(handles.checkSaturationCorrection,'Value');
guidata(hObject, handles);   % Update handles structure


%% POPUPS

% --- POP UP ---- Create modify channel
function popUpChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popUpChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popUpChannel contents as cell array
%        contents = get(hObject,'Value') returns selected item from popUpChannel
handles.imageCh = get(hObject,'Value');  % get current value (as a number by default)
guidata(hObject, handles); % Update handles structure

if(isfield(handles, 'pmt_data'))
    handles.im_Ch_ind                 = find(handles.pmt_header.acqChannels==handles.imageCh);
    if (isempty(handles.im_Ch_ind))
        warndlg('Oops - empty image channel in pmt data file')
        guidata(hObject, handles); % Update handles structure
        return
    end
    %string_to_execute=[handles.displaymode '(hObject, eventdata, handles)'];
    %eval(string_to_execute);
    if strcmp (handles.displaymode, 'Show_continuous_Callback')
        Show_continuous_Callback(hObject, eventdata, handles);
    elseif strcmp (handles.displaymode,'Show_alternate_Callback')
        Show_alternate_Callback(hObject, eventdata, handles);
    elseif strcmp (handles.displaymode,'pushbuttonDisplayScanFrom_Callback')
        pushbuttonDisplayScanFrom_Callback(hObject, eventdata, handles);
    end
else
    
end

% --- POP UP ---- Create image channel
function popUpChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popUpChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
popUpChannel_Callback(hObject, eventdata, handles)

% --- POP UP---ChannelMap
function popUpChannelMap_Callback(hObject, eventdata, handles)
% hObject    handle to popUpChannelMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popUpChannelMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popUpChannelMap
handles.imageChMap = get(hObject,'Value');  % get current value (as a number by default)
pushButtonResetImage_Callback(hObject, eventdata, handles)
guidata(hObject, handles); % Update handles structure

% --- POP UP---Channel
function popUpChannelMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popUpChannelMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
popUpChannelMap_Callback(hObject, eventdata, handles)

% --- POP UP---DiaTypeAnalysis
function popupDiaTypeAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to popupDiaTypeAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contentss=get(hObject,'String');
handles.DiaTypeAnalysis = contentss{get(hObject,'Value')};

guidata(hObject, handles); % Update handles structure

% --- POP UP---creation DiaTypeAnalysis
function popupDiaTypeAnalysis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDiaTypeAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
popupDiaTypeAnalysis_Callback(hObject, eventdata, handles)


% --- BUTTON --- AnalyseStored
function pushbuttonAnalyseStored_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAnalyseStored (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathAnalysisHelper_SCANIMAGE(handles.dataStructArray);

% --- BUTTON --- EditStoredAnalysis.
function pushbuttonSaveDataStructArray_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveDataStructArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles,'dataStructArray'))
    if ~isempty(handles.dataStructArray)
        resDir = [fullfile(handles.fileDirectory,'DataSt_stock'),handles.punctuation];
        if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it
        fileName=handles.fileNameMpd;
        [fileName,resDir] = uiputfile('*.mat','Save DataStructArray to mat file:',[resDir fileName '_DataStAr']);
        save([resDir fileName],'-struct','handles','dataStructArray');
        
        structsavename=strrep(fileName,' ', '_');
        structsavename=strrep(structsavename,'_DataStAr','');
        structsavename=strrep(structsavename,'.mat','');
        structsavename=strrep(structsavename,'-','_');

        structsavename=['DST_' structsavename];
        dataStructArray=handles.dataStructArray;
        assignin ('base',structsavename,dataStructArray);
    end
else
    warndlg( 'oops, it appears that no dataStructArray was built...')
    return
end


% --- BUTTON pushbuttonSaveGuiAsPdf.
function pushbuttonSaveGuiAsPdf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveGuiAsPdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles,'figure1'))
    resDir = [fullfile(handles.fileDirectory,'GUIS'),handles.punctuation];
    if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it
    fileName=handles.fileNameMpd;
    [fileName,resDir] = uiputfile('*.pdf','Save GUI to PDF:',[resDir fileName '_GUIS']);
    gg=findall(0,'type','figure','tag','figure1');
    saveas(gg,[resDir fileName],'pdf')
    %, '-bestfit' )
    %   saveas(pathAnalyzeGUI_SCANIMAGE,[resDir fileName],'pdf', '-bestfit' )
    
else
    warndlg( 'oops, load a file first...')
    return
end



% --- BUTTON during object creation, after setting all properties.
function popupmenuColorscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuColorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
popupmenuColorscale_Callback(hObject, eventdata, handles)


% --- BUTTON on button press in pushbuttonSendGUIToWS.
function pushbuttonSendGUIToWS_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSendGUIToWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp ('Saving handles to workspace.....')
assignin('base','handles',handles)%
disp ('...handles saved to workspace!')



% --- CHECK BOX (creation)
function checkboxQueueValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkboxQueueValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
value = get(hObject,'Value');

if ~value == true;
    handles.analyseLater = false;
else
    handles.analyseLater = true;
end
guidata(hObject, handles); % Update handles structure


% --- CHECK BOX (creation)
function checkSaturationCorrection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkSaturationCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.SaturationCorrection=get(hObject,'Value');
guidata(hObject, handles);   % Update handles structure



% --- CHECKBOX on button press in checkCorrectAverageVelocity.
function checkCorrectAverageVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to checkCorrectAverageVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

value = get(hObject,'Value');

if ~value == true
    handles.CorrectAverageVelocity = false;
else
    handles.CorrectAverageVelocity = true;
end
guidata (hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of checkCorrectAverageVelocity


% --- CHECKBOX Executes during object creation, after setting all properties.
function checkCorrectAverageVelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkCorrectAverageVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

value = get(hObject,'Value');

if ~value == true
    handles.CorrectAverageVelocity = false;
else
    handles.CorrectAverageVelocity = true;
end
guidata (hObject,handles);


% --- Executes on button press in checkboxDiaInvertImage.
function checkboxDiaInvertImage_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDiaInvertImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of
%checkboxDiaInvertImage\
value = get(hObject,'Value');
if ~value == true
    handles.DiaInvertImage = false;
else
    handles.DiaInvertImage = true;
end
guidata (hObject,handles);


% --- Executes during object creation, after setting all properties.
function checkboxDiaInvertImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkboxDiaInvertImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

value = get(hObject,'Value');

if ~value == true
    handles.DiaInvertImage = false;
else
    handles.DiaInvertImage = true;
end
guidata (hObject,handles);


% --- Executes on selection change in popupmenuColorscale.
function popupmenuColorscale_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuColorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tac = cellstr(get(hObject,'String')); % returns popupmenuColorscale contents as cell array
handles.Colorscale= tac{get(hObject,'Value')}; % returns selected item from popupmenuColorscale
guidata (hObject,handles);


% --- Executes during object creation, after setting all properties.
function pushbuttonSendGUIToWS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonSendGUIToWS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



%% AUXILLIARY CODE

function CM_plot_lines(scanData)
for counter=1:1:length(scanData.scanCoords)
    hold on
    scan_shape=scanData.scanCoords(1,counter).scanShape;
    
    limits=find(scanData.pathObjNum==counter);
    
    if~isempty(strfind (scan_shape,'line'))
        plot(limits,((limits./limits).*-180),'r')
        to_text=strrep(scanData.scanCoords(1,counter).name,'line_','line');
        to_text=strrep(to_text,'_','line');
        
        text(mean(limits(:)),-150,to_text,'HorizontalAlignment','center','fontsize',8,'color','b');
    else
        plot(limits,(limits./limits).*-100,'g')
        %          sublimits_search=scanData.pathObjSubNum (limits(1):limits(end));
        %          for inside_counter=1:1:max(sublimits_search(:))
        %
        %                     sublimits=(find(sublimits_search==inside_counter))+limits (1);
        %                     plot(sublimits,(sublimits./sublimits).*20,'k')
        %          end
    end
end
% --- helper function, allows user to select other limits

function [userStartPoint userEndPoint handles] = selectLimit(handles,autoStartPoint,autoEndPoint)

% make sure the correct portion of the graph is selected, and draw
figure(handles.figure1)
set(handles.figure1,'CurrentAxes',handles.axesSingleFrame)
imagesc(handles.scanDataLines_to_show)
colormap (handles.Colorscale)
hold on

ymax = size(handles.scanDataLines_to_show,1);
set (gca,'xlim',[autoStartPoint-100 autoEndPoint+100]); % commented CM 20150401 to allow the zoom to not be reset
%plot values from file (initial guess)
plot([autoStartPoint autoStartPoint],[1 ymax],'y')
plot([autoEndPoint autoEndPoint],[1 ymax],'y')

sp = ginput(1);    % get a user click, note sp(1) is distance across image
if( sp(1)<1 | sp(1)>size(handles.scanDataLines_to_show,2) | sp(2)<1 | sp(2)>size(handles.scanDataLines_to_show,1))
    userStartPoint = autoStartPoint;   % user clicked outside image, use default point
else
    userStartPoint = round(sp(1));            % use selected point
end

plot([userStartPoint userStartPoint],[1 ymax],'g')

ep = ginput(1);     % get a user click, note ep(1) is distance across image
if( ep(1)<1 | ep(1)>size(handles.scanDataLines_to_show,2) | ep(2)<1 | ep(2)>size(handles.scanDataLines_to_show,1))
    userEndPoint = autoEndPoint;     % user clicked outside image
else
    userEndPoint = round(ep(1));            % use selected point
end

plot([userEndPoint userEndPoint],[1 ymax],'r')
set (gca,'xlim',[1 , size(handles.scanDataLines_to_show,2)]); % CM 20150401 to allow the zoom to not be reset
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrameProjection,'horizontal');
pp=zoom; setAxesZoomMotion(pp,handles.axesSingleFrame,'horizontal');

hold off

function dataStructArray=writeForLater(dataStruct,handles)
if (isfield(handles, 'dataStructArray'))
    dataStructArray=handles.dataStructArray;
    counter_datastr=length (dataStructArray)+1;
    dataStructArray{counter_datastr}=dataStruct;
else
    dataStructArray{1}=dataStruct;
end


%guidata(hObject, handles);   % Update handles structure
function [scanData,arb_struct] = loadpmtdatatostruct_to_scan_data(filename,tiff_file )
%This function load pmtdata file and save it as data struct
%filename  a string of file name, not including extensions

%arb_struct contains the following fields:
%pmtdata            matrix of pmt data Nptpercycle*Nchannels*Ncycles
%scannerPosData     scannerposition feedback signal, if any
%linescanchannels   vector of channel id saved in linescandata
%header             header generated by readLineScanDataFile, contain scanning
%                   parameter info
%roiGroup           roiGroup object as per scanimage format
%imagechannel       identity of channels saved in the two images.

%scanData contains these fields
%pathObjNum to use for GUI first ROI is 1, second is 2....in the order of
%the path

% [header, ~, scannerPosData, roiGroup] = scanimage.util.readLineScanDataFiles(filename);
 [header,~, scannerPosData, roiGroup]    = readLineScanDataFiles_PATHGUI(filename,666); % 666 is to make sure that the called code does not load the full file
%scannerPosData=evalin('base','pathFov')
arb_struct.header=header;
arb_struct.roiGroup=roiGroup;
arb_struct.scannerPosData=scannerPosData; %not sure if read linescan return only one cycle or multiple.
%if returns too much, maybe average to one cycle.
arb_struct.linescanchannel=header.SI.hChannels.channelSave;

%load scanfield image

if (isempty(tiff_file))
    [imgheader,XStk,~]=scanimage.util.opentif;
else
    [imgheader,XStk,~]=scanimage.util.opentif(tiff_file);  %manually select tif image of the scanfield.
end
imagechannel=imgheader.SI.hChannels.channelSave;
scanData.roiGroup=roiGroup;
scanData.header=header;
scanData.linescanchannel=header.SI.hChannels.channelSave;
scanData.im=zeros(size(XStk,1),size(XStk,2),4);



for jj=1:numel(imagechannel)
    ch_num=imagechannel(jj);
    quickstk=squeeze((XStk(:,:,jj,:)));size(quickstk);
    scanData.im(:,:,ch_num)=mean(quickstk,3); %Average image for j's channel
end

%process roi group to get pointtime data and linetime data
nrois=length(roiGroup.activeRois);
samplerate=header.sampleRate;
points_per_line=header.samplesPerFrame;
time_per_line=header.samplesPerFrame/header.sampleRate;
pathObjNum=zeros(points_per_line,1);
nptpassed=0;
nline=0;npause=0;npoint=0;nwaypoint=0;nsinesquare=0;nlogspiral=0;nothershape=0;

if ~(isempty(scannerPosData))
    [x,y]=CM_build_path(scanData.header.samplesPerFrame,scannerPosData,scanData);
    scanData.path=[x;y]';
end

% To uncomment
% if exist ([filename '_PATH.mat'])==2
%         load ([filename '_PATH.mat'])
%         pathlength=time_per_line/(double(1/samplerate));
%         x=InterpScanPath (ST.pathFov.G(:,1),pathlength);
%         y=InterpScanPath (ST.pathFov.G(:,2),pathlength);
%         scanData.path=[x;y]';
% end



for ii=1:nrois
    RoiStr=roiGroup.activeRois(ii).scanfields.shortDescription;
    scanData.scanCoords(1,ii).scanShape=strrep(RoiStr, 'Stim: ', '');
    sizeXY=roiGroup.activeRois(1,ii).scanfields.sizeXY;
    diagon=sqrt(sizeXY(1,1).^2+sizeXY(1,2).^2); % may have to add the z direction
    scanData.scanVelocity(1,ii)=diagon/roiGroup.activeRois(ii).scanfields.duration;% degree per sec
    
    switch roiGroup.activeRois(ii).scanfields.shortDescription
        
        case 'Stim: pause'
            npause=npause+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this pause
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(npause)];
            
        case 'Stim: line'
            nline=nline+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this line
            pathObjNum ([1:nroipoints]+nptpassed)=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(nline)];
            
        case 'Stim: point'
            npoint=npoint+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this line
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(npoint)];
            
        case 'Stim: waypoint'
            nwaypoints=nwaypoints+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this line
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(nwaypoint)];
            
        case 'Stim: logspiral'
            nlogspiral=nlogspiral+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this line
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(nlogspiral)];
            
        case 'Stim: sinesquare'
            nsinesquare=nsinesquare+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);% nb of points for this line
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(nsinesquare)];
            
        otherwise %for other type of ROI, add time to nptpassed
            nothershape=nothershape+1;
            nroipoints=round(roiGroup.activeRois(ii).scanfields.duration*samplerate);
            pathObjNum ([1:nroipoints]+min(nptpassed,points_per_line))=ii;
            nptpassed=nptpassed+nroipoints;
            scanData.scanCoords(1,ii).name=[scanData.scanCoords(1,ii).scanShape '_' num2str(nothershape)];
            
    end
    scanData.scanCoords(1,ii).indices     = [nptpassed-nroipoints+1 min(nptpassed,points_per_line)];
    
    startindex                            = scanData.scanCoords(1,ii).indices(1);
    endindex                              = scanData.scanCoords(1,ii).indices(2);
    
    if(isfield (scanData,'path'))
        scanData.scanCoords(1,ii).startPoint  = [scanData.path(startindex,1),scanData.path(startindex,2)];
        scanData.scanCoords(1,ii).endPoint    = [scanData.path(endindex,1),scanData.path(endindex,2)];    end
    %check if nptpassed corresponds to the size of the pmtdata %it does
end

scanData.dt=double(1/samplerate);
scanData.fs=samplerate;
scanData.timePerLine=time_per_line;
scanData.nLines=header.numFrames;


% is for each
% scanData.path=;
% % scanData.returnedPath=;  % not needed anymore
% % scanData.maxAcc=; % not needed anymore
% scanData.im=;
scanData.axisLimRow=[imgheader.SI.hRoiManager.imagingFovDeg(1,1),imgheader.SI.hRoiManager.imagingFovDeg(3,1)];
scanData.axisLimCol=[imgheader.SI.hRoiManager.imagingFovDeg(1,2),imgheader.SI.hRoiManager.imagingFovDeg(3,2)];
%axisLimCol
%axisLimRow
%scanData.axisLimRow=scanData.axisLimRow-(mean(scanData.axisLimRow(:))); % added for offset imaging
%scanData.axisLimCol=scanData.axisLimCol-(mean(scanData.axisLimCol(:))); % added for offset imaging

%scanData.axisLimRow=[imgheader.SI.hRoiManager.imagingFovDeg(3,1),imgheader.SI.hRoiManager.imagingFovDeg(1,1)];

%scanData.scanCoords=;
scanData.pathObjNum=pathObjNum;
% scanData.pathObjSubNum=pathObjSubNum;
arb_struct.scanData=scanData;


function [x,y]=CM_build_path(pathlength,scannerPosData,scanData)
frame_to_use=3;
pathlength=round(scanData.header.sampleRate*(size(scannerPosData.G,1)/scanData.header.feedbackSampleRate));

shortx=squeeze(scannerPosData.G(:,1,frame_to_use));tac=size(shortx,1);
x=InterpScanPath (shortx,pathlength);
shorty=squeeze(scannerPosData.G(:,2,frame_to_use));tac=size(shortx,1);
y=InterpScanPath (shorty,pathlength);
real_path_length=scanData.header.numSamples/scanData.header.numFrames;
point_difference=round(real_path_length-pathlength);
padding_points=nan (1,point_difference);
x=[x padding_points];
y=[y padding_points];




%figure;imagesc(handles.scanData.axisLimCol,handles.scanData.axisLimRow,handles.scanData.im (:,:,handles.imageChMap));axis image;hold on; plot(x,y,'r.');hold off;


function path_high_res=InterpScanPath (path_low_res,path_high_res_length)
old_spacing=(1:1:size(path_low_res))/size(path_low_res,1);size(old_spacing);
new_spacing = (1:1:path_high_res_length)/path_high_res_length;size(new_spacing);
new_spacing = (1:1:path_high_res_length)/path_high_res_length;size(new_spacing);
path_high_res = interp1(old_spacing,path_low_res,new_spacing,'pchip');%figure;plot(path_high_res)


function[results]=Analyse_from_base ()
dataStructArray=CM_uigetvar ('cell','Get DST Structure to analyse');
if isempty(dataStructArray)
    return
end

results=pathAnalysisHelper_SCANIMAGE(dataStructArray);


% --- BUTTON PUSH Executes on button press in pushbuttonPickStrToAna.
function pushbuttonPickStrToAna_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPickStrToAna (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[results]=Analyse_from_base ();



function editUmPerDegree_Callback(hObject, eventdata, handles)
% hObject    handle to editUmPerDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.UmPerDegree=str2double(get(hObject,'String'));
guidata(hObject, handles); % Update handles structure

% Hints: get(hObject,'String') returns contents of editUmPerDegree as text
%        str2double(get(hObject,'String')) returns contents of editUmPerDegree as a double


% --- Executes during object creation, after setting all properties.
function editUmPerDegree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editUmPerDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
editUmPerDegree_Callback(hObject, eventdata, handles)

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

% --- Executes during object creation, after setting all properties.
function text98_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text98 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in popUpCorrectionChannel.
function popUpCorrectionChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popUpCorrectionChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.CorrectionChannel = get(hObject,'Value');  % get current value (as a number by default)
tac= get(hObject,'String');  % get current value (as a number by default)
handles.CorrectionChannelString=tac{handles.CorrectionChannel};
guidata(hObject, handles); % Update handles structure


% Hints: contents = cellstr(get(hObject,'String')) returns popUpCorrectionChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popUpCorrectionChannel


% --- Executes during object creation, after setting all properties.
function popUpCorrectionChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popUpCorrectionChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
popUpCorrectionChannel_Callback(hObject, eventdata, handles)
