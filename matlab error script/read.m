function image = read(directory)
[image, ~, ~] = imread(directory);
if size(image,3) == 3
    image = rgb2gray(image);
end
image = im2uint8(image);