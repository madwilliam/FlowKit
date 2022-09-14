%% pO2 codes for sharing

%% load data and arrange lines with phosphorescence decay with option to substract baseline (laser off) lines
ttif = Tiff(filelocation.experiments(run).name,'r');
%t = Tiff(trialname,'r');
pO2.imageData = read(tif);
figure('Name',filelocation.experiments(run).name); set(gca,'FontSize',12);
subplot(2,3,1);
imagesc(pO2.imageData);axis ij;axis image; axis off
xpixels= length(pO2.imageData(on,:));
% O2Pintensity=pO2.imageData(forwardline,:);
%O2Pintensity(1,513:1024)=fliplr(pO2.imageData(backwardline,:));
% O2Pintensity(1,(1+xpixels):(2*xpixels))=fliplr(pO2.imageData(backwardline,:));
% O2Pintensity(1,(1+xpixels*2):(3*xpixels))=pO2.imageData(forwardline+1,:);
% O2Pintensity(1,(1+xpixels*3):(4*xpixels))=fliplr(pO2.imageData(backwardline+1,:));
O2Ponline(1,:)=[pO2.imageData(on,:) fliplr(pO2.imageData(on+1,:)) pO2.imageData(on+2,:) fliplr(pO2.imageData(on+3,:))];
%O2Pbaseline(1,:)=[pO2.imageData(on-2,:) fliplr(pO2.imageData(on-1,:)) pO2.imageData(on+4,:) fliplr(pO2.imageData(on+5,:))];
O2Pintensity(1,:)=O2Ponline-O2Pbaseline;
out.O2Pintensity(run,:)=O2Pintensity(1,:);
fillfraction=0.9;
flyback=512*pdt*(1-fillfraction);

O2Ptime=0:pdt:(length(O2Pintensity)-1)*pdt;
O2Ptime(xpixels+1:xpixels*2)=O2Ptime(xpixels+1:xpixels*2)+flyback;
O2Ptime(xpixels*2+1:xpixels*3)=O2Ptime(xpixels*2+1:xpixels*3)+flyback*2;
O2Ptime(xpixels*3+1:xpixels*4)=O2Ptime(xpixels*3+1:xpixels*4)+flyback*3;

O2Ptime=O2Ptime./1000; %from ns to us
subplot(2,3,2); hold on
plot(O2Ptime,O2Pintensity,'+k','MarkerSize',3)
xlabel('time [\mus]','Fontsize',11,'FontWeight','Bold'); ylabel('Oxyphor2P intensity','Fontsize',11,'FontWeight','Bold'); pbaspect([1 1 1]);  set(gcf,'color','w');

%idx_start = 4;
[maxpO2intensity,idx_max]=max(O2Pintensity); % set start to maximum intensitz

%pockelscelldelay=3; % delaz by pockelscell in pixels
%idx_start=round(5000/pixeldwelltime)+powerbox+pockelscelldelay; % start after 5 us
%idx_end   =length(O2Pintensity); 
idx_end = 1700;

idx_start=round(5000/pdt)+idx_max;
%idx_start=200;
bias= min(O2Pintensity); % subtract baseline (dark counts level)

b=O2Pintensity-bias; 
a=double(b);
a=a/a(idx_start); % normalize   by the photon count measured on the selected start point of the curve
% a is now a vector of the counts, between 0 and 1

decay_profile =       @(c,xdata) (c(1)*exp(-xdata/c(2))+c(3));
decay_profile_error = @(c,xdata,ydata) ( ydata - decay_profile(c,xdata) );

c0 = [1 40 0]; % initial values for fitted param
options.Algorithm='levenberg-marquardt';

% Compute the fit for tau (c(2))
%         try
 [cAll,resnorm,resid,exitflag,output,lambda,jacobian_c] =  lsqnonlin(decay_profile_error , c0, [],[],options,O2Ptime(idx_start:idx_end),a(idx_start:idx_end));
   



%% Michele's code for fitting pO2 
    idx_start = 4;  % Start point for fitting (bin index) 4   (4.5312 micros)      // for 5   micros 4.4138  bins
    idx_end   = 88;   % End point for fitting (bin index)  170 (192.5781 micros)// for 100 micros 88.2759 bins

    p3=[];
    lgstr=[];
    fn=fns{iFile};
    
    thelist = dir(fullfile(fn,['LifetimeData_PLIM_Cycle00001_000001_Ch_*_1_.mat']));
    
    [pth,name_of_run]=fileparts(fn);
    top_path = fileparts(pth);

    dda1 = [];
    for iF = 1:size(thelist,1)
        tmp = load(fullfile(fn,thelist(iF).name)); % Contains variable dda : nBins x nPts x nReps x nChannels
        dda1 = cat(3,dda1,tmp.dda); % concatenate on 3rd dimension = repetitions
    end    
    dda = double(dda1);
    clear tmp dda1

    
    % VERIFY number of counts per decay
    TotCntsPerDecay = squeeze(sum(dda,1)); % sum of counts; 
                                                   
    % you get a distribution over all points on the grid:
    hfig4 = figure(4);
    hist(TotCntsPerDecay), title('Distribution of total counts per single decay for all points')

    % Select channel 1 (always channel 1 for Phosphorescence)
    dda3 = dda(:,:,:,1); 
    % Sum over repetitions
     dda3_sum = squeeze(sum(dda,3));
     dda3_sum = dda3_sum(:,:,1);
     
     
     
     
     
     
     
     
    
    
    
    
    
    


