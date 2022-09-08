function [dx,dt] = get_dxdt(meta_path)
    [SI,RoiGroups] = parse_scan_image_meta(meta_path);
    dx=1;
    dt=1;
    for roi = 1:numel(RoiGroups.imagingRoiGroup.rois)
        scan_field = RoiGroups.imagingRoiGroup.rois(roi).scanfields;
        if all(strcmp(scan_field.stimulusFunction,'scanimage.mroi.stimulusfunctions.line'))
            sizeXYmicron = 80.7*scan_field.sizeXY;
            lineLengthum=sqrt(sizeXYmicron(1)^2 + sizeXYmicron(2)^2);
            sampleRate = SI.hScan2D.sampleRate;
            duration = scan_field.duration;
            umPerPixel=(lineLengthum/(duration*sampleRate));
            framePeriod=SI.hRoiManager.linePeriod;
            dx=umPerPixel; 
            dt=framePeriod*1000; 
        end
    end
end