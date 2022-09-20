function O2Ptime = get_po2_time(pixel_dwell_time,fillfraction,image_size)
[n_space_sample,n_pixel_per_line] = image_size{:};
flyback=n_space_sample*pixel_dwell_time*(1-fillfraction);
O2Ptime=0:pixel_dwell_time:(n_pixel_per_line*4-1)*pixel_dwell_time;
O2Ptime(n_pixel_per_line+1:n_pixel_per_line*2)=O2Ptime(n_pixel_per_line+1:n_pixel_per_line*2)+flyback;
O2Ptime(n_pixel_per_line*2+1:n_pixel_per_line*3)=O2Ptime(n_pixel_per_line*2+1:n_pixel_per_line*3)+flyback*2;
O2Ptime(n_pixel_per_line*3+1:n_pixel_per_line*4)=O2Ptime(n_pixel_per_line*3+1:n_pixel_per_line*4)+flyback*3;
O2Ptime=O2Ptime./1000;
end