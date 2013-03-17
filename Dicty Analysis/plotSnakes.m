%%%%%%%%%%%%%%%% PLOT SNAKES %%%%%%%%%%%%%%%%
%
% Plots the extracted snake boundaries on each image and saves the images. 
%
% Inputs: 
%  snakeType         - sets which iteration of the blob variable is plotted (options: 'snakeTrack, 'snakeAutoRemove', 'snakeManRemove')
%  background
%  N                 - the number of images
%  minDuration       - the minimum duration of a blob (in frames)
%  maxRegionSize     - the maximum mean size of a blob (in square pixels)
%  minSolidity       - the minimum mean solidity of a blob
%  inDirectory       - the directory in which the images are stored
%  savePath          - directory the outputed images are saved in
%
% Outputs: Saves images overlaid by snaked boundaries in the snakeType directory of savePath.

function plotSnakes(snakeType, background, N, minDuration, minRegionSize, maxRegionSize, minSolidity, inDirectory, savePath)

% load picture info 
load([savePath 'boundaries']); % frame info (loads picture)

% load snake tracks (loads blob and frame2blob)
if strcmp(snakeType, 'snakeTrack') % plots the tracked snakes
    load([savePath 'blobSnake']); 
elseif strcmp(snakeType, 'snakeAutoRemove') % plots the automatically removed snakes
    load([savePath 'blobAutoRemove']); 
elseif strcmp(snakeType, 'snakeManRemove') % plots the manually removed snakes
    load([savePath 'blobManRemove']); 
    [blob, frame2blob] = shortenBlob(N, blob, minDuration, minRegionSize, maxRegionSize, minSolidity);
else
    disp(['  Error ' snaketype ' is not a valid snakeType.'])
end

% make a directory
mkdir([savePath snakeType])

% define a colormap for the snake colors
colors = colormap(hsv(256));

% sets the figure background color
figure;
axis image
axis off
scrsz = get(0,'ScreenSize');
f=figure('Position',[5*scrsz(4)/12 2*scrsz(4)/3 scrsz(3)/2 2*scrsz(4)/3]);
set(f, 'Color', 'w');

% make the image still if there is no background
[imageRows, imageCols] = size(imread([inDirectory picture{1}.name]));
imageWhite = ones(imageRows+5, imageCols+5);
if background == 2
    imshow(imageWhite);
    hold on
end

% iterate through the frames
for i=1:N
%figure
    % plot the background image
    if background == 0
        imshow(imageWhite)
        hold on
    elseif background == 1
        imshow(im2double(imread([inDirectory picture{i}.name])))
        hold on
    end
    
    % plot the approximate boundaries
    for r = 1:length(frame2blob{1,i})
        
        % get blob ID
        ID = frame2blob{1,i}(r);
        
        % set the blob color
        blobColor=colors(mod(ID^2+100,255)+1,:);
        
        % plot the blob
        hold on
        %plot(blob{ID}.snakeNum(i-blob{ID}.startFrame+1,1:1:end,1),blob{ID}.snakeNum(i-blob{ID}.startFrame+1,1:1:end,2), 'LineWidth', 1, 'Color', blobColor);
       %size(blob{ID}.snakeDist{1,i-blob{ID}.startFrame+1})
        plot(blob{ID}.snakeDist{1,i-blob{ID}.startFrame+1}(1,:),blob{ID}.snakeDist{1,i-blob{ID}.startFrame+1}(2,:), 'LineWidth', 2, 'Color', blobColor);
    end
    hold off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(i)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % pause to allow the user to adjust the figure size
    if i==1
        pause(15); 
    end
    
    % saves the figure
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/' snakeType '/snake' num2str(i) '.tif'],'tif','Compression','none');
end