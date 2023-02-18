hh = 10; %padding around center for region size
h = hh*2+1 %size of region
N = h*h; %number of points in the region
e = 0.5; %convergance limit

%load kde(pdf) function 
load('tabulated.mat');

%x = -50:50;
%[X, Y] = meshgrid(x, x);
%Z=exp(-1/20^2*((X-20).^2+(Y).^2)) - exp(-1/15^2*((X).^2+(Y-10).^2)) + exp(-1/10^3*((X).^2+(Y-30).^2)) + exp(-1/20^2*((X+20).^2+(Y).^2));
%Z = Z-(min(Z(:)));
%Z = Z./max(Z(:));

%choose starting point, right click once
imagesc(responses);
xk1 = ginput(1);

%draw search region square
s1 = [(xk1(1)-hh), (xk1(1)+hh), (xk1(1)+hh), (xk1(1)-hh), (xk1(1)-hh)];
s2 = [(xk1(2)-hh), (xk1(2)-hh), (xk1(2)+hh), (xk1(2)+hh), (xk1(2)-hh)];
hold on;plot(s1, s2, 'r-', 'LineWidth', 1);

[X, Y] = meshgrid((-hh:hh), (-hh:hh)); % matrices of coordinates for faster calculation of sum in the next step

iter = 0;
m = 2;
while(m > e)
    %extract region of weights around starting point
    x = (xk1(1)-hh):(xk1(1)+hh);
    y = (xk1(2)-hh):(xk1(2)+hh);
    W = responses(uint8(y), uint8(x));

    %[X, Y] = meshgrid(x, y); % matrices of coordinates for faster calculation of sum in the next step

    %calculate next mean in the region
    xk2x = sum(sum(double(X).*W))./ sum(W(:));
    xk2y = sum(sum(double(Y).*W))./ sum(W(:));
    m = [xk2x, xk2y];
    
    %calculate next mean (center)
    xk2 = xk1 + m;
    m = norm(m); %vector size

    %new iteration
    xk1 = xk2;
    %show new point
    hold on;plot(xk1(1), xk1(2), 'r*');
    iter = iter + 1;
end

%print iteration number
iter





