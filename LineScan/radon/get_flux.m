function flux = get_flux(raw_slopes,time,locations,dt,chunk_size)
[location_per_stripe,~,~] = find_speed_per_cell(raw_slopes,time,locations);
nbins = floor(((numel(raw_slopes)-1)*(0.25*chunk_size)+chunk_size)*dt/100);
[flux,~] = histcounts(location_per_stripe,nbins);

end