classdef VesselDiameter
   methods(Static)


        function [meanFwhms,meanFwhmSTDEVs] = getVesselDiameter(data,x,y,cross_line_distance,cross_line_length,pixelWidth)
            [~, ~,slices] = size(data);
            all_fwhms = [];
            meanFwhms = [];
            meanFwhmSTDEVs = [];
            cross_lines = VesselDiameter.makeCrossLines(x,y,cross_line_distance,cross_line_length);
            for slice = 1:slices
        % 		// Parse through the cross-lines and obtain the FWHM values
                profiles = VesselDiameter.getProfilesForSlice(data(:,:,slice),cross_lines);
                fwhms = VesselDiameter.getFWHMFromProfiles(profiles, pixelWidth);
                nonNanFwhms = [];
                for i = 1:numel(fwhms)
                    if ~isnan(fwhms(i))
                        nonNanFwhms = [nonNanFwhms fwhms(i)];
                    end
                end
                meanFwhms = [meanFwhms mean(nonNanFwhms)];
                meanFwhmSTDEVs =[meanFwhmSTDEVs std(nonNanFwhms)];
                all_fwhms = [all_fwhms {nonNanFwhms}];
           end
        end

        function cross_lines = makeCrossLines(x,y,cross_line_distance,cross_line_length)
            lastX = 0;
            lastY = 0;
            cross_lines = [];
            totalLength = 0;
            for i = 1:numel(x) - 1
                totalLength = totalLength + sqrt(power(x(i+1)-x(i),2) + power(y(i+1)-y(i),2));
            end
            extraLength = mod(totalLength,cross_line_distance);
            for i = 1:numel(x) - 1
                slope = (y(i+1) - y(i)) / (x(i+1) - x(i));
                perpendicularSlope = -1 / slope;
                yInt = y(i) + (-1 * slope * x(i));

            % 					// Move the starting point based on the excess so that the cross-lines are centered
                if i == 1
                    intersection = VesselDiameter.getIntersection(x(i), y(i), extraLength/2, slope, yInt);
                    if x(i+1) > x(i)
                        movingX = max(intersection);
                    else 
                        movingX = min(intersection);
                    end
                end
            % 					// Move the starting points on line-segments following the first so that equal cross-line distance is maintained
                if i > 1
                    intersection = VesselDiameter.getIntersection(lastX, lastY, cross_line_distance, slope, yInt);
                    if x(i+1) > x(i)
                        movingX = max(intersection);
                    else
                        movingX = min(intersection);
                    end
                end
                while (movingX <= max([x(i),x(i+1)])) && ((movingX >= min([x(i), x(i+1)]))) 
                    movingY = slope * movingX + yInt;
                    invYInt = movingY + (-1 * perpendicularSlope * movingX);
                    intersection = VesselDiameter.getIntersection(movingX, movingY, cross_line_length/2, perpendicularSlope, invYInt);
                    cross_lines = [cross_lines {[perpendicularSlope,invYInt,intersection]}];
                    lastX = movingX;
                    lastY = movingY;
                    intersection = VesselDiameter.getIntersection(movingX, movingY, cross_line_distance, slope, yInt);
                    if x(i+1) > x(i)
                        movingX = max(intersection);
                    else
                        movingX = min(intersection);
                    end
                end
            end
        end

        function intersection = getIntersection(centerX, centerY, radius, slope, yInt) 
            a = power(slope, 2) + 1;
            b = 2 * ((slope * yInt) - (slope * centerY) - centerX);
            c = power(centerY, 2) - power(radius, 2) + power(centerX, 2) - (2 * yInt * centerY) + power(yInt, 2);
            x1 = (-1 * b + sqrt(power(b, 2) - 4 * a * c)) / (2 * a);
            x2 = (-1 * b - sqrt(power(b, 2) - 4 * a * c)) / (2 * a);
            intersection =  [x1, x2];
        end

        function i = index(a, value) 
            for i=1:numel(a)
                if a(i)==value 
                    return 
                end
            end
            i = -1; 
        end

        function profiles = getProfilesForSlice(dataSlice,cross_lines) 
            profiles = [];
            for this_line = cross_lines
                [x1,x2,y1,y2] = VesselDiameter.line_to_end_points(this_line);
                profile = improfile(dataSlice,[x1,x2],[y1,y2]);
                profiles = [profiles {profile}];
            end
        end

        function fwhms = getFWHMFromProfiles(profiles, pixelScale)
            fwhms = [];
            for i = 1:numel(profiles)
                profile = profiles{i};
            %     // Determine the derivative of this profile and use it to expand the bounds of FWHM height
            %     // Obtain the FWHM value for this profile
                halfMax = (max(profile)-min(profile))/2+min(profile);
                fwhm_intersects = VesselDiameter.getYIntersects(halfMax, profile);
            %     // Determine the derivative of this profile and use it to expand the bounds of FWHM height
                derivative = diff(profile);
                intersects = VesselDiameter.getYIntersects(0, derivative);
                intersects = round(intersects);
                leftIntChange = 0;
                rightIntChange = numel(profile);
                for x = 1:numel(intersects)
                    if (intersects(x) > leftIntChange) && (min(fwhm_intersects) > intersects(x)) 
                        leftIntChange = intersects(x);
                    end
                    if (intersects(x) < rightIntChange) && (intersects(x) > max(fwhm_intersects)) 
                        rightIntChange = intersects(x);
                    end
                end
            %     // Using the adjusted intersects, recalculate the half max and find the x distance
                vesselCenter = (rightIntChange + leftIntChange) / 2;
                fwhm = VesselDiameter.fwhmFromProfile(profile, halfMax, ((rightIntChange + leftIntChange) / 2), false) * pixelScale;		
                fwhms =[fwhms fwhm];
            end
        end

        function fwhm = fwhmFromProfile(profile, targetY, vesselCenterX, minDist) 
            intersects = VesselDiameter.getYIntersects(targetY, profile);
            if targetY < 0.2
                fwhm = NaN;
                return
            end
            if numel(intersects) < 2 
                fwhm = NaN;
                return
            end
            leftX = intersects(1);
            rightX = intersects(end);
            for x = 1: numel(intersects)
                if minDist && intersects(x) < vesselCenterX && vesselCenterX - intersects(x) < vesselCenterX - leftX
                    leftX = intersects(x);
                end
                if minDist && intersects(x) > vesselCenterX && intersects(x) - vesselCenterX < rightX - vesselCenterX
                    rightX = intersects(x);
                end
                if ~minDist && intersects(x) < vesselCenterX && vesselCenterX - intersects(x) > vesselCenterX - leftX
                    leftX = intersects(x);
                end
                if ~minDist && intersects(x) > vesselCenterX && intersects(x) - vesselCenterX > rightX - vesselCenterX
                    rightX = intersects(x);
                end
            end
            fwhm  =rightX - leftX;
        end

        function intersects = getYIntersects(targetY, fx) 
            intersects = [];
            for c=1: numel(fx)-1
                profileSlope = (fx(c+1) - fx(c));
                profileYInt = fx(c) + (-1 * profileSlope * c);
                xInt = (targetY - profileYInt) / profileSlope;
                if (xInt >= c && xInt <= (c+1)) 
                    intersects = [intersects xInt];
                end
            end
        end
        
        function [x1,x2,y1,y2] = line_to_end_points(this_line)
            perpendicularSlope = this_line{1}(1);
            invYInt = this_line{1}(2);
            x1 = this_line{1}(3);
            x2 = this_line{1}(4);
            y1 = x1*perpendicularSlope+invYInt;
            y2 = x2*perpendicularSlope+invYInt;
        end

        function plot_cross_lines(data,x,y,cross_lines)
            figure
            hold on
            projection = mean(data,3);
            imagesc(projection)
            colormap(gray)
            plot(x,y,'color','r','linewidth',1)
            for this_line = cross_lines
                perpendicularSlope = this_line{1}(1);
                invYInt = this_line{1}(2);
                x1 = this_line{1}(3);
                x2 = this_line{1}(4);
                y1 = x1*perpendicularSlope+invYInt;
                y2 = x2*perpendicularSlope+invYInt;
                line([x1,x2],[y1,y2],'color','r','linewidth',1)
            end
            [sizex,sizey] = size(projection);
            xlim([1,sizex])
            ylim([1,sizey])
        end
        
        function plot_result(meanFwhms,meanFwhmSTDEVs)
            figure
            curve1 = meanFwhms + meanFwhmSTDEVs;
            curve2 = meanFwhms - meanFwhmSTDEVs;
            x = 1:numel(meanFwhms);
            x2 = [x, fliplr(x)];
            inBetween = [curve1, fliplr(curve2)];
            h = fill(x2, inBetween, 'k');
            set(h,'facealpha',.5)
            hold on;
            plot(x, meanFwhms, 'black', 'LineWidth', 2);
        end
   end
end