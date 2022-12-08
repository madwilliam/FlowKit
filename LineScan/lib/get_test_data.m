function zz=get_test_data()
%function to get test line scan flow data from patric drew lab

    spatial_freq=1;
    npoints=64*spatial_freq;%number of points in a line
    nlines=64*8*2*spatial_freq;%number of lines 
    zz=zeros(nlines,npoints);
    f0=30;
    phi0=(pi/25);%-0.3571;
    phi1=1;
    f_phi=pi;
    for i=1:npoints
        for j=1:nlines
            phi=phi0*i;%
            f=f0+phi1*sin(((f_phi*2*pi*j)/spatial_freq)/1000);
            zz(j,i)=.5+.5*sin((2*pi*f*j/spatial_freq)/1000+phi);
        end
    end
    zz= zz';
end