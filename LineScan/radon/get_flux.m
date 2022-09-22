function flux = get_flux(radon_result,dt,chunk_size)
[location_per_stripe,~,~] = find_speed_per_cell(radon_result);
nbins = floor(((numel(radon_result.slopes)-1)*(0.25*chunk_size)+chunk_size)*dt/100);
[flux,~] = histcounts(location_per_stripe,nbins);

end