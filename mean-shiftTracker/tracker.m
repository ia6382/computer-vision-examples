%parameters
sigma = 1;
alfa = 0.05;
e = 1e-1;

frame = 1;
video = read_video('test\');
%read frame
I = video(:,:,:,frame);
imshow(I);

%select search region square
rect = getrect;
xs=rect(1);
ys=rect(2);
ws=rect(3);
hs=rect(4);

%draw search region square
s1 = [xs, xs+ws, xs+ws, xs, xs];
s2 = [ys, ys, ys+hs, ys+hs, ys];
hold on;plot(s1, s2, 'y-', 'LineWidth', 1);

%**********************INITIALIZATION
%get epanechnik kernel
eK = create_epanechnik_kernel(ws, hs, sigma); % dimensions of search region

%extract histogram q from chosen region
x = (xs):(xs + size(eK,2)-1);
y = (ys):(ys + size(eK,1)-1);
S = I(int32(y), int32(x), :);

%get weighted histogram from template
Q = extract_histogram(S, 16, eK);


%***********************SEARCHING
%search in next frame
frame = frame + 1;
I = video(:,:,:,frame);
imshow(I);

%extract region (from previous step)
R = I(int32(y), int32(x), :);

%get weighted histogram from search region
P = extract_histogram(R, 16, eK);

%calculate weight for each colour bin from template and current region
Q = Q/sum(Q(:));
P = P/sum(P(:));
V = sqrt((Q)./((P+e)));
V = V/sum(V(:));

%backproject into the search region
W = backproject_histogram(R, V);
imagesc(W);

%MS

%update template histogram Q



