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
            [SI,RoiGroups] = parse_scan_image_meta(meta_path);
            [dx,dt] = get_dxdt(SI,RoiGroups);
            data=imread(strcat(analDir,tifName));
            if size(data, 1) > size(data, 2)
                data=data.';
            end
            data=double(data);
            [raw_slopes,time,locations]=get_slope_from_line_scan(data,100);
            flux = get_flux(raw_slopes,time,locations,dt);
            speed = raw_slopes*dx/dt;
            flux = flux.';
            speed=speed.';
            speed(speed==Inf)=max(speed(speed~=Inf));
            
            channels=SI.hChannels.channelSave; 
            if channels(end) == 4
                fid=fopen(append(dataDir,bname,'.pmt.dat'),'r');
                M=fread(fid,'int16=>int16');
                M=M(2:2:end);
                M=int16(M);
                smr=append( outDir, '\', bname, '.smr' );
                smr=char( smr );
                fileTime=size(data,2)*dt/1000; %dt back to sec from ms
                time = fileTime/numel(speed);
                n=numel(speed);
                stimulus = M(1 : n : end);
                stimulus=int16(stimulus);
                save_smr(smr,speed,stimulus,flux,time,cedpath)
            end
        end
    end
end