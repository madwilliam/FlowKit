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
        

   
       