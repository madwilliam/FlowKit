function max_value_theta= get_max_value_angle(R,angles_to_detect)
   [~,max_variance_di]=max(max(R));
   max_value_theta=angles_to_detect(max_variance_di);  
end