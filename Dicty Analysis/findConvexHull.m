%%%%%%%%%%%%%%%% FIND CONVEX HULL %%%%%%%%%%%%%%%%

% Processes the images to find the convex hulls and the nearly binarized images.

% Inputs:
%  N, picture       - outputs from readDirectory
%  minRegionSize    - the minimum size, in square pixels, of a nucleus
%  inDirectory      - directory the original images are stored in 

% Outputs:
%  picture(i)
%   .size           - the size of the image
%   .bwLevel        - thresholding level (a number in [0,1])
%   .CHSstats(j)    - inner convex hulls
%   .CHLstats(j)    - outer convex hulls

function picture = findBoundaries(N, picture, minRegionSize, inDirectory)

for i=1:N
    
    display(['   image ' num2str(i)])
    image = im2double(imread([inDirectory picture(i).name]));
    picture(i).size = size(image);
    
    %figure; imagesc(image);

    % adjust the histogram
    %image = adapthisteq(image,'NumTiles', [16,16],'clipLimit',0.02,'Distribution','rayleigh');
    image = imadjust(image);
    image = imadjust(image,[],[],0.3);

    %figure; imagesc(image);
    
    % threshold and binarize
    picture(i).bwLevel = graythresh(image);
    image = im2bw(image, picture(i).bwLevel);
    
    %figure; imagesc(image);

    % fill holes
    image = imfill(image,'holes');

    % remove objects near the border
    image = imclearborder(image);
    
    %figure; imagesc(image);

    % erode
    image = imerode(image,strel('disk',2));
    
    %figure; imagesc(image);
    
    % dilate
    image = imdilate(image,strel('disk',4));
    
    % removes small objects
    image = bwareaopen(image, minRegionSize);
    
    %figure; imagesc(image);

    % labels the image
    image = bwlabel(image);
    
    %figure; imagesc(image);

    % finds the convex hulls and image boundaries
    imageLarge = imdilate(image,strel('disk',5));
    picture(i).CHLstats = regionprops(imageLarge, 'BoundingBox', 'ConvexHull');
    imageSmall = imerode(image,strel('disk',1));
    picture(i).CHSstats = regionprops(imageSmall, 'ConvexHull');
    imageBoundary = imdilate(image,strel('disk',2));
    picture(i).boundary = bwboundaries(imageBoundary);
    
end