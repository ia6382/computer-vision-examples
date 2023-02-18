function cos_window = create_cos_window(sz)
% INPUT: sz (size vector: [width, height])
% OUTPUT: 2-d cosine window (size = width x height])

cos_window = hann(sz(2)) * hann(sz(1))';

end  % endfunction