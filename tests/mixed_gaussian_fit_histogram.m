%%
path = '/home/zhw272/code for ben/';
files = dir([path '*.tif']);
filei = [path,files(1).name];
t = Tiff(filei,'r');
all_data = read(t);
imageData = all_data(:,218000:end);
[nline,nframes] = size(imageData);
%%
fig1 = figure;
ax1 = gca;
hist_data= all_data(150:end,:);
hist_data = hist_data(hist_data>33600);
hist_data = hist_data(hist_data<34000);
histogram(ax1,hist_data)

histogram(ax1,all_data(150:end,1:10000))

fig2 = figure;
ax2 = gca;
imagesc(ax2,all_data(150:end,1:1000)>33600)


[N,edges] = histcounts(dat);

figure 
hold on
plot(N/sum(N))
plot(mixed_gaussian(edges,m1,m2,s1,s2))

dat = double(reshape(all_data(150:end,1:10000),[],1));
mixed_gaussian = @(x,mu1,mu2,sig1,sig2) normpdf(x,mu1,sig1) +normpdf(x,mu2,sig2);
start = [mean(dat),mean(dat),std(dat),std(dat)];
out = mle(dat,'pdf',mixed_gaussian,'Start',start, ...
    'LowerBound',[0,0,0,0],'Options',statset('MaxIter',250));
m1 = out(1);
m2 = out(2);
s1 = out(3);
s2 = out(4);