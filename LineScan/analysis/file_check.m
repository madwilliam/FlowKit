unprocessed = '/net/dk-server/bholloway/Zhongkai/unprocessed';
tifs = FileHandler.get_tif_files(unprocessed);
unprocessed2 = '/net/dk-server/bholloway/Zhongkai/unprocessed050522';
tifs2 = FileHandler.get_tif_files(unprocessed2);

processed = '/net/dk-server/bholloway/Zhongkai/FoG_Weka_mask_first_pass';
processed_tifs = FileHandler.get_tif_files(processed);

second_out = '/net/dk-server/bholloway/Zhongkai/secondout';
tifs_out = FileHandler.get_tif_files(second_out);

up1_name = {tifs.name};
up2_name = {tifs2.name};
out1_name = {tifs_out.name};
p_name = {processed_tifs.name};

intersect(up1_name,out1_name)

setdiff(up1_name,out1_name)

intersect(p_name,up2_name)

tifs1_path= '/net/dk-server/bholloway/Zhongkai/Tifs and Mats';
tifs1 = FileHandler.get_tif_files(tifs1_path);
tifs1_name = {tifs1.name};
tifs1_name  = cellfun(@FileHandler.strip_extensions,tifs1_name,'UniformOutput',false);

tifs2_path= '/net/dk-server/bholloway/Zhongkai/outpath';
tifs2 = FileHandler.get_tif_files(tifs2_path);
tifs2_name = {tifs2.name};
tifs2_name  = cellfun(@FileHandler.strip_extensions,tifs2_name,'UniformOutput',false);

raw_path= '/net/dk-server/bholloway/Zhongkai/CBF Data/';
raw = FileHandler.get_pmt_files(raw_path);
raw_name = {raw.name};
raw_name  = cellfun(@FileHandler.strip_extensions,raw_name,'UniformOutput',false);

setdiff(tifs2_name,tifs1_name)
intersect(tifs1_name,raw_name)
%%
for i = raw_name
    for j = tifs1_name
        fount = false;
        if contains(j,i)
            found = true;
        end
        if ~found
            disp(i)
        end
    end
end


