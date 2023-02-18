function [ U, V ] = lucaskanade( I1, I2, N, lambda)
%I1 - first image matrix (grayscale)
%I2 - second image matrix (grayscale)
%N - size of neigbourhood (NxN)

%parameters:
sigma = 1;

I1 = double(I1);
I2 = double(I2);

%derivates
It = I2-I1;
It = gausssmooth(It, 1);
[Ix1, Iy1, ~] = gaussderiv(I1, sigma);
[Ix2, Iy2, ~] = gaussderiv(I2, sigma);
Ix = (Ix1+Ix2)/2;
Iy = (Iy1+Iy2)/2;

%multiplications
IxIt = Ix.*It;
IyIt = Iy.*It;
IxIx = Ix.*Ix;
IyIy = Iy.*Iy;
IxIy = Ix.*Iy;

%summations of neighbours
K = ones(N);

sumIxIt=conv2(IxIt, K, 'same');
sumIyIt=conv2(IyIt, K, 'same');
sumIxIx=conv2(IxIx, K, 'same');
sumIyIy=conv2(IyIy, K, 'same');
sumIxIy=conv2(IxIy, K, 'same');

%calculate flow vectors
D = sumIxIx.*sumIyIy-sumIxIy.*sumIxIy;
%figure(2);imshow(D);title('D matrix');
D = D+lambda;

U = -((sumIyIy.*sumIxIt) - (sumIxIy.*sumIyIt))./D;
V = -((sumIxIx.*sumIyIt) - (sumIxIy.*sumIxIt))./D;
