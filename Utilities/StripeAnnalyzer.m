classdef StripeAnnalyzer
   methods(Static)
       function line = parse_model(model,mid_line)
           %location is the intersection of the line with the horizontal
           %midline of the image
            line.intercept = model.Coefficients{1,'Estimate'};
            line.slope = model.Coefficients{2,'Estimate'};
            line.location = (mid_line-line.intercept)/line.slope;
       end

   end
end