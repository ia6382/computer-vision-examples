function showflow(U, V, type)

switch (type)
    case 'color_angle'
        angle = atan2(V, U) + pi;

        Ihsv = cat(3, angle ./ (2 * pi), ones(size(angle)), ones(size(angle)));

        imshow(hsv2rgb(Ihsv));
    case 'color_magnitude'
        magnitude = sqrt(U .^ 2 + V .^ 2);
        
        I = min(1, magnitude);

        imshow(I);
    case 'color'
        angle = atan2(V, U) + pi;
        magnitude = sqrt(U .^ 2 + V .^ 2);
        
        Ihsv = cat(3, angle ./ (2 * pi), min(1, magnitude), ones(size(magnitude)));

        imshow(hsv2rgb(Ihsv));
    case 'field'    
        scaling = 0.1;
        
        u = imresize(U, scaling);
        v = imresize(V, scaling);
        
        [x, y] = meshgrid(((1:size(u, 2)) - 0.5) ./ scaling, ...
            ((1:size(u, 1)) - 0.5) ./ scaling);
        
        quiver(x, y, u * 5, v * 5, 'b');
        xlim([0, size(U, 2)]);
        ylim([0, size(U, 1)]);
        set(gca,'Ydir','reverse');
end

