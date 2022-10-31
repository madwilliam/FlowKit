function crop_tiffs(meta_files,tif_files,pmt_files,output_dir)
    uncropped_tiffs = FileHandler.get_uncropped_tifs(meta_files,tif_files,pmt_files);
    nfiles = numel(uncropped_tiffs);
    for i = 1:nfiles
        file_name = uncropped_tiffs(i);
        disp(append('working on ',file_name))
        pmt_file = FileHandler.get_file_path(pmt_files,file_name);
        meta_file = FileHandler.get_file_path(meta_files,file_name);
        pmtToTiff( pmt_file, meta_file, output_dir )
    end
end