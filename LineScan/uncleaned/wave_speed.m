%%
path = '/home/zhw272/better_data/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(150:end,1:8000); 

%%
raw_data = double(imageData(:,1:8000));
data = raw_data-mean(raw_data,'all');
mean_data = mean(data,2);
mean_data = repmat(mean_data,1,size(data,2));
mean_data = cast(mean_data,class(data));
data = data-mean_data;
data = imgaussfilt(data,5);
threshold = 0;
imagesc(data)
% data = data>0;
%%
val = data(25,1:1000);
val = lowpass(val,0.2);
hold on
plot(val)
plot(data(25,1:500))
hold off
%%
figure

hold off
imagesc(data(:,1:500))
hold on
for i = 1:15:size(data,1)
    val = data(i,1:500);
    val = -lowpass(val,0.005);
    [peaks,loc] = findpeaks(-val/max(val),'MinPeakProminence',0.1);
    toplot = val/max(val)*10+i;
    plot(toplot,'color','K')
    scatter(loc,toplot(loc),'rx')
end
%%
peaks = cell(1,size(data,1));
for i = 1:size(data,1)
    if i == 1
        val = data(1:5,1:end);
        val = mean(val);
        val = -lowpass(val,0.005);
        [~,peaks{i},w] = findpeaks(-val/max(val),'MinPeakProminence',0.8);
    else
        val = data(i,1:end);
        val = -lowpass(val,0.005);
        [~,peaks{i}] = findpeaks(-val/max(val),'MinPeakProminence',0.1);
    end
end
%%
all_min = [];
n_line = size(data,1);
n_peaks = numel(peaks{1});
all_path = cell(1,n_peaks);
for i = 1:n_peaks
    current_peak = peaks{1}(i);
    peak_path = [];
    peak_path(1) = current_peak;
    finish = false;
    for j = 2: n_line
        next_peaks = peaks{j};
        [min_val,id] = min(abs(next_peaks-current_peak));
        if min_val>20
            finish = true;
        end
        if finish == true
            continue
        end
        all_min = [all_min min_val];
        cloest_peak = next_peaks(id);
        peak_path = [peak_path cloest_peak];
        current_peak = cloest_peak;
    end
    all_path{i} = peak_path;
end
%%
figure
hold off
imagesc(raw_data(:,1:end))
hold on
x = 1:size(data,2);
for i = 1:n_peaks
    if numel(all_path{i})==n_line
        plot(all_path{i},1:n_line,'color','red')
        c = polyfit(all_path{i},1:n_line,1);
        y = x*c(1)+c(2);
        plot(x,y,'color','black')
    else
        plot(all_path{i},1:numel(all_path{i}),'color','red')
        if numel(all_path{i})>n_line/2
            c = polyfit(all_path{i},1:numel(all_path{i}),1);
            y = x*c(1)+c(2);
            plot(x,y,'color','black')
        end
    end
end
%%
%%binary
[nline,nsample] = size(data);
events = cell(2,nline);
for linei = 1:nline
    [start_time,end_time] = find_event_start_and_end_time(data(linei,:));
    events{1,linei} = start_time;
    events{2,linei} = end_time;
end
%%
all_min = [];
n_events = numel(events{1,1});
all_bands = cell(1,n_events);
for i = 1:n_events
    current_event_start = events{1,1}(i);
    current_event_end = events{2,1}(i);
    continuous_band = (current_event_end - current_event_start)/2;
    finish = false;
    for j = 2: nline
        if  ~finish
            n_events_in_next_line = numel(events{1,j});
            found = false;
            for eventi = 1:n_events_in_next_line
                starti = events{1,j}(eventi);
                if starti>=current_event_start && starti <= current_event_end
                    current_event_start = starti;
                    current_event_end = events{2,j}(eventi);
                    continuous_band=[continuous_band (current_event_end - current_event_start)/2];
                    found = true;
                end
            end
            if ~found
                finish = true;
            end
        end
    end
    all_bands{i} = continuous_band;
end
%%
figure
hold off
imagesc(raw_data(:,1:end))
hold on
x = 1:size(data,2);
for i = 1:n_events
    if numel(all_bands{i})==n_line
        plot(all_bands{i},1:n_line,'color','red')
    else
        plot(all_bands{i},1:numel(all_bands{i}),'color','red')
%         if numel(all_path{i})>n_line/2
%             c = polyfit(all_path{i},1:numel(all_path{i}),1);
%             y = x*c(1)+c(2);
%             plot(x,y,'color','black')
%         end
    end
end







