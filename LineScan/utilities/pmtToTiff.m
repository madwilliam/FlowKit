function pmtToTiff( pmt_files,meta_files, output_dir )
     pmt_files = filter_small_files(pmt_files);
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
            scan_start = floor(line_scan_start(linei)*sampleRate)+1;
            scan_end = floor((line_scan_start(linei)+line.duration)*sampleRate)-1;
            offset = floor(line.duration*sampleRate*0.05);
            [dx_um,dt_ms] = get_dxdt(SI,line);
            image =  pmt(scan_start+offset:scan_end-offset,:);
            if isnan(image)
                break
            else
                image=imadjust(image);
                image=medfilt2(image);
                [image,downsample_factor] = down_sample_pixels(image,dx_um);
                if downsample_factor~=1
                    dx_um = 0.15;
                end
                [start_time,end_time] = get_stimulus_start_and_end(image,channels,total_pixels,pmt_path);
                has_stimulus = numel(start_time)>0;
                if has_stimulus
                    save_name = append(file_name,'_roi_',num2str(linei));
                    tif_name = append(save_name,'.tif');
                    mat_name = append(save_name,'.mat');
                    image = im2uint16(image);
                    imwrite(image,fullfile(output_dir,tif_name));
                    save(fullfile(output_dir,mat_name),'SI','RoiGroups','has_stimulus'...
                        ,'dx_um','dt_ms','downsample_factor','channels','start_time','end_time')
                end
            end
        end
    end
end
 
function pmt_files = filter_small_files(pmt_files)
    pmt_sizes=[];    
    pmt_sizes = [pmt_sizes, pmt_files.bytes].';
    pmt_files = pmt_files( pmt_sizes > 20e3 ) ;
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