function [state, location] = particle_update(state, I, varargin)
    %colour spaces
    %I = rgb2ycbcr(I);
    %I = rgb2hsv(I);
    %I = rgb2lab(I);
    
    %parameters
    sigma = 0.5;
    alfa = 0.05;
    
    %resample particles from weights
    particles = state.particles;
    weights = state.weights / sum(state.weights);
    R = cumsum(weights);
    [~, T] = histc(rand(1, state.N), R);
    particles = particles(T+1, :);
    
%     hold on;
%     scatter(particles(:,1),particles(:,2),weights.*10000,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 1 0],'LineWidth',1)
    
    %aply dynamic model to particles
    particles = state.A*particles';
    particles = particles';
    %sample noise from gaussian with covariance Q
    mean = zeros(1, 4);
    noise = mvnrnd(mean, state.Q, state.N);
    %add noise to particles
    particles = particles + noise;
    
%     imshow(I);
%     hold on;
%     scatter(particles(:,1),particles(:,2),weights.*10000,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 1 0],'LineWidth',1)
    
    %recalculate weight for each particle
    for i=1:state.N
        %extract region around the center that is the particle
        region = get_patch(I, particles(i,1:2), 1, state.size);
        %get weighted histogram from region
        rH = extract_histogram(region, state.bins, state.eK);
        rH = rH/sum(rH(:));
        
        %hellinger distance
        dH = sqrt(sum((sqrt(state.H(:)) - sqrt(rH(:))).^2)*2);
        %probability = weight
        pi = exp(-(1/2)*((dH^2)/sigma));
        weights(i) = pi;
    end
    
    %calculate weighted mean = target center
    weights = weights / sum(weights);
    x = particles(:,1).*weights;
    y = particles(:,2).*weights;
    center = [sum(x), sum(y)];
    
%     hold on;
%     imshow(I);
%     scatter(particles(:,1),particles(:,2),weights.*10000,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 1 0],'LineWidth',1);     
%     hold on;
%     plot(center(1), center(2), 'r*');

    %update template visual model H
    newRegion = get_patch(I, center, 1, state.size);
    Hnew = extract_histogram(newRegion, state.bins, state.eK);
    Hnew = Hnew/sum(Hnew(:));
    
    H = (1-alfa)*state.H + alfa*Hnew;
    
    %update struct
    state.particles = particles;
    state.weights = weights;
    state.position = center;
    state.H = H;
    location = [state.position - state.size / 2, state.size];
end
