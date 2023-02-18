function [U, V] = hornschunck(I2, I1, lambda, iteration)
%I1 - first image matrix (grayscale)
%I2 - second image matrix (grayscale)
%lambda - parameter
%iterations - number of iterations (try several hundred)

%parameters:
sigma = 1;

I1 = double(I1);
I2 = double(I2);
%residual Laplacian kernel (for avereging)
L = [0 (1/4) 0; (1/4) 0 (1/4); 0 (1/4) 0];

%derivates
It = I1-I2;
It = gausssmooth(It, 1);
[Ix1, Iy1, ~] = gaussderiv(I1, sigma);
[Ix2, Iy2, ~] = gaussderiv(I2, sigma);
Ix = (Ix1+Ix2)/2;
Iy = (Iy1+Iy2)/2;

%D (part of P that doesnt change)
D = lambda + (Ix.*Ix) + (Iy.*Iy);

%initialize U and V
U = zeros(size(I1, 1), size(I1, 2));
V = zeros(size(I1, 1), size(I1, 2));

for i = 1:iteration
    %average U and V
    Ua = conv2(U, L, 'same');
    Va = conv2(V, L, 'same');
    
    P = ((Ix.*Ua) + (Iy.*Va) + It)./D;
    
    %new iteration of U and V
    U = Ua - (Ix.*P);
    V = Va - (Iy.*P);
end

