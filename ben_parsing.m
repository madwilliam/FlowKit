function [zz3Top]=radonDynamicWindow( dataDir, analDir, outDir )
zz3Top=3; 
cd( dataDir );
meta=dir( '*.meta.txt' );
cd( analDir );
tif_names=dir( '*.tif' );

for i=1:size( tif_names, 1 );
    tifName=tif_names( i ).name;
    bname=erase( tifName, ".tif" );
    cd( dataDir );
    
    for p=1:size( meta, 1 )    
    if contains( meta( p ).name, bname )==1
    meta_name=append( bname, '.meta.txt' );
    meta_text=readtable( meta( p ).name );

%calculate line length in um (still needs work for multiple lines)
    B=regexp( fileread( meta_name ), '\n','split' );
    line_lineRoi=find( contains( B, 'stimulusfunctions.line' ) );
    line_sizeXY=line_lineRoi-3;
    sizeXY=B( line_sizeXY );
    A=sizeXY;
    C=(A{1,1});
    sizeXYstr= regexp(C,'(-)?\d+(\.\d+)?(e(-|+)\d+)?','match');
    sizeXYnum = str2double(sizeXYstr);
    sizeXYmicron = 80.7*sizeXYnum;
    lineLengthum=sqrt(sizeXYmicron(1,1)^2 + sizeXYmicron(1,2)^2);

%Find um/pixel via line_duration*sampleRate
    samp=find(contains(B,'SI.hScan2D.sampleRate = '));
    sampR= regexp(B(samp),'(-)?\d+(\.\d+)?(e(-|+)\d+)?','match');
    sampleRate=sampR{1, 1}{1, 2};
    sampleRate=str2double(sampleRate);

    textline_duration=line_lineRoi+5;
    D=B(textline_duration);
    Dur=regexp(D,'(-)?\d+(\.\d+)?(e(-|+)\d+)?','match');
    Dura=str2double(Dur{1,1});
    umPerPixel=(lineLengthum/(Dura*sampleRate));


%Find dt
    line_framePeriod=find(contains(B,'linePeriod'));
    framePeriod=regexp(B(line_framePeriod),'(-)?\d+(\.\d+)?(e(-|+)\d+)?','match');
    framePeriod=framePeriod{1,1};
    framePeriod=str2double(framePeriod);

    %%%%%%%%%%%%%% INPUTS (um/pix) & dt in ms
    dx=umPerPixel; %pixel length (um)
    dt=framePeriod*1000; %pixel clock (*1000 convert sec to ms)
    %%%%%%%%
    cd (analDir);

    dataRaw=imread(tifName);
    if size(dataRaw, 1) < size(dataRaw, 2)
        data=dataRaw.';
    else data=dataRaw;
    end
    clearvars dataRaw;

    data=double(data(:,:));

%Total time
    fileTime=size(data,1)*dt/1000; %dt back to sec from ms

%function [thetas,the_t,spread_matrix]=GetVelocityRadonFig_demo(data,windowsize);
%window size should be in pixels, not ms, no?
%     windowsize=1*(size(data,2)*dx)/dt;

%how many different window sizes to try?
%     for u=1:2
%     w=1/u;
w=1;
windowsize=w*(size(data,2)*dx)/dt;
windowsize=round(windowsize/4)*4;

% %square window
% windowsize=size(data,2);
% windowsize=round(windowsize/4)*4;
%   
%%OUTPUTS
%thetas - the time varying angle of the space-time image
%the_t - time pointsof the angle estimates (in lines)
%spreadmatrix - matrix of variances as a function of angles at each time point
    stepsize=.25*windowsize;
    nlines=size(data,1);
    npoints=size(data,2);
    nsteps=floor(nlines/stepsize)-3;
    %find the edges
    angles=(0:179);
    angles_fine=-2:.25:2;

    spread_matrix=zeros(nsteps,length(angles));
    spread_matrix_fine=zeros(nsteps,length(angles_fine));
    thetas=zeros(nsteps,1);

    hold_matrix=ones(windowsize,npoints);
    blank_matrix=ones(nsteps,length(angles));
    the_t=NaN*ones(nsteps,1);


for k=1:nsteps
        the_t(k)=1+(k-1)*stepsize+windowsize/2;
        data_hold=data(1+(k-1)*stepsize:(k-1)*stepsize+windowsize,:);
        data_hold=data_hold-mean(data_hold(:))*hold_matrix;%subtract the mean
        radon_hold=radon(data_hold,angles);%radon transform
        spread_matrix(k,:)=var(radon_hold);%take variance
        [m the_theta]=max(spread_matrix(k,:));%find max variace
        thetas(k)=angles(the_theta);     
        radon_hold_fine=radon(data_hold,thetas(k)+angles_fine);%re-do radon with finer increments around first estiamte of the maximum
        spread_matrix_fine(k,:)=var(radon_hold_fine);
        [m the_theta]=max(spread_matrix_fine(k,:));
        thetas(k)=thetas(k)+angles_fine(the_theta);
    end
    thetas=thetas-90; %rotate
    v=(dx/dt)*cot(pi*thetas/180);%dx is in m & dt is sec

    %%
    cd(outDir);
    vOut=v.';
    vOutInf=vOut;
    vOutInf(vOutInf==Inf)=max(vOut(vOut~=Inf));

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %Is there a laser channel?
    channels=meta_text{endsWith(meta_text.Var1,'SI.hChannels.channelSave'),2};
    channels=str2num(channels{1}).';

     %Initialise the library
    cedpath = "C:\CEDMATLAB\CEDS64ML";
    addpath( cedpath );
    CEDS64LoadLib( cedpath );   
    
    if channels(end) == 4
    %%
    cd ( dataDir )
    fid=fopen(append(bname,'.pmt.dat'),'r');
    M=fread(fid,'int16=>int16');
    M=M(2:2:end);
    M=int16(M);
    
    %%
    %Initialise the library
    cedpath = "C:\CEDMATLAB\CEDS64ML";
    addpath( cedpath );
    CEDS64LoadLib( cedpath );
    
    cd( outDir );
    %Create an output file
    
    smr=append( outDir, '\', bname, '.smr' );
    smr=char( smr );
    fhand2 = CEDS64Create( smr ); 
    if( fhand2<=0 ); unloadlibrary ceds64int; return; end
    if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
    tbase = fileTime/size(vOutInf,1); % Change this 1,000,000 to sampleRate var
    else
        tbase = fileTime/size(vOutInf,2);
    end
    CEDS64TimeBase( fhand2, tbase );
    
    %Create radon channel
    CEDS64SetWaveChan( fhand2, 1, 1, 9 );
    CEDS64WriteWave( fhand2, 1, vOutInf, 0 );
    
    %Create lz-stim channel
    
    %Downsample to 10k
    if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
    n=size( M, 1 )/size( vOutInf, 1 );; % Change this 1,000,000 to sampleRate var
    else
    n=size( M, 1 )/size( vOutInf, 2 );; 
    end
     
    DSVals = M(1 : n : end);
    DSVals=int16(DSVals);
    
    %Correct new time
    %HOW?
    CEDS64SetWaveChan( fhand2, 2, 1, 1);  
    CEDS64WriteWave( fhand2, 2, DSVals, 0 );
    CEDS64CloseAll();
    unloadlibrary ceds64int;

    end
%     end %end from for loop to try multiple windows
    end
%            toc
    end
end