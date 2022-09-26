function [parameters,line_fit] = fit_exponential(xdata,ydata)
    decay_profile_function = @(c,xdata) (c(1)*exp(-xdata/c(2))+c(3));
    parameters = nlinfit(xdata,ydata,decay_profile_function,[1 40 0]);
    line_fit = decay_profile_function(parameters,xdata);
end