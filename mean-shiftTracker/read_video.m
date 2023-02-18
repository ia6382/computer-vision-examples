function video = read_video(directory)

mask = '%08d.jpg';
l = 1;

while true
    if exist(fullfile(directory, sprintf(mask, l)), 'file')
        l = l + 1;
    else
        l = l - 1;
        break;
    end
end

if l == 0
    error('Unable to read video from the directory.');
end;

first = imread(fullfile(directory, sprintf(mask, 1)));

[h, w, c] = size(first);
video = uint8(zeros([h, w, c, l]));
video(:, :, :, 1) = first;

for i = 2:l
    video(:, :, :, i) = imread(fullfile(directory, sprintf(mask, i)));
end
