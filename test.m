%% create template Stimulation Roi
hSf = scanimage.mroi.scanfield.fields.StimulusField();  % create a stimulus Scanfield
hRoi = scanimage.mroi.Roi();                            % create an empty Roi
hRoi.add(0,hSf);                                        % add the scanfield to the Roi; Currently ScanImage® only supports stimulation at z=0


%% create multiple stimulus Rois from template
hRoi1 = hRoi.copy();                          % create deep copy of template Roi
hRoi1.scanfields(1).centerXY = [0.25,0.5];    % change the position of the stimulus
hRoi2 = hRoi.copy();                          % create deep copy of template Roi
hRoi2.scanfields(1).centerXY = [0.5,0.5];     % change the position of the stimulus
hRoi3 = hRoi.copy();                          % create deep copy of template Roi
hRoi3.scanfields(1).centerXY = [0.75,0.5];    % change the position of the stimulus

stimRois = [hRoi1 hRoi2 hRoi3];               % collect the position of the stimulus Rois in array


%% create pause Roi
hSfPause = scanimage.mroi.scanfield.fields.StimulusField();     % create a stimulus Scanfield
hSfPause.stimfcnhdl = @scanimage.mroi.stimulusfunctions.pause;  % the pause stimulus function allow for a smooth transition between stimuli
hSfPause.duration = 0.01;                                       % allow enough time for the mirrors to transition in between stimuli

hRoiPause = scanimage.mroi.Roi();                               % create an empty Roi
hRoiPause.add(0,hSfPause);                                      % add 'pause' stimulus to Roi


%% create park Roi
hSfPark = scanimage.mroi.scanfield.fields.StimulusField();      % create a stimulus Scanfield
hSfPark.stimfcnhdl = @scanimage.mroi.stimulusfunctions.park;    % the park stimulus function moves the mirrors to the park position
hSfPark.duration = 0.01;                                        % allow enough time for the mirrors to traverse to the park position

hRoiPark = scanimage.mroi.Roi();                                % create an empty Roi
hRoiPark.add(0,hSfPark);                                        % add 'park' stimulus to Roi


%% create roiGroup containing sequence of stimuli
hRoiGroup = scanimage.mroi.RoiGroup();

% add all stimuli, interleave with pauses
for idx = 1:length(stimRois)
    hRoiGroup.add(hRoiPause);
    hRoiGroup.add(stimRois(idx));
end
hRoiGroup.add(hRoiPark);  % transition to park position at end of sequence

hSI.hPhotostim.stimRoiGroups(end+1) = hRoiGroup;  % add sequence to array of stimRoiGroups