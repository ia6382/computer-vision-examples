function [state, location] = ms_updateScale(state, I, varargin)
    %colour spaces
    %I = rgb2ycbcr(I);
    %I = rgb2hsv(I);
    %I = rgb2lab(I);
    
    %parameters
    alfa = 0.05;
    sigma = 1;
    e = 1e-4; %eps
    cl = 1; %convergance limit = pixel
    nIterMax = 10;
    scaleFactor = 0.10;
    gama = 0.3;
    
    [height, width] = size(I);
    w = state.size(1);
    h = state.size(2);
    
    %scaling - pick a size that is most similar with template
    sizeDiff = scaleFactor*state.size;
    
    sameV = getV(state, I, state.size);
    biggerV = getV(state, I, state.size + sizeDiff);
    if (biggerV > sameV)
        w = state.size(1) + sizeDiff;
        h = state.size(2) + sizeDiff;
    end
    smallerV = getV(state, I, state.size - sizeDiff);
    if (smallerV > sameV) && (smallerV > biggerV)
        w = state.size(1) - sizeDiff;
        h = state.size(2) - sizeDiff;
    end
    
    %update size - prevent oversensitive scale adaptation
    w = gama*w + (1-gama)*state.size(1);
    h = gama*h + (1-gama)*state.size(2);
    
    %get epanechnik kernel
    eK = create_epanechnik_kernel(w, h, sigma);
    w = size(eK,2);
    h = size(eK,1);  
    
    %coordinates for ms
    [X, Y] = meshgrid(((-w+1)/2):((w-1)/2), ((-h+1)/2):((h-1)/2)); 

    center = state.position;
    m = 2;
    iter = 0;
    while(m > cl && iter < nIterMax)
        %get left upper corner and lower right from center point and size
        x1 = max(1, center(1) - (w-1)/2);
        y1 = max(1, center(2) - (h-1)/2);
        x2 = min(width-2, center(1) + (w-1)/2);
        y2 = min(height-2, center(2) + (h-1)/2);
        
        region = I(int32((y1:y2)+1), int32((x1:x2)+1), :);
        if (x1 == 1 || y1 == 1 || x2 == width-2 || y2 == height-2) %if we are out of picture bounds
            %get epanechnik kernel, meshgrid and new region
            w = x2-x1;
            h = y2-y1;
            eK = create_epanechnik_kernel(w, h, sigma);
            w = size(eK,2);
            h = size(eK,1);       
            [X, Y] = meshgrid(((-w+1)/2):((w-1)/2), ((-h+1)/2):((h-1)/2));
            region = I(int32(y1:(y1+h)-1), int32(x1:(x1+w)-1), :);
        end;
        
        %get weighted histogram from search region
        P = extract_histogram(region, state.bins, eK);

        %calculate weight for each colour bin from template and current region
        P = P/sum(P(:));
        V = sqrt((state.Q)./(P+e));
        V = V/sum(V(:));

        %backproject into the search region
        W = backproject_histogram(region, V);

        %calculate mean shift vector
        xMove = sum(sum(double(X).*W))./ sum(W(:));
        yMove = sum(sum(double(Y).*W))./ sum(W(:));
        move = [xMove, yMove];

        %calculate next mean (center)
        centerNew = center + move;
        m = norm(move); %vector size

        %new iteration
        center = centerNew;
        iter = iter + 1;
        
    end
    %iter
    %update template Q
    Qnew = P;
    Qold = state.Q;
    state.Q = (1 - alfa)*Qold + alfa*Qnew;
    
    %update struct
    state.size = [w h];
    state.position = center;
    location = [state.position - state.size / 2, state.size];
end
