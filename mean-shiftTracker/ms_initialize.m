function [state, location] = ms_initialize(I, region, varargin)
    %colour spaces
    %I = rgb2ycbcr(I);
    %I = rgb2hsv(I);
    %I = rgb2lab(I);
    
    %parameters
    bins = 16;
    sigma = 1;
    [height, width] = size(I);

    % If the provided region is a polygon ...
    if numel(region) > 4
        x1 = round(min(region(1:2:end)));
        x2 = round(max(region(1:2:end)));
        y1 = round(min(region(2:2:end)));
        y2 = round(max(region(2:2:end)));
        region = round([x1, y1, x2 - x1, y2 - y1]);
    else
        region = round([round(region(1)), round(region(2)), ... 
            round(region(1) + region(3)) - round(region(1)), ...
            round(region(2) + region(4)) - round(region(2))]);
    end;

    %extract template from image
    x1 = max(1, region(1));
    y1 = max(1, region(2));
    x2 = min(width-2, region(1) + region(3) - 1);
    y2 = min(height-2, region(2) + region(4) - 1);

    %template = I((y1:y2)+1, (x1:x2)+1, :);
    w = x2 - x1 + 1;
    h = y2 - y1 + 1;
    
    %get epanechnik kernel
    eK = create_epanechnik_kernel(w, h, sigma);
    w = size(eK,2);
    h = size(eK,1);
   
    %extract template using eK dimensions
    x = (x1):(x1 + w-1);
    y = (y1):(y1 + h-1);
    template = I(int32(y), int32(x), :);
    
    %get weighted histogram from template
    Q = extract_histogram(template, bins, eK);
    Q = Q/sum(Q(:));
    
    %coordinates for ms
    [X, Y] = meshgrid(((-w+1)/2):((w-1)/2), ((-h+1)/2):((h-1)/2)); 
    
    %create struct
    state = struct('template', template, 'size', [w, h]);
    state.position = [x1 + x2 + 1, y1 + y2 + 1] / 2; %center point
    state.eK = eK;
    state.Q = Q;
    state.X = X;
    state.Y = Y;
    state.bins = bins;
    location = [x1, y1, state.size];

end