function max_value_theta= get_max_value_angle(R,angles_to_detect)
   [~,max_value_di]=max(max(R));
   max_value_theta=angles_to_detect(max_value_di);  
end