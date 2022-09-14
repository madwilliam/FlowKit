function save_smr(save_path,velocity,stimulus,flux,time,cedpath)
    if nargin ==4
        cedpath = "C:\CEDMATLAB\CEDS64ML";
    end
    addpath( genpath(cedpath ));
    CEDS64LoadLib( cedpath );  
    file_handle = CEDS64Create( save_path ); 
    CEDS64TimeBase( file_handle, time );
    CEDS64SetWaveChan( file_handle, 1, 1, 9 );
    CEDS64WriteWave( file_handle, 1, velocity, 0 );   
    CEDS64SetWaveChan( file_handle, 2, 1, 1);  
    CEDS64WriteWave( file_handle, 2, stimulus, 0 );
    CEDS64SetWaveChan( file_handle, 3, 1, 1);  
    CEDS64WriteWave( file_handle, 3, flux, 0 );
    CEDS64CloseAll();
    unloadlibrary ceds64int;
end