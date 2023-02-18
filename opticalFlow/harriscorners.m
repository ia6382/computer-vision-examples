function H = harriscorners(I, N)
treshold = 0.01;
k = 0.04;
sigma = 1;

%derivates
[Ix, Iy, ~] = gaussderiv(I, sigma);

%multiplications
IxIx = Ix.*Ix;
IyIy = Iy.*Iy;
IxIy = Ix.*Iy;

%summations of neighbours
K = ones(N);

sumIxIx=conv2(IxIx, K, 'same');
sumIyIy=conv2(IyIy, K, 'same');
sumIxIy=conv2(IxIy, K, 'same');


%Harris corner detection
H = zeros(size(I,1), size(I,2));
for x=1:size(I,1)
   for y=1:size(I,2)
       S = [sumIxIx(x, y) sumIxIy(x, y); sumIxIy(x, y) sumIyIy(x, y)];
       det = sumIxIx(x, y)*sumIyIy(x, y)-sumIxIy(x, y)*sumIxIy(x, y);

       c = det - k * (trace(S) ^ 2);
       if (c > treshold)
          H(x, y) = c;
       end
   end
end

figure(3); imshow(H); title('Harris corner points');