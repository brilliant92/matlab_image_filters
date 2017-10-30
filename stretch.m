%stretch.m
% Stretches an image to have better contrast.
% By: Maxx Sokal, ID# 301235422, msokal@sfu.ca

%%MAXX NOTES: what you want to do is determine a and b in the histogram
%%(color varaition) and even out the boxes to differentiate more between
%%grayscale values.

%read the image
imname = sprintf('lena.jpg');
im = imread(imname);
im = rgb2gray(im);
figure;
subplot(2,2,1),imshow(im), title(imname);
subplot(2,2,2), imhist(im), title('Image histogram');
%display a histogram for the image in order to choose a and b values
%figure; imhist(im);
 %with a = 5, and b = 100 the contrast between building values is very
 %apparent
a = 25;
b = 225;
p0 = 0;
pm = 255;
imstretch = zeros(size(im));

%Here we iterate through pixels using a for loop
for i = 1:size(im, 1)
    for j = 1:size(im, 2)
        if im(i,j) < a
            imstretch(i,j) = 0;
        elseif im(i, j) > b 
            imstretch(i, j) = 255;
        else
            val = ((pm/(b-a)) * (im(i,j) - a));
            imstretch(i, j) = val;
        end
    end
end
imstretch = mat2gray(imstretch);
%figure; 
str = sprintf('Stretch image, a = %d, b = %d', a, b);
subplot(2,2,3), imshow(imstretch), title(str);
%figure; imhist(imstretch);

%here we do histogram equalization on the same image

imeq = zeros(size(im));
%let p denote the normalized histogram for image im
[counts, binLoc] = imhist(im);
%figure; stem(binLoc, counts);

%J is the histeq showing the contrast in the image from histogram
%equalization
J = histeq(im);
subplot(2,2,4), imshow(J), title('dark.tif histogram equalization');

    
