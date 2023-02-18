function V = getV(state, I, dim)
    [height, width] = size(I);
    sigma = 1;
    
    w = dim(1);
    h = dim(2);
    
    %get epanechnik kernel
    eK = create_epanechnik_kernel(w, h, sigma);
    w = size(eK,2);
    h = size(eK,1);
    
    center = state.position;

    %get left upper corner and lower right from center point and size
    x1 = max(1, center(1) - (w-1)/2);
    y1 = max(1, center(2) - (h-1)/2);
    x2 = min(width-2, center(1) + (w-1)/2);
    y2 = min(height-2, center(2) + (h-1)/2);
        
    region = I(int32((y1:y2)+1), int32((x1:x2)+1), :);
    
    if any(size(region, 2) < w || size(region, 1) < h) % region is on the edge
        V = -1;
    	return;
    end;

    %get weighted histogram from search region
    P = extract_histogram(region, state.bins, eK);

    %calculate weight for each colour bin from template and current region
    P = P/sum(P(:));
    V = sqrt((state.Q).*(P));
    V = sum(V(:));
end