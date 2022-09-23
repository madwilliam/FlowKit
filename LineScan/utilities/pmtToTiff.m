function pmtToTiff( pmt_files,meta_files, output_dir )
    [shared_experiment,~,~] = FileHandler.get_shared_experiments(pmt_files,meta_files);
    nfiles = numel(shared_experiment);
    for filei = 1:nfiles
        file_name = shared_experiment(filei);
        disp(append('cropping tiffs for ',file_name))
        pmt_path = FileHandler.get_file(pmt_files,file_name);
        meta_path = FileHandler.get_file(meta_files,file_name);
        [SI,RoiGroups] = parse_scan_image_meta(meta_path);
        total_pixels = SI.hScan2D.lineScanSamplesPerFrame;
        n_channels = numel(SI.hChannels.channelSave);
        sampleRate = SI.hScan2D.sampleRate;
        line_scans = MetaParser.get_all_line_scans(RoiGroups);
        nlines = numel(line_scans);
        lineDuration = line_scans(1).duration;
        line_scan_pixels=lineDuration*sampleRate;
        image = load_image(pmt_path,total_pixels,n_channels,line_scan_pixels,meta_path);
        channels=SI.hChannels.channelSave;
        for linei = 1:nlines
            line = line_scans(linei);
            [dx_um,dt_ms] = get_dxdt(SI,line);
            if isnan(image)
                break
            else
                image=imadjust(image);
                image=medfilt2(image);
                [image,downsample_factor] = down_sample_pixels(image,dx_um);
                has_stimulus = stimulus_exists(image,channels,pmt_files,file_name);
                save_name = append(file_name,'_roi_',num2str(linei));
                tif_name = append(save_name,'.tif');
                mat_name = append(save_name,'.mat');
                imwrite(image,fullfile(output_dir,tif_name));
                save(fullfile(output_dir,mat_name),'SI','RoiGroups','has_stimulus'...
                    ,'dx_um','dt_ms','downsample_factor')
            end
        end
    end
end

function image = load_image(pmt_path,total_pixels,n_channels,line_scan_pixels,meta_path)
    pmt = FileHandler.load_pmt_file(pmt_path,total_pixels,n_channels,1);
    if numel(pmt)*2<(2^31)
        if FileHandler.read_from_end(meta_path)
            image=pmt(total_pixels-(line_scan_pixels*.95)+1:total_pixels-line_scan_pixels*.05,:);
        else
            image=pmt(line_scan_pixels*.05:line_scan_pixels*.95,:);
        end
    else
        image = NaN;
        disp(' File too large');
    end
end
function [data,downsample_factor] = down_sample_pixels(data,dx_um)
    size_factor = 1/dx_um;
    if size_factor > 0.5
        size_factor = 2/dx_um;
        downsample_factor = ceil(size_factor);
        data = imresize(data,'Scale',[1/downsample_factor,1]);
    else
        downsample_factor=1;
    end
end