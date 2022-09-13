%Goal: find if white band exists, if so when and how long?
dataDir= "Z:\Data and Analysis\Analysis\Two Photon Analysis\PACK-080422\AutoCropped\08-31-22\test\";
stimOutDir= "Z:\Data and Analysis\Analysis\Two Photon Analysis\PACK-080422\StimCrop";
cd( dataDir );
imjs=dir( '*.tif' );

%Find white band
for i=1:size( imjs,1 );
    %read in Tiff
    cd( dataDir );
    filei = imjs( i ).name;
    t = Tiff( filei, 'r' );
    pmt_data = read( t );
    
    %Avg method to compress vertical
    vert_avg = mean( pmt_data );
    
    [ mean_val, stim_start_index ] = max( vert_avg );
   mx_index = find( (vert_avg == 65535 ) );
   
   if mx_index ~= 0 %if stim exists...
    
   j=1;
    while j < (size ( mx_index, 2 ) - 1) ; 
        if mx_index( j ) ~= ( mx_index( j+1 ) - 1 );
            stim_end_index = ( mx_index( j ) );
            
            j = size ( mx_index, 2 ) - 1;
        end
        j= j+1 ;
    end
    stim_dur = stim_end_index-stim_start_index ; %in pixels
    
%   stim_dur = stim_dur/(frameRate); %in seconds 
%     if mean_val == 65535
%         stimRoi = pmt_data( :, ( mean_index-25000 ) : ( mean_index+2500 ) );
%     end

    % WANT to add code here to generate the SMR channel for stimulation
   end
end