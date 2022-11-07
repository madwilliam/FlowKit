function max_variance_theta= get_max_variance_minus_kurtosis_angle(R,angles_to_detect)
   variance=var(R);
   kurt = kurtosis(R);
   [~,max_variance_di]=max(variance-kurt);
   max_variance_theta=angles_to_detect(max_variance_di); 
end