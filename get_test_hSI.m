function hSI = get_test_hSI()
hSI.hDisplay.lastAveragedFrame = cell(1,3);
for i =1:3
    hSI.hDisplay.lastAveragedFrame{i} = checkerboard(20);
end

% boxes = hSI.hBeams.powerBoxes;
