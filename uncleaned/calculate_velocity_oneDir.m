function calculate_velocity_oneDir( directory, basename, fileOutputDir, cedpath)
if nargin < 4
    cedpath = "C:\CEDMATLAB\CEDS64ML";
end
directory = append( directory, '\' );
meta = append( fileOutputDir, basename, '.meta.txt' );
cropped_tiff = append( fileOutputDir, basename, '.tif');
[dx,dt] = get_dxdt(meta);
t = Tiff(cropped_tiff,'r');
data=read( t );
if size(data, 1) > size(data, 2)
    data=data.';
end
data = double( data );
fileTime=size( data,2 )*dt/1000; %dt back to sec from ms
[raw_slopes,~]=get_slope_from_line_scan(imcomplement(data),100);
v = raw_slopes*dx/dt;
vOut=v.';
vOutInf=vOut;
vOutInf(vOutInf==Inf)=max(vOut(vOut~=Inf));
[SI,~] = parse_scan_image_meta(meta);
channels=SI.hChannels.channelSave; 
pmt_dat = append( directory, basename, '.pmt.dat');
fid = fopen( pmt_dat,'r' );
M=fread(fid,'int16=>int16');
M=M(2:2:end);
M=int16(M);   
smr=append( fileOutputDir, basename, '.smr' );
smr=char(smr);
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

if channels(end) == 4
    save_smr_wLaser(smr,vOutInf,DSVals,tbase,cedpath);
else
    save_smrBH( smr, vOutInf, DSVals, tbase, cedpath );
end