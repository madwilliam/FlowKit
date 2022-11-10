classdef WekaAnalyzer
   methods(Static)
       function stripe_statistics = find_stripes(image,threshold)
            if ~exist('threshold','var')
                threshold = 4;
            end
            mid_line = floor(size(image,1)/2);
            dist = bwdist(image);
            mask = dist>threshold;
            objects = bwconncomp(mask);
            area = cellfun(@numel,objects.PixelIdxList);
            is_stripe = area>500;
            stripes = objects.PixelIdxList(is_stripe);
            stripe_statistics = cell(sum(is_stripe),1);
            for stripei = 1:numel(stripes)
                stripe = stripes{stripei};
                [x,y] = ind2sub(size(mask),stripe);
                mdl = fitlm(y,x);
                line = StripeAnnalyzer.parse_model(mdl,mid_line);
                stripe_statistics{stripei} = line;
            end
       end

       function stripe_coordinates = crop_stripes(image)
            mid_line = floor(size(image,1)/2);
            image = 1-image;
            image = imbinarize(image);
            image = bwdist(~image);
            image = image>2;
            objects = bwconncomp(image);
            area = cellfun(@numel,objects.PixelIdxList);
            is_stripe = area>500;
            stripes = objects.PixelIdxList(is_stripe);
            stripe_coordinates = cell(sum(is_stripe),1);
            for stripei = 1:numel(stripes)
                stripe = stripes{stripei};
                stripe_coordinates{stripei} = stripe;
            end
       end

       function plot_stripe(image,stripe_statistics,range)
            figure
            hold on
            image_chunk = image(:,range(1):range(2));
            imagesc(image_chunk )
            xs = 1:range(2)-range(1);
            stripe_is_in_range = cellfun(@(x) x.location>range(1) && x.location<range(2) ,stripe_statistics);
            stripes_in_range = stripe_statistics(stripe_is_in_range);
            for stripei = 1:numel(stripes_in_range)
                line = stripes_in_range{stripei};
                plot(xs,xs*line.slope+line.intercept+line.slope*(range(1)-1),'linewidth',5,'color','red')
                xlim([0,size(image_chunk ,2)])
                ylim([0,size(image_chunk ,1)])
            end
            hold off
       end
   end
end
