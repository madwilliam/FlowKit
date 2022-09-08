function save_smr(save_path,velosity,stimulus,time,cedpath)
    if nargin = =4
        cedpath = "C:\CEDMATLAB\CEDS64ML";
    end
    addpath( cedpath );
    CEDS64LoadLib( cedpath );  
    fhand2 = CEDS64Create( save_path ); 
    CEDS64TimeBase( fhand2, time );
    CEDS64SetWaveChan( fhand2, 1, 1, 9 );
    CEDS64WriteWave( fhand2, 1, velosity, 0 );   
    CEDS64SetWaveChan( fhand2, 2, 1, 1);  
    CEDS64WriteWave( fhand2, 2, stimulus, 0 );
    CEDS64CloseAll();
    unloadlibrary ceds64int;
end