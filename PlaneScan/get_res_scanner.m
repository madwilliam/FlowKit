function res_scanner = get_res_scanner(hSI)
n_scanners = numel(hSI.hScanners);
for i=1:n_scanners
    scanneri = hSI.hScanners{i};
    if isa(scanneri,'scanimage.components.scan2d.ResScan')
        res_scanner = scanneri;
    end
end
end