function is_local_max_Q = fun_array_local_maximum(A, window_size)
% fun_array_local_maximum computes the local maximum logical array of the
% input array A. 
% Input: 
%   A: 3D numerical array
%   window_size: size of the moving maximum window. 
%
if all(window_size == 1)
    is_local_max_Q = true(size(A));
    return;
end

num_dim = ndims(A);

if isscalar(window_size)
    window_size = repelem(window_size, num_dim, 1);
else
    assert(numel(window_size) == num_dim, 'Window size should match the dimension of the array');
end

dt_mov_max = movmax(A, window_size(1), 1, 'omitnan');
if ~isvector(A)    
    for iter_dim = 2 : num_dim
    dt_mov_max = movmax(dt_mov_max, window_size(iter_dim), iter_dim, 'omitnan');
    end
end
is_local_max_Q = (A >= dt_mov_max);
end