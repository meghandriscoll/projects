%%%%%%%%%%%%%%%% PLOT SNAKE BOUNDARIES %%%%%%%%%%%%%%%%

% Plots the extracted convex hulls on an image and saves the images in a
% directory in the 'savePath'.

% Inputs:
%  plotS           - sets the background image 
%                       options: 'original'  - original image
%                                'originalA' - brightness and contrast enhanced image                
%  N                - the number of images
%  picture          - an output of findConvexHull.m
%  imageAdjustSize  - the spatial scale over which the histogram is adjusted (in pixels)
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images overlaid by convex hulls in the 'convexHull' directory of 'savePath'


function plotSnake(plotS, N, picture, snake, inDirectory, savePath)

mkdir([savePath 'snakeBoundaries'])

% define colormaps
colors=colormap(hsv(32));

%%%% make the directory name input dependant
%figure
for i=1:1:N
    figure
    %plot the background image
    switch plotS
        case 'original'
            imshow(im2double(imread([inDirectory picture(i).name])))
        case 'originalA'
            imshow(imadjust(im2double(imread([inDirectory picture(i).name]))))
        otherwise
            imshow(im2double(imread([inDirectory picture(i).name])))
    end

    % plot the snake boundaries
    if isfield(snake(i).nuclei(1),'trackID')
        for r = 1:length(snake(i).nuclei)
            colorID = colors(mod(snake(i).nuclei(r).trackID,32)+1,:);
            hold on
            plot(snake(i).nuclei(r).posNum(1,:),snake(i).nuclei(r).posNum(2,:), 'LineWidth', 1, 'Color', colorID)
        end
    else
        for r = 1:length(snake(i).nuclei)
            hold on
            plot(snake(i).nuclei(r).posNum(1,:),snake(i).nuclei(r).posNum(2,:), 'LineWidth', 1, 'Color', 'r')
        end
    end
    hold off
    axis image
    axis off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(picture(i).number)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % saves the figure
    pause(0.1)
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/snakeBoundaries/' plotS '_' num2str(i) '.tif'],'tif','Compression','none');
    

end