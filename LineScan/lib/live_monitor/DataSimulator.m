classdef DataSimulator

   methods (Static)
       function zz=get_test_line_scan_data()
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

       function zz=get_test_line_scan_data_chunk(sample_range)
            spatial_freq=1;
            npoints=64*spatial_freq;%number of points in a line
            zz=zeros(sample_range(2)-sample_range(1)-1,npoints);
            f0=30;
            phi0=(pi/25);%-0.3571;
            phi1=1;
            f_phi=pi;
            for i=1:npoints
                for j=sample_range(1):sample_range(2)-1
                    phi=phi0*i;%
                    f=f0+phi1*sin(((f_phi*2*pi*j)/spatial_freq)/1000);
                    zz(j-sample_range(1)+1,i)=.5+.5*sin((2*pi*f*j/spatial_freq)/1000+phi);
                end
            end
            zz= zz';
       end

       function img = get_one_radon_test(~)
            theta = pi * rand(1);
            [x1,y1]=pol2cart(theta,200);
            [x2,y2]=pol2cart(theta+pi,200);
            img = zeros(100,100);
            img = insertShape(img, 'Line', [x1+50, y1+50, x2+50, y2+50], 'LineWidth', 10);
            img = img(:,:,1);
            img = img+rand(size(img));
            img = imcomplement(img);
       end

        function images = generate_radon_test(nsample)
            theta = linspace(0,pi,nsample);
            [x1,y1]=pol2cart(theta,200);
            [x2,y2]=pol2cart(theta+pi,200);
            images = cell(nsample);
            for i = 1:nsample
                img = zeros(100,100);
                img = insertShape(img, 'Line', [x1(i)+50, y1(i)+50, x2(i)+50, y2(i)+50], 'LineWidth', 10);
                images{i} = img(:,:,1);
            end
        end

        function data = get_simulated_data_feed(counter)
            data = DataSimulator.get_test_line_scan_data_chunk([counter*100,(counter+1)*100]);
            data = reshape(data,[],1);
            data = data+rand(size(data));
        end

   end
end