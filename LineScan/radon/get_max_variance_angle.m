function max_variance_theta= get_max_variance_angle(R,angles_to_detect)
   variance=var(R);
   [~,max_variance_di]=max(variance);
   max_variance_theta=angles_to_detect(max_variance_di);  
end