function [dx,dt] = get_dxdt_readline(meta_path)
%calculate line length in um (still needs work for multiple lines)
    B=regexp( fileread( meta_path ), '\n','split' );
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