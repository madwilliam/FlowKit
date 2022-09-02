function [zz3Top]=radonDynamicWindow( dataDir, analDir, outDir )
zz3Top=3; 
cd( dataDir );
meta=dir([dataDir '*.meta.txt' ]);
cd( analDir );
tif_names=dir([analDir '*.tif' ]);
for tiffi=1:size( tif_names, 1 )
    tifName=tif_names( tiffi ).name;
    bname=erase( tifName, ".tif" );
    cd( dataDir );
    for metai=1:size( meta, 1 )    
        if contains( meta( metai ).name, bname )==1
            meta_name=append( bname, '.meta.txt' );
            [SI,RoiGroups] = parse_scan_image_meta([dataDir meta_name]);
            scan_field = RoiGroups.imagingRoiGroup.rois.scanfields;
            sizeXYmicron = 80.7*scan_field.sizeXY;
            lineLengthum=sqrt(sizeXYmicron(1,1)^2 + sizeXYmicron(1,2)^2);
            sampleRate = SI.hScan2D.sampleRate;
            duration = scan_field.duration;
            umPerPixel=(lineLengthum/(duration*sampleRate));
            framePeriod=SI.hRoiManager.linePeriod;
            dx=umPerPixel; 
            dt=framePeriod*1000; 
            data=imread([analDir tifName]);
            if size(data, 1) < size(data, 2)
                data=data.';
            end
            data=double(data);
            fileTime=size(data,1)*dt/1000; %dt back to sec from ms
            [raw_slopes,~]=get_slope_from_line_scan(imcomplement(data),100);
            cd(outDir);
            v = raw_slopes*dx/dt;
            vOut=v.';
            vOutInf=vOut;
            vOutInf(vOutInf==Inf)=max(vOut(vOut~=Inf));
            channels=SI.hChannels.channelSave;
             %Initialise the library
            cedpath = "C:\CEDMATLAB\CEDS64ML";
            addpath( cedpath );
            CEDS64LoadLib( cedpath );   
            if channels(end) == 4
                cd ( dataDir )
                fid=fopen(append(bname,'.pmt.dat'),'r');
                M=fread(fid,'int16=>int16');
                M=M(2:2:end);
                M=int16(M);
                cd( outDir );    
                smr=append( outDir, '\', bname, '.smr' );
                smr=char( smr );
                fhand2 = CEDS64Create( smr ); 
                if( fhand2<=0 )
                    unloadlibrary ceds64int; 
                    return;
                end
                if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
                    tbase = fileTime/size(vOutInf,1); % Change this 1,000,000 to sampleRate var
                else
                    tbase = fileTime/size(vOutInf,2);
                end
                CEDS64TimeBase( fhand2, tbase );
                CEDS64SetWaveChan( fhand2, 1, 1, 9 );
                CEDS64WriteWave( fhand2, 1, vOutInf, 0 );         
                if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
                    n=size( M, 1 )/size( vOutInf, 1 ); % Change this 1,000,000 to sampleRate var
                else
                    n=size( M, 1 )/size( vOutInf, 2 ); 
                end
                DSVals = M(1 : n : end);
                DSVals=int16(DSVals);
                CEDS64SetWaveChan( fhand2, 2, 1, 1);  
                CEDS64WriteWave( fhand2, 2, DSVals, 0 );
                CEDS64CloseAll();
                unloadlibrary ceds64int;
    
            end
        end
    end
end