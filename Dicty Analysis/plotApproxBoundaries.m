%%%%%%%%%%%%%%%% PLOT APPROXIMATE BOUNDARIES %%%%%%%%%%%%%%%%

% Plots the extracted approximate boundaries on an image and saves the images 
% in a directory in 'savePath'.

% Inputs:            
%  N                - the number of images
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images overlaid by the approximate boundaries in the 'approxBoundary' directory of 'savePath'

function plotApproxBoundaries(N, inDirectory, savePath)

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)

% make a new directory
mkdir([savePath 'approxBoundary'])

% iterate through the images
figure;
axis image
axis off
for i=1:N

    % plot the background image
    imshow(im2double(imadjust(imread([inDirectory picture{i}.name]))))

    % plot the approximate boundaries
    for r = 1:length(picture{i}.boundary)
        hold on
        plot(picture{i}.boundary{r}(:,2),picture{i}.boundary{r}(:,1), 'LineWidth', 2, 'Color','r')
    end
    hold off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(picture{i}.number)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % pause to allow the user to adjust the figure size
    if i==1
        pause(10); 
    end
    
    % saves the figure
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/approxBoundary/image_' num2str(i) '.tif'],'tif','Compression','none');
end