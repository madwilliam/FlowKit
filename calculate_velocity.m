function calculate_velocity( dataDir, analDir, outDir )
meta=dir(append(dataDir,'*.meta.txt' ));
tif_names=dir(strcat(analDir,'*.tif'));
for tiffi=1:size( tif_names, 1 )
    tifName=tif_names( tiffi ).name;
    bname=erase( tifName, ".tif" );
    for metai=1:size( meta, 1 )    
        if contains( meta( metai ).name, bname )==1
            disp(strcat('working on ',bname))
            meta_name=strcat( bname, '.meta.txt' );
            meta_path = strcat(dataDir,meta_name);
            [dx,dt] = get_dxdt(meta_path);
            data=imread(strcat(analDir,tifName));
            if size(data, 1) > size(data, 2)
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
            [SI,~] = parse_scan_image_meta(meta_path);
            channels=SI.hChannels.channelSave; 
            if channels(end) == 4
                cd ( dataDir )
                fid=fopen(append(bname,'.pmt.dat'),'r');
                M=fread(fid,'int16=>int16');
                M=M(2:2:end);
                M=int16(M);
                cd( outDir );    
                smr=append( outDir, '\', bname, '.smr' );
                smr=char( smr );

                if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
                    tbase = fileTime/size(vOutInf,1); % Change this 1,000,000 to sampleRate var
                else
                    tbase = fileTime/size(vOutInf,2);
                end
      
                if( size ( vOutInf, 1 ) > size( vOutInf, 2 ) )
                    n=size( M, 1 )/size( vOutInf, 1 ); % Change this 1,000,000 to sampleRate var
                else
                    n=size( M, 1 )/size( vOutInf, 2 ); 
                end
                DSVals = M(1 : n : end);
                DSVals=int16(DSVals);

    
            end
        end
    end
end