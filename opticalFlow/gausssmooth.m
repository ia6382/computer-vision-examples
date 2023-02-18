function I = gausssmooth(I, sigma)
 
x = floor(-3.0 * sigma + 0.5) : floor(3.0 * sigma + 0.5);
G = exp(-x .^ 2 / (2 * sigma ^ 2));
G = G / sum(sum(G));

I = conv2(conv2(I, G, 'same'), G', 'same');