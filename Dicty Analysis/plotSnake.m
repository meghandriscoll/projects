%%%%%%%%%%%%%%%% PLOT SNAKES%%%%%%%%%%%%%%%%
%
% Plots the extracted snake boundaries on each image and saves the images. 
%
% Inputs:
%  plotS           - sets the background image 
%                       options: 'original'  - original image
%                                'originalA' - brightness and contrast enhanced image                
%  N                - the number of images
%  blob             - track information
%  frame2blob       - provides the IDs of the nonremoved blobs in every frame
%  picture          - binarized frame information, including snake initializations
%  inDirectory      - the directory in which the images are stored
%
%  savePath         - directory the outputed images are saved in
%
% Outputs: Saves images overlaid by snaked boundaries in the 'snakeBoundaries' directory of 'savePath'

function plotSnakes(plotS, N, blob, frame2blob, picture, inDirectory, savePath)

mkdir([savePath 'snakeBoundaries'])

% define a colormap for the snake colors
colors = colormap(hsv(256));

% iterate through the frames
figure;
for i=1:N

    % plot the background image
    imshow(im2double(imread([inDirectory picture(i).name])))
    
    % plot the approximate boundaries
    for r = 1:length(frame2blob{1,i})
        
        % get blob ID
        ID = frame2blob{1,i}(r);
        
        % set the blob color
        blobColor=colors(mod(ID^2+100,255)+1,:);
        
        % plot the blob
        hold on
        plot(blob(ID).snakeNum(i,:,1),blob(ID).snakeNum(i,:,2), 'LineWidth', 2, 'Color', blobColor)
    end
    hold off
    axis image
    axis off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(i)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % pause to allow the user to adjust the figure size
    if i==1
        pause(10); 
    end
    
    % saves the figure
    pause(0.1)
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/snakeBoundaries/' plotS '_' num2str(i) '.tif'],'tif','Compression','none');
end