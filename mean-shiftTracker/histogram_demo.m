
I = imread('00000001.jpg');

region = [93, 71, 146, 168];

R = I(region(2):region(4), region(1):region(3), :);

H = extract_histogram(R, 16);

B = backproject_histogram(I, H);

figure;
subplot(1, 3, 1); imshow(I); title('Original image');
subplot(1, 3, 2); imshow(R); title('Region of interest');
subplot(1, 3, 3); imagesc(B);title('Projected histogram');
