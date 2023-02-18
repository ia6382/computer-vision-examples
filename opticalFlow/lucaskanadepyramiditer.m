function [ U, V ] = lucaskanadepyramiditer( I1, I2, N, level, iterations )
%I1 - first image matrix (grayscale)
%I2 - second image matrix (grayscale)
%N - size of neigbourhood (NxN)

%parameters:
sigma = 1;
lambda = 0.1;


I1 = double(I1);
I2 = double(I2);

%pyramid reduce
C = cell(2,level);
C{1, level} = I1;
C{2, level} = I2;
for i=level-1:-1:1
   C{1, i} = impyramid(C{1, i+1}, 'reduce');
   C{2, i} = impyramid(C{2, i+1}, 'reduce');
end

%pyramid expand
%previous U and V
prevU = zeros(size(C{1,1}, 1), size(C{1,1}, 2));
prevV = zeros(size(C{1,1}, 1), size(C{1,1}, 2));
for i=1:level
    for j=1:iterations
        %derivates
        It = C{2, i}-C{1, i};
        It = gausssmooth(It, 1);
        [Ix1, Iy1, ~] = gaussderiv(C{1, i}, sigma);
        [Ix2, Iy2, ~] = gaussderiv(C{2, i}, sigma);
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
        D = D + lambda;

        U = -((sumIyIy.*sumIxIt) - (sumIxIy.*sumIyIt))./D;
        V = -((sumIxIx.*sumIyIt) - (sumIxIy.*sumIxIt))./D;

        U = U + prevU;
        V = V + prevV;
        
        if(j < iterations) %warp current level image
            W = zeros(size(U, 1), size(U, 2), 2);
            W(:,:,1) = U;
            W(:,:,2) = V;
            imwarp(C{2,i},W);

            prevU = U;
            prevV = V;
        elseif (i ~= level) %resize and warp lower level
            U = 2*imresize(U, [size(C{1,i+1},1) size(C{1,i+1},2)], 'bilinear');
            V = 2*imresize(V, [size(C{1,i+1},1) size(C{1,i+1},2)], 'bilinear');

            %warp I2 image on lower level
            W = zeros(size(U, 1), size(U, 2), 2);
            W(:,:,1) = U;
            W(:,:,2) = V;
            imwarp(C{2,i+1},W);

            prevU = U;
            prevV = V;
        end
    end
end