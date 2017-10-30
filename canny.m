%canny.m
%By Maxx Sokal

%Replace photo.jpg with name of image you wish to perform the canny edge operator
imname = sprintf('photo.jpg');
I = imread(imname);
I = rgb2gray(I);


%CANNY EDGE
h = 5; % size for gaussian filter
sig = 5; % sigma for gaussian filter
%use Gaussian I * G
G = fspecial('gaussian', [h h], sig);
figure,
subplot(2,2,1), imshow(I), title('trees_salt020.tif');
%Ig is the image convolved with the gaussian filter
Ig = imfilter(I,G,'same');

subplot(2,2,2), imshow(Ig), title('Smoothed Image');
%Gradient Operators
%convert image to double to do calculations
Ig = double(Ig);
gx = [-1 0 1; -2 0 2; -1 0 1];
gy = [1 2 1; 0 0 0; -1 -2 -1];


dx = zeros(size(Ig,1) - 2, size(Ig,2)-2);
dy = zeros(size(Ig,1) - 2, size(Ig,2)-2);
for i = 1:size(Ig,1) - 2
    for j = 1:size(Ig,2) - 2
        % find the derivative in the x direction by (sum of 3rd row
        % multiplied by kernel) - (sum of 1st row multiplied by kernel)
        dx(i,j) = (Ig(i,j+2) + 2*(Ig(i+1, j+2)) + Ig(i+2,j+2)) - ...
            ((Ig(i,j)) + (2 * Ig(i+1,j)) + (Ig(i+2,j)));
        dy(i,j) = ( ( Ig(i+2,j)) + (2 * Ig(i+2, j+1)) + (1 * Ig(i+2, j+2))) - ...
            (Ig(i,j) + (2 * Ig(i,j+1)) + (Ig(i, j+2)));
    end
end

M = zeros(size(dx));
theta = zeros(size(dx));
for i = 1:size(M,1)
    for j = 1: size(M,2)
        M(i,j) = sqrt(dx(i,j)^2 + dy(i,j)^2);
        temp = atan2(dy(i,j), dx(i,j));
        %round theta to nearest segment
        %FOR GRADIENT:
        %any edge direction falling within :
        %  0 to 22.5 && 157.2 to 180 degrees is set to 0
        %  22.5 to 67.5 is set to 45 degrees
        %  67.5 to 112.5 is set to 90 degrees
        %  112.5 to 157.5 is set to 135 degrees.
        if (0.125 * pi <= temp && temp < 0.375 * pi)
            theta(i,j) = .25 * pi;
        elseif (0.375*pi <= temp && temp < 0.625 * pi)
            theta(i,j) = 0.5 * pi;
        elseif (0.625*pi <= temp && temp < 0.875*pi)
            theta(i,j) = .75 * pi;
        else
            theta(i,j) = 0;
        end
    end
end


% After the edge directions are known, nonmaximum suppression is applied. Nonmax supp is used
% to trace along the edge in the edge direction and suppress any pixel value (set pixel = 0)
% that is not considered to be an edge. This will give a thin line in the output image.

%Now we move to non-maximum suppression
%we thin the edges by keeping large values of gradient
%- thin broad edges in M[i,j] into ridges that are only 1 pixel wide.
% - Find local maxima in M[i,j] by suppressing all values along the line of
% the gradient that are not peak values of the ridge.


Mpad = padarray(M, [1 1]);

subplot(2,2,3), imshow(mat2gray(Mpad)), title('Magnitude');
edgemat = zeros(size(Mpad));
for i = 2:size(Mpad,1) - 1
    for j = 2:size(Mpad,2) - 1
        temp = theta(i-1,j-1);
        if (temp == 0)
            if ((Mpad(i,j) > Mpad(i,j-1)) && Mpad(i,j) > Mpad(i,j+1))
                edgemat(i,j) = Mpad(i,j);
            else
                edgemat(i,j) = 0;
            end
        elseif (temp == .25 *pi) % 45 degrees
            if (Mpad(i,j) > Mpad(i-1,j+1) && Mpad(i,j) > Mpad(i+1,j-1))
                edgemat(i,j) = Mpad(i,j);
            else
                edgemat(i,j) = 0;
            end
        elseif (temp == .5 * pi) % 90 degrees
            if (Mpad(i,j) > Mpad(i-1,j) && Mpad(i,j) > Mpad(i+1, j))
                edgemat(i,j) = Mpad(i,j);
            else
                edgemat(i,j) = 0;
            end
        else %135 degrees
            if (Mpad(i,j) > Mpad(i-1,j-1) && Mpad(i,j) > Mpad(i+1, j+1))
                edgemat(i,j) = Mpad(i,j);
            else
                edgemat(i,j) = 0;
            end
        end
    end
end

% Apply hysteresis thresholding
ht =30; %high threshold value
lt = 15; % low threshold value
%try: ht = 100, lt = 15
%typical ratio is roughly ht/lt = 2;
%edgemat = edgemat(2:end-1, 2:end-1);
hyst = zeros(size(edgemat));
for i = 2: size(edgemat,1) - 1
    for j = 2: size(edgemat,2) - 1
        if (edgemat(i,j) > ht)
            hyst(i,j) = 1;
        elseif (edgemat(i,j) < lt)
            hyst(i,j) = 0;
        else
            %check neighboring pixels for connectivity
               %4 connected, for left, right, top and bottom
            if ( ...
                (edgemat(i,j-1) > ht) || ...
                    (edgemat(i-1,j) > ht) || ...
                    (edgemat(i,j+1) > ht) || ...
                    (edgemat(i+1,j) > ht)  || ...
                (edgemat(i-1,j-1) > ht) || ...
                    (edgemat(i-1,j+1) > ht) || ...
                    (edgemat(i+1,j+1) > ht) || ...
                    (edgemat(i+1,j-1) > ht) ...
                    )
                hyst(i,j) = 1;
            else
                hyst(i,j) = 0;
            end
        end
    end
end
str = sprintf('Hysteresis edges, low = %d, high = %d',lt, ht);
subplot(2,2,4), imshow(hyst), title(str);
