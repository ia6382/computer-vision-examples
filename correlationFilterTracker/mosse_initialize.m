function [state, location] = mosse_initialize(I, region, varargin)
    scale = 2;
    sigma = 1; %vecji je, sirsi je gauss
    lamda = 1e-10;
    img = double(rgb2gray(I));

    [height, width] = size(img);

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

    x1 = max(1, region(1));
    y1 = max(1, region(2));
    x2 = min(width-2, region(1) + region(3) - 1);
    y2 = min(height-2, region(2) + region(4) - 1);
    
    position = [x1 + x2 + 1, y1 + y2 + 1] / 2; %center of region

    %extract template from image
    wold = x2 - x1 + 1;
    hold = y2 - y1 + 1;
    template = get_patch(img, position, scale, [wold, hold]);
    template = template - mean(template(:));
    [h, w] = size(template);
    
    %apply cos on template
    C = create_cos_window([w, h]);
    template = template.*C;
    ftemplate = fft2(template); %furier transform
    cftemplate = conj(ftemplate);%conjugate
    
    %desired response G
    G = create_gauss_peak([w, h], 255, sigma);
    fG = fft2(G);
    
    %local center = gauss peak
    [~,i] = max(G(:));
    [y, x] = ind2sub(size(G),i);
    localCenter = [x, y];
    
    %calculate filter H
    cfH = (fG.*cftemplate)./((ftemplate.*cftemplate)+lamda); 
    
    %create struct state
    state = struct('size', [wold, hold]);
    state.position = position;
    state.C = C;
    state.fG = fG;
    state.cfH = cfH;
    state.lamda = lamda;
    state.scale = scale;
    state.localCenter = localCenter;

    location = [x1, y1, state.size];

end