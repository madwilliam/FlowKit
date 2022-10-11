names = [];
names = [names {mat_files.name}];
for i = 1:numel(names)
    namei= names{i};
    for j = 1:numel(names)
        namej= names{j};
        if ~strcmpi(namei,namej)
            if strcmpi(namei,namej)
                disp(namei)
                disp(namej)
            end
        end
    end
end
%%
for i = 1:numel(names)
    namei= names{i};
    if strcmp(namei(1:4),'PACK')
%         disp(namei)
        for j = 1:numel(names)
            namej= names{j};
            if ~strcmp(namei,namej)
                if contains(namej,namei(5:end-4))
                    try
                        filea = load(fullfile('/net/dk-server/bholloway/Zhongkai/Tifs and Mats/',namei));
                        fileb = load(fullfile('/net/dk-server/bholloway/Zhongkai/Tifs and Mats/',namej));
                        
                        fields = fieldnames(filea);
                        for fieldi = 1: numel(fields)
                            fieldii = fields{fieldi};
                            sizea = get_size(getfield(filea,fieldii));
                            sizeb = get_size(getfield(fileb,fieldii));
                            if sizea~=sizeb
%                                 return
                                disp(namei)
                                disp(namej)
                                disp(fieldii)
                                disp(sizea)
                                disp(sizeb)
                            end
                        end
                    catch
                        disp(namei)
                        disp(namej)
                        disp('load error')
                    end
                end
            end
        end
    end
end
%%
imagea = FileHandler.load_image_data('/net/dk-server/bholloway/Zhongkai/duplicates/Pack-050522-NoCut_05-19-22_00013_roi_1.tif');
imageb = FileHandler.load_image_data('/net/dk-server/bholloway/Zhongkai/duplicates/PACK-050522-NoCut_05-19-22_00013_roi_1.tif');

%%
% filea = load('/net/dk-server/bholloway/Zhongkai/duplicates/PACK-071022_08-08-22_vessel_100ms-stim_5mW_00005_roi_1.mat');
% fileb = load('/net/dk-server/bholloway/Zhongkai/duplicates/Pack-071022_08-08-22_vessel_100ms-stim_5mW_00005_roi_1.mat');
% 
filea = load('/net/dk-server/bholloway/Zhongkai/duplicates/PACK-050522-NoCut_05-19-22_00013_roi_1.mat');
fileb = load('/net/dk-server/bholloway/Zhongkai/duplicates/Pack-050522-NoCut_05-19-22_00013_roi_1.mat');

fields = fieldnames(filea);
for fieldi = 1: numel(fields)
    fieldii = fields{fieldi};
    disp(fieldii)
    disp(get_size(getfield(filea,fieldii)))
    disp(get_size(getfield(fileb,fieldii)))
end