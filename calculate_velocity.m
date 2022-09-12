function calculate_velocity( dataDir, analDir, outDir,cedpath)
if nargin ==3
    cedpath = "C:\CEDMATLAB\CEDS64ML";
end
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
            [raw_slopes,~]=get_slope_from_line_scan(imcomplement(data),100);
            v = raw_slopes*dx/dt;
            vOutInf=v.';
            vOutInf(vOutInf==Inf)=max(vOutInf(vOutInf~=Inf));
            [SI,~] = parse_scan_image_meta(meta_path);
            channels=SI.hChannels.channelSave; 
            if channels(end) == 4
                fid=fopen(append(dataDir,bname,'.pmt.dat'),'r');
                M=fread(fid,'int16=>int16');
                M=M(2:2:end);
                M=int16(M);
                smr=append( outDir, '\', bname, '.smr' );
                smr=char( smr );
                fileTime=size(data,2)*dt/1000; %dt back to sec from ms
                tbase = fileTime/numel(vOutInf);
                n=numel(vOutInf);
                DSVals = M(1 : n : end);
                DSVals=int16(DSVals);
                save_smr(smr,vOutInf,DSVals,tbase,cedpath)
            end
        end
    end
end