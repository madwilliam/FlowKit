%% pO2 codes for sharing

function pO2 = compute_pO2_from_tau(tau, whichCalibration)

% Simple function to compute pO2 from lifetime value, based on calibration
% values provided by our collaborators. Input is tau (single value or can
% be a vector or matrix) and identification of which calibration to use. 


switch whichCalibration
    
    case '2017_08_25' % Sent by Sergei in Dec. 2017, batch 2016-10, calibration 2017_08_25
        
        % Times are in us (vs s for Sergei's pdf) 
        tau = tau*1e-6;
        
        a = 14.8;
        p = 1.265776950;
        t0 = 3.8e-5; 
        kq = 890.6295443; 
        
        pO2 = (1./kq) .* (1./(a.*tau.^p) - 1./t0);
        
        
    case '2017_01_11' % Sent by Ikbal in Dec. 2017, batch 2015-10, calibration 2017_01_11
        
        % Calibration values for Oct. 2017 batch of PtG2P (expts in Dec. 2017 and on)
        sy0 = -34.8191582908306;
        sA1 = 136.317301530121;
        st1 = 2.85256938818861E-5 *1e6; % times are in us (vs s for Sergei's pdf)
        sA2 = 557.153773654456;
        st2 = 5.58371871330896E-6 *1e6; % times are in us (vs s for Sergei's pdf)
        % Equation: y = A1  *exp(-x/t1) + A2 *exp(-x/t2) + y0; delay 5 us
        
        pO2 = sA1.*exp(-tau./st1)+sA2.*exp(-tau./st2)+sy0;
        
    case '2016_12' % Sent by Ikbal in fall 2018, batch 2016-10, calibration 2016_12
        
         % Calibration values for Oct. 2017 batch of PtG2P (expts in Dec. 2017 and on)
        sy0 = -18.853346;
        sA1 = 166.06267;
        st1 = 1.7751566E-5 *1e6; % times are in us (vs s for Sergei's pdf)
        sA2 = 585.449747;
        st2 = 4.219516E-6 *1e6; % times are in us (vs s for Sergei's pdf)
        % Equation: y = A1  *exp(-x/t1) + A2 *exp(-x/t2) + y0; delay 5 us
        
        pO2 = sA1.*exp(-tau./st1)+sA2.*exp(-tau./st2)+sy0;
            
end
        

%% resonant scanner


%% load data and arrange lines with phosphorescence decay with option to substract baseline (laser off) lines
tif = Tiff(filelocation.experiments(run).name,'r');
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
     
     
     
     
     
     
     
     
    
    
    
    
    
    


