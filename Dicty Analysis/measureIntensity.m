%%%%%%%%%%%%%%%% MEASURE INTENSITY %%%%%%%%%%%%%%%%

function [intensity] = measureIntensity(N, picture, shape, snake, inDirectory)

% makes the convolution kernel
intensitySize = 11; % the mask radius is intensity_size plus 1/2
ksize = 2*intensitySize+1;

convolveMask = zeros(ksize);
for x=1:ksize; % x-direction
     for y=1:ksize; % y-direction
          convolveMask(y,x) = (((x-intensitySize-1).^2+(y-intensitySize-1).^2)<=intensitySize^2);
     end
end

for i=1:N
    
    % constructs a binary mask of all the nuclei in the image
    imageMask = zeros(picture(i).size);
    for r=1:length(shape(i).nuclei)
        imageMask = imageMask+poly2mask(snake(i).nuclei(r).posDist(1,:), snake(i).nuclei(r).posDist(2,:), picture(i).size(1,1), picture(i).size(1,2)); 
    end
    
    % makes the nuclei edges have value 0.5
    edgeMask = zeros(picture(i).size);
    for r=1:length(snake(i).nuclei) % iterate through the nuclei
        for j=1:length(snake(i).nuclei(r).posDist)  % iterate through the boundary points
            edgeMask(round(snake(i).nuclei(r).posDist(2,j)), round(snake(i).nuclei(r).posDist(1,j))) = 0.5;
        end
    end
    imageMask = imageMask-edgeMask;
    
    % loads the original image
    imageGray = im2double(imread([inDirectory picture(i).name]));
    
    % adds a border to the mask and original image
    imageGrayBorder = makeBorder(imageGray, intensitySize);
    imageMaskBorder = makeBorder(imageMask, intensitySize);
    
    % finds the average intensity near each boundary point        
    for r=1:length(snake(i).nuclei) % iterate through the nuclei
        for j=1:length(snake(i).nuclei(r).posDist)  % iterate through the boundary points
            bpY = round(snake(i).nuclei(r).posDist(1,j))+intensitySize;
            bpX = round(snake(i).nuclei(r).posDist(2,j))+intensitySize;
            toAreaCount = convolveMask.*imageMaskBorder((bpX-intensitySize):(bpX+intensitySize), (bpY-intensitySize):(bpY+intensitySize));
            areaCount = sum(sum(toAreaCount));
            intensityCount = sum(sum(toAreaCount.*imageGrayBorder((bpX-intensitySize):(bpX+intensitySize), (bpY-intensitySize):(bpY+intensitySize))     ));
            intensity(i).nuclei(r).mean(j) = 255*intensityCount/areaCount;
        end
    end
end