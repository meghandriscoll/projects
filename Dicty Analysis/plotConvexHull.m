%%%%%%%%%%%%%%%% plotConvexHull %%%%%%%%%%%%%%%%

% Plots the extracted convex hulls on an image and saves the images in a
% directory in the 'savePath'.

% Inputs:
%  plotCH           - sets the background image 
%                       options: 'original'  - original image
%                                'originalA' - brightness and contrast enhanced image
%                                'NBW'       - nearly binarized image                 
%  N                - the number of images
%  picture          - an output of findConvexHull.m
%  imageAdjustSize  - the spatial scale over which the histogram is adjusted (in pixels)
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images overlaid by convex hulls in the 'convexHull' directory of 'savePath'


function plotConvexHull(plotCH, N, picture, imageAdjustSize, inDirectory, savePath)

mkdir([savePath 'convexHull'])
figure;
for i=1:N

    % plot the background image
    switch plotCH
        case 'original'
            imshow(im2double(imread([inDirectory picture(i).name])))
        case 'originalA'
            imshow(imadjust(im2double(imread([inDirectory picture(i).name]))))
        case 'NBW'
            imshow(makeNBW(inDirectory, picture(i).name, imageAdjustSize))
        case 'gradNBW'
            imshow(abs(gradient2(makeNBW(inDirectory, picture(i).name, imageAdjustSize))))
        otherwise
            imshow(im2double(imread([inDirectory picture(i).name])))
    end

    % plot the convex hulls
    for r = 1:length(picture(i).CHLstats)
        hold on
        plot(picture(i).CHSstats(r).ConvexHull(:,1),picture(i).CHSstats(r).ConvexHull(:,2), 'LineWidth', 1, 'Color', 'b')
        plot(picture(i).boundary{r}(:,2),picture(i).boundary{r}(:,1), 'LineWidth', 1, 'Color','r')
    end
    hold off
    axis image
    axis off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(picture(i).number)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % saves the figure
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/convexHull/' plotCH '_' num2str(i) '.tif'],'tif','Compression','none');
end