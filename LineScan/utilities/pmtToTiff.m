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
        [line_scans,line_scan_start] = MetaParser.get_all_line_scans(RoiGroups);
        nlines = numel(line_scans);
        channels=SI.hChannels.channelSave;
        pmt = FileHandler.load_pmt_file(pmt_path,total_pixels,n_channels,1);
        for linei = 1:nlines
            line = line_scans(linei);
            scan_start = line_scan_start(linei)*sampleRate;
            scan_end = scan_start+line.duration*sampleRate;
            [dx_um,dt_ms] = get_dxdt(SI,line);
            image = load_image(pmt,scan_start,scan_end);
            if isnan(image)
                break
            else
                image=imadjust(image);
                image=medfilt2(image);
                [image,downsample_factor] = down_sample_pixels(image,dx_um);
                if downsample_factor~=1
                    dx_um = 0.15;
                end
                has_stimulus = stimulus_exists(image,channels,pmt_files,file_name);
                save_name = append(file_name,'_roi_',num2str(linei));
                tif_name = append(save_name,'.tif');
                mat_name = append(save_name,'.mat');
                imwrite(image,fullfile(output_dir,tif_name));
                [stimulus,duration] = get_stimulus(image,channels,pmt_files,file_name,size(image,2));
                duration_ms = duration*dt_ms;
                save(fullfile(output_dir,mat_name),'SI','RoiGroups','has_stimulus'...
                    ,'dx_um','dt_ms','downsample_factor','channels','stimulus','duration_ms')
            end
        end
    end
end

function image = load_image(pmt,scan_start,scan_end)
    if numel(pmt)*2<(2^31)
        image=pmt(floor(scan_start*1.05):floor(scan_end*.95),:);
    else
        disp('tiff is too big')
        image = NaN;
    end

end
function [data,downsample_factor] = down_sample_pixels(data,dx_um)
    if dx_um < 0.1
        size_factor = 0.15/dx_um;
        downsample_factor = ceil(size_factor);
        data = imresize(data,'Scale',[1/downsample_factor,1]);
    else
        downsample_factor=1;
    end
end