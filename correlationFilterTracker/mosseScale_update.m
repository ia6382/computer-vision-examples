function [state, location] = mosseScale_update(state, I, varargin)
    alfa = 0.01; %hitrost updatanja
    scaleFactor = 0.10;
    gama = 0.3;
    
    img = double(rgb2gray(I));
    
    %extract 3 patches(regions) with different sizes
    regionSame = get_patch(img, state.position, state.scale, state.size);
    regionSame = imresize(regionSame, size(state.C));
    regionSame = regionSame - mean(regionSame(:));
    responseSame = getResponse(state, regionSame);
    
    regionBigger = get_patch(img, state.position, state.scale+scaleFactor, state.size);
    regionBigger = regionBigger - mean(regionBigger(:));
    regionBigger = imresize(regionBigger, size(state.C));
    responseBigger = getResponse(state, regionBigger);
    
    regionSmaller = get_patch(img, state.position, state.scale-scaleFactor, state.size);
    regionSmaller = regionSmaller - mean(regionSmaller(:));
    regionSmaller = imresize(regionSmaller, size(state.C));
    responseSmaller = getResponse(state, regionSmaller);
    
    %choose the one with the biggest response
	newSize = state.size;
    if (responseBigger > responseSame)
        newSize = floor(state.size*(1+scaleFactor));
    end
    if (responseSmaller > responseSame) && (responseSmaller > responseBigger)
       	newSize = floor(state.size*(1-scaleFactor));
    end
    %update size - prevent oversensitive scale adaptation
    state.size = (1-gama)*state.size + gama*newSize;
    region = get_patch(img, state.position, state.scale, state.size);
    region = region - mean(region(:));
    region = imresize(region, size(state.C));
    
    
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
    region = imresize(region, size(state.C));
    
    fregion = fft2(region);
    cfregion = conj(fregion);
    cfHnew = (state.fG.*cfregion)./((fregion.*cfregion)+state.lamda); 
    cfH = (1 - alfa)*state.cfH + alfa*cfHnew;
    %vizualizacija
%     H = ifft2(cfH);
%     figure(2); colormap gray;
%     imagesc(fftshift(H));
%     figure(1);
%     figure(3);
%     imagesc(cor);
%     figure(1);
    
    %update struct
    state.position = state.position + displacement;
    location = [state.position - state.size / 2, state.size]; %of the target, not the region
    state.cfH = cfH;

end
