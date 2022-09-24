function flux = get_flux(radon_result,dt_ms)
nsamples_per_second = floor(1000/dt_ms);
[location_per_stripe,~,~] = find_speed_per_cell(radon_result);
image_size = numel(radon_result.slopes)*radon_result.stepsize+radon_result.windowsize/2+1;
bins = 0:nsamples_per_second:image_size;
[flux,~] = histcounts(location_per_stripe,bins);
flux = flux.';
end