
analDir = '/home/zhw272/AutoCropped/';
dataDir = '/home/zhw272/data/';
outDir = '/home/zhw272/output/';
cedpath = '/home/zhw272/CEDMATLAB/CEDS64ML';
calculate_velocity_parallel( dataDir, analDir, outDir,cedpath );


meta=dir(append(dataDir,'*.meta.txt' ));
tif_names=dir([analDir '*.tif' ]);
tiffi=1;
tifName=tif_names( tiffi ).name;
bname=erase( tifName, ".tif" );
metai=1;
meta_name=append( bname, '.meta.txt' );

meta_path = [dataDir meta_name];

[dx,dt] = get_dxdt(meta_path);

[dx,dt] = get_dxdt_readline(meta_path);