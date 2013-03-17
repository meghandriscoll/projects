%%%%%%%%%%%%%%%% FIND BOUNDARIES %%%%%%%%%%%%%%%%

% Processes the images to find the convex hulls and approximate boundaries
%
% Inputs:
%  N
%  minRegionSize    - the minimum size, in square pixels, of a blob
%  adjustGamma      - the adjusted gamma of the image prior to binarization (deals with varying blob brightness)
%  erodeImage       - number of pixels the binary image is eroded prior to labeling
%  dilateImage      - number of pixels the binary image is next dilated prior to labeling (smooths the outline)
%  dilateLargeCH    - number of pixels the binary image is dilated prior to finding the large convex hull
%  inDirectory      - directory the original images are stored in 
%  savePath         - the location where data is saved
%
% Saves:
%  picture(i)
%   .size           - the size of the image
%   .bwLevel        - thresholding level (a number in [0,1])
%   .CHSstats(j)    - inner convex hulls, areas, centroids, and solidities
%   .CHLstats(j)    - outer convex hulls and bounding boxes
%   .boundary       - approximate boundary
%  Saves binarized, labeled versions of every frame in [savePath 'labeledImages/image'] as variables named 'labeled' in image[#].

function findBoundaries(N, minRegionSize, noiseLevelAdd, adjustGammaPre, adjustGammaPost, erodeImage, dilateImage, dilateLargeCH, inDirectory, savePath)

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)

% create a directory for the labeled images
mkdir([savePath 'labeledImages'])

% iterates through every frame
parfor i=1:N
    
    %display progress
    display(['   image ' num2str(i)])
    
    % find approximate boundaries
    [pictSize, threshlevel, CHSstats, boundary, CHLstats] = findBoundariesInImage(picture{i}.name, picture{i}.number, minRegionSize, noiseLevelAdd, adjustGammaPre, adjustGammaPost, erodeImage, dilateImage, dilateLargeCH, inDirectory, savePath);
    
    % assign values to picture
    picture{i}.size = pictSize;
    picture{i}.bwlevel = threshlevel;
    picture{i}.CHSstats = CHSstats;
    picture{i}.boundary = boundary;
    picture{i}.CHLstats = CHLstats;
end

% save the variables
save([savePath 'boundaries'], 'picture');


function [pictSize, threshLevel, CHSstats, boundary, CHLstats] = findBoundariesInImage(pictureName, pictureNumber, minRegionSize, noiseLevelAdd, adjustGammaPre, adjustGammaPost, erodeImage, dilateImage, dilateLargeCH, inDirectory, savePath)

% loads the image
image = im2double(imread([inDirectory pictureName]));
pictSize = size(image);

% adjust the histogram
image = image+noiseLevelAdd*rand(size(image));
image = imadjust(image,[0 1], [0 1],adjustGammaPre);
image = imadjust(image);
image = imadjust(image,[0 1], [0 1], adjustGammaPost);

% threshold and binarize
threshLevel = graythresh(image);
image = im2bw(image, threshLevel); 

% removes small objects
image = bwareaopen(image, minRegionSize, 4);

% fill holes
image = imfill(image,'holes');

% erode
image = imerode(image,strel('disk',erodeImage));

% dilate
image = imdilate(image,strel('disk',dilateImage));

% remove objects near the border
image = imclearborder(image);

% removes small objects
image = bwareaopen(image, minRegionSize);

% labels the images
image = bwlabel(image);

% saves the images
labeled = image;
save([savePath 'labeledImages/image' pictureNumber],'labeled');

% finds the convex hulls and approximate boundaries
CHSstats = regionprops(image, 'ConvexHull', 'Area', 'Centroid', 'Solidity');
boundary = bwboundaries(image);

% dilates the image to find the larger convex hulls
imageLarge = imdilate(image,strel('disk',dilateLargeCH));
CHLstats = regionprops(imageLarge, 'BoundingBox', 'ConvexHull');



%%%%% Non-parallel version
% % load saved variables
% load([savePath 'boundaries']); % frame info (loads picture)
% 
% % create a directory for the labeled images
% mkdir([savePath 'labeledImages'])
% 
% % iterates through every frame
% for i=1:N
%     
%     % loads the image
%     display(['   image ' num2str(i)])
%     image = im2double(imread([inDirectory picture(i).name]));
%     picture(i).size = size(image);
%     
%     % adjust the histogram
%     image = image+noiseLevelAdd*rand(size(image));
%     image = imadjust(image,[0 1],[0 1],adjustGammaPre);
%     image = imadjust(image);
%     image = imadjust(image,[0 1], [0 1], adjustGammaPost);
% 
%     % threshold and binarize
%     picture(i).bwLevel = graythresh(image);
%     image = im2bw(image, picture(i).bwLevel); 
%         
%     % removes small objects
%     image = bwareaopen(image, minRegionSize, 4);
% 
%     % fill holes
%     image = imfill(image,'holes');
% 
%     % erode
%     image = imerode(image,strel('disk',erodeImage));
%     
%     % dilate
%     image = imdilate(image,strel('disk',dilateImage));
%     
%     % remove objects near the border
%     image = imclearborder(image);
%     
%     % removes small objects
%     image = bwareaopen(image, minRegionSize);
%     
%     % labels the images
%     image = bwlabel(image);
%     
%     % saves the images
%     labeled = image;
%     save([savePath 'labeledImages/image' picture(i).number],'labeled');
% 
%     % finds the convex hulls and approximate boundaries
%     picture(i).CHSstats = regionprops(image, 'ConvexHull', 'Area', 'Centroid', 'Solidity');
%     picture(i).boundary = bwboundaries(image);
%     
%     % dilates the image to find the larger convex hulls
%     imageLarge = imdilate(image,strel('disk',dilateLargeCH));
%     picture(i).CHLstats = regionprops(imageLarge, 'BoundingBox', 'ConvexHull');
%     
% end
% 
% % save the variables
% save([savePath 'boundaries'], 'picture');