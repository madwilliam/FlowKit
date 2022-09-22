function [dx_um,dt_ms] = get_dxdt(SI,RoiGroups)
    dx_um=1;
    dt_ms=1;
    for roi = 1:numel(RoiGroups.imagingRoiGroup.rois)
        scan_field = RoiGroups.imagingRoiGroup.rois(roi).scanfields;
        if all(strcmp(scan_field.stimulusFunction,'scanimage.mroi.stimulusfunctions.line'))
            sizeXYmicron = 80.7*scan_field.sizeXY;
            lineLengthum=sqrt(sizeXYmicron(1)^2 + sizeXYmicron(2)^2);
            sampleRate = SI.hScan2D.sampleRate;
            duration = scan_field.duration;
            umPerPixel=(lineLengthum/(duration*sampleRate));
            framePeriod=SI.hRoiManager.linePeriod;
            dx_um=umPerPixel; 
            dt_ms=framePeriod*1000; 
        end
    end
end