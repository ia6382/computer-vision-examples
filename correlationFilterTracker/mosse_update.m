function [state, location] = mosse_update(state, I, varargin)
    alfa = 0.05; %hitrost updatanja
    
    img = double(rgb2gray(I));
    
    region = get_patch(img, state.position, state.scale, state.size);
    region = region - mean(region(:));
     
    %apply cos on region
    region = region.*state.C;
    fregion = fft2(region);

    %calculate corelation with filter h
    fcor = fregion.*state.cfH;
    cor = ifft2(fcor);
    
    %find max position of corelation = new center in local coordinates
    [~,i] = max(cor(:));
    [y, x] = ind2sub(size(cor),i);
    %[y x] = find(ismember(cor, max(cor(:))));
    mode = [x, y];
    
    %calculate displacement from center of region
    displacement = mode - state.localCenter;
       
    %update filter H
    %get new  updated patch
    region = get_patch(img, state.position + displacement, state.scale, state.size);
    region = region - mean(region(:));
    
    fregion = fft2(region);
    cfregion = conj(fregion);
    cfHnew = (state.fG.*cfregion)./((fregion.*cfregion)+state.lamda); 
    cfH = (1 - alfa)*state.cfH + alfa*cfHnew;
    %vizualizacija
%      H = ifft2(cfH);
%      figure(2); colormap gray;
%      imagesc(fftshift(H));
%      figure(1);
%     figure(3);
%     imagesc(cor);
%     figure(1);
    
    %update struct
    state.position = state.position + displacement;
    location = [state.position - state.size / 2, state.size]; %of the target, not the region
    state.cfH = cfH;

end
