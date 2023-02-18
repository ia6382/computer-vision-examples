function [state, location] = particle_initialize(I, region, varargin)
    %colour spaces
    %I = rgb2ycbcr(I);
    %I = rgb2hsv(I);
    %I = rgb2lab(I);
    
    %parameters
    N = 50; %number of particles
    %q = 1;
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
    
    center = [x1 + x2 + 1, y1 + y2 + 1] / 2;

    w = x2 - x1 + 1;
    h = y2 - y1 + 1;
    
    %heuristic formula for dynamic q paramater
    expectedMove = ((width/w)/3+(height/h)/3)/2;
    q = floor((3/4)*expectedMove^2)
    
    %get epanechnik kernel
    eK = create_epanechnik_kernel(w, h, sigma);
    w = size(eK,2);
    h = size(eK,1);
   
    %extract template using eK dimensions
    template = get_patch(I, center, 1, [w h]);
    
    %get weighted histogram from template
    H = extract_histogram(template, bins, eK);
    H = H/sum(H(:));
    
    %motion model NCV
    A = [1 0 1 0;0 1 0 1; 0 0 1 0; 0 0 0 1]; %T = 1
    Q = q*[(1/3) 0 (1/2) 0; 0 (1/3) 0 (1/2); (1/2) 0 1 0; 0 (1/2) 0 1];
    
    %create particles with equal weights in the center of template
    particles = zeros(N, 4);
    weights = ones(N,1);
    particles(:, 1) = center(1);
    particles(:, 2) = center(2);
    %sample noise from gaussian with covariance Q
    mean = zeros(1, 4);
    noise = mvnrnd(mean, Q, N);
    %add noise to particles to get sampled particles
    particles = particles + noise;
    
%     imshow(I);
%     hold on;
%     rectangle('Position',[x1, y1, w, h], 'LineWidth',2, 'EdgeColor','g');
%     hold on;
%     scatter(particles(:,1),particles(:,2),weights.*80,'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',[0 1 0], 'LineWidth', 1)
    
    %create struct
    state = struct('template', template, 'size', [w, h]);
    state.position = center; %center point
    state.eK = eK;
    state.bins = bins;
    state.H = H;
    state.A = A;
    state.Q = Q;
    state.N = N;
    state.particles = particles;
    state.weights = weights;
    
    location = [x1, y1, state.size];

end