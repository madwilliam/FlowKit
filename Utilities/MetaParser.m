classdef MetaParser
   methods (Static)
       function [dx,dt] = get_dxdt(SI,RoiGroups)
           scan_field = MetaParser.get_first_line_scan(RoiGroups);
           sizeXYmicron = 80.7*scan_field.sizeXY;
           lineLengthum=sqrt(sizeXYmicron(1)^2 + sizeXYmicron(2)^2);
           sampleRate = SI.hScan2D.sampleRate;
           duration = scan_field.duration;
           umPerPixel=(lineLengthum/(duration*sampleRate));
           framePeriod=SI.hRoiManager.linePeriod;
           dx=umPerPixel;
           dt=framePeriod*1000;
       end

       function line_scan = get_first_line_scan(RoiGroups)
           for roi = 1:numel(RoiGroups.imagingRoiGroup.rois)
               scan_field = RoiGroups.imagingRoiGroup.rois(roi).scanfields;
               if all(strcmp(scan_field.stimulusFunction,'scanimage.mroi.stimulusfunctions.line'))
                   line_scan = scan_field;
                   break
               end
           end
       end

       function stimulus_field = get_stimulus_field(RoiGroups)
           for roi = 1:numel(RoiGroups.imagingRoiGroup.rois)
               scan_field = RoiGroups.imagingRoiGroup.rois(roi).scanfields;
               if all(strcmp(scan_field.stimulusFunction,'stimulusfunctions.pause'))
                   stimulus_field = scan_field;
                   break
               end
           end
       end

       function lineDuration = get_line_scan_duration(RoiGroups)
           scan_field = MetaParser.get_first_line_scan(RoiGroups);
           lineDuration = scan_field.duration;
       end

       function [line_scans,line_scan_start] = get_all_line_scans(RoiGroups)
           line_scans = [];
           line_scan_start = [];
           duration = 0;
           for roi = 1:numel(RoiGroups.imagingRoiGroup.rois)
               scan_field = RoiGroups.imagingRoiGroup.rois(roi).scanfields;
               if all(strcmp(scan_field.stimulusFunction,'scanimage.mroi.stimulusfunctions.line'))
                   line_scans = [line_scans scan_field];
                   line_scan_start = [line_scan_start duration];
               end
               duration = duration+scan_field.duration;
           end

       end
   end
end