%%%%%%%%%%%%%%%% MAKE NBW %%%%%%%%%%%%%%%%

% Makes an image nearly black and white.

% Inputs:
%  inDirectory      - the directory the image is in
%  name             - the name of the image 
%  imageAdjustSize  - the spatial scale over which the histogram is adjusted (in pixels)

% Outputs:
%  imageNBW         - the nearly binarized image


function imageNBW = makeNBW(inDirectory, name, imageAdjustSize)

% load the image
image = im2double(imread([inDirectory name]));

% smooth the image
h = fspecial('average', [3,3]); 
image = imfilter(image, h);

% equalize the histogram
image = adapthisteq(image,'NumTiles', round(size(image)/imageAdjustSize),'clipLimit',0.02,'Distribution','rayleigh');

% nearly binarize the image
bwLevel = graythresh(image);
imageNBW = imadjust(image,[0.97*bwLevel; 1.1*bwLevel],[0,1]);

% fill holes
for v=0:0.1:0.7
    imageB = (image >= 1-v);
    imageB = (1-v)*imfill(imageB,'holes');
    imageNBW = max(imageNBW, imageB);
end