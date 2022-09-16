function pmtToTiff( pmt_file, meta_file, output_dir )
pmt_path = fullfile(pmt_file.folder, pmt_file.name);
meta_path = fullfile(meta_file.folder, meta_file.name);
file_name = FileHandler.strip_extensions(pmt_file.name);
[SI,RoiGroups] = parse_scan_image_meta(meta_path);
total_pixels = SI.hScan2D.lineScanSamplesPerFrame;
n_channels = numel(SI.hChannels.channelSave);
sampleRate = SI.hScan2D.sampleRate;
lineDuration = MetaParser.get_line_scan_duration(RoiGroups);
line_scan_pixels=lineDuration*sampleRate;
pmt = FileHandler.load_pmt_file(pmt_path,total_pixels,n_channels,1);
if size(pmt,1)~=0
    if numel(pmt)*2<(2^31)
        if FileHandler.read_from_end(meta_path)
            cropped=pmt(total_pixels-(line_scan_pixels*.95)+1:total_pixels-line_scan_pixels*.05,:);
        else
            cropped=pmt(line_scan_pixels*.05:line_scan_pixels*.95,:);
        end
        cropped=imadjust(cropped);
        cropped=medfilt2(cropped);
        imwrite(cropped,fullfile(output_dir,append(file_name,'.tif')));
    else
        disp(' File too large');
    end
end
end