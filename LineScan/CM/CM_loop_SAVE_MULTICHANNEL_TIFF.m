function [files_to_open]=CM_loop_SAVE_MULTICHANNEL_TIFF (files_to_open)
pathlocc= which ('CM_loop_SAVE_MULTICHANNEL_TIFF');
[pathlocc,~,~] = fileparts(pathlocc) ;

addpath([pathlocc '\private\Scanimage']);
if (~exist ('files_to_open','var') || isempty (files_to_open))
    files_to_open= uipickfiles ('REFilter','\.tif');
end

if isnumeric (files_to_open)
    return
end

for i=1:1:length(files_to_open)
    lname_full=files_to_open{i};
    if(~isempty(strfind(lname_full,'.tif')))
        [PathName, FileName, C]=fileparts (lname_full);
        CM_SAVE_MULTICHANNEL_TIFF([FileName C],[PathName '\']);
    end
    
end
end

%example
% CM_SAVE_RESLICE_TIFF(Hyperstack,'','SPLIT')
% works to separate channels in scanimage

function STK_TO_TIFF=CM_SAVE_MULTICHANNEL_TIFF(FileName,PathName)


if (isempty(PathName))
    PathName=cd;
end

if (isempty(FileName))
    [FileName,PathName] = uigetfile('*.tif','Select the scanimage tiff file');
end
    resDir=[PathName 'tiffs\'];

if (length(FileName)==1)
    return
end

fullfilename=[PathName,FileName];
[header,~,~] = scanimage.util.opentif(fullfilename);
number_of_channels=length(header.SI.hChannels.channelSave);

for channel_counter=1:1:number_of_channels
    [~,B]=fileparts([PathName FileName]);
    if ~isdir(resDir);mkdir(resDir);end % if the directory does not exist, create it
    
    fname=[resDir B '_' num2str(header.SI.hChannels.channelSave(channel_counter))];
    TiffFileName=[fname '.tif'] ;
    [~,STK_TO_TIFF,~] = scanimage.util.opentif(fullfilename,'channel',header.SI.hChannels.channelSave(channel_counter));
    
    if (length (size(STK_TO_TIFF))>5) % stack with different slices
        STK_TO_TIFF=squeeze(STK_TO_TIFF);
        tac=size (STK_TO_TIFF);
        STK_TO_TIFF=reshape(STK_TO_TIFF,[tac(1),tac(2),tac(4),tac(3)]); % because at 20170524 scanimage data is not stored properly
        STK_TO_TIFF=squeeze(STK_TO_TIFF);
        STK_TO_TIFF=mean(double(STK_TO_TIFF),3);
        STK_TO_TIFF=squeeze(STK_TO_TIFF);
    else
        STK_TO_TIFF=squeeze(STK_TO_TIFF); % % stack with 1 slices
    end
    STK_TO_TIFF=STK_TO_TIFF-min(STK_TO_TIFF(:));
    STK_TO_TIFF=uint16(round(STK_TO_TIFF));
    output_filename = maketiff(STK_TO_TIFF,TiffFileName);
    AVG_STK_TO_TIFF=mean(single(STK_TO_TIFF),3);
    AVG_STK_TO_TIFF=uint16(AVG_STK_TO_TIFF);
    [A,B,C]=fileparts(TiffFileName);
    output_filename_AVG = maketiff(AVG_STK_TO_TIFF,[[A,'\AVG_' B, C]]);
    disp (fname);disp 'was saved as ';disp([resDir,['RESP_' B],'.tif']);
    if (channel_counter==1)
        AVG_STK_TO_TIFF_1=AVG_STK_TO_TIFF;
        AVG_STK_TO_TIFF_2=AVG_STK_TO_TIFF./AVG_STK_TO_TIFF;
        AVG_STK_TO_TIFF_3=AVG_STK_TO_TIFF./AVG_STK_TO_TIFF;
    end
    if (channel_counter==2)
        AVG_STK_TO_TIFF_2=AVG_STK_TO_TIFF;
    end
    if (channel_counter==3)
        AVG_STK_TO_TIFF_3=AVG_STK_TO_TIFF;
    end
    if (channel_counter==4)
        AVG_STK_TO_TIFF_4=AVG_STK_TO_TIFF;
    end
    
    
 end

  composite_image = imfuse(AVG_STK_TO_TIFF_1,AVG_STK_TO_TIFF_2,AVG_STK_TO_TIFF_3,'falsecolor','Scaling','joint','ColorChannels',[1 2 3]);
    imshow(composite_image)
        [A,B,C]=fileparts(TiffFileName);
    output_filenaoutput_filename_compositeme_AVG = maketiff(AVG_STK_TO_TIFF,[A,'\AVG_' B, C]);

    output_filename_composite= maketiff(composite_image,[A,'\COMPO_AVG_' B, C]);

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



