function [dx_um,dt_ms] = get_dxdt(SI,scan_field)
    sizeXYmicron = 80.7*scan_field.sizeXY;
    lineLengthum=sqrt(sizeXYmicron(1)^2 + sizeXYmicron(2)^2);
    sampleRate = SI.hScan2D.sampleRate;
    duration = scan_field.duration;
    umPerPixel=(lineLengthum/(duration*sampleRate));
    framePeriod=SI.hRoiManager.linePeriod;
    dx_um=umPerPixel; 
    dt_ms=framePeriod*1000; 
end