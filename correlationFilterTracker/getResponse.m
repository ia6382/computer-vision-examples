function response = getResponse(state, region)
    %apply cos on region
    region = region.*state.C;
    fregion = fft2(region);

    %calculate corelation with filter h
    fcor = fregion.*state.cfH;
    cor = ifft2(fcor);
    
    %find max position of corelation = new center in local coordinates
    [~,i] = max(cor(:));
    [y, x] = ind2sub(size(cor),i);
    response = region(y, x);

end