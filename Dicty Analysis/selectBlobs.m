%%%%%%%%%%%%%%%% SELECT SNAKES %%%%%%%%%%%%%%%%

% Allow the user to select blobs to remove from further analysis.

% Inputs:             
%  N                - the number of images
%  blob             - track information
%  frame2blob       - provides the IDs of the nonremoved blobs in every frame
%  picture          - contains frame information
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the binarized, labeld images are stored in
%
% Outputs:
%  blob(ID)
%  frame2blob       - a cell array of size {1,number of frames}, each cell lists the IDs of the non-removed blobs in that frame 

function [blob, frame2blob] = selectSnakes(N, blob, frame2blob, checkFrame, picture, inDirectory, savePath)

% define a colormap for the snake colors
colors = colormap(hsv(256));

fig=figure;
for i=1:checkFrame:N
    
    % plot the background image
    imshow(im2double(imread([inDirectory picture(i).name])))
    
    % load the binary, labeled image (called 'labeled')
    load([savePath 'labeledImages/image' picture(i).number]);
    
    % plot the approximate boundaries
    region2ID = zeros(1,max(max(labeled))); % will give the ID of the blob at the label corresponding to the index
    for r = 1:length(frame2blob{1,i})
        
        % get blob ID, and set region2ID
        ID = frame2blob{1,i}(r);
        region2ID(1,blob(ID).labels(i-blob(ID).startFrame+1)) = ID;
        
        % set the blob color
        blobColor=colors(mod(ID^2+100,255)+1,:);
        
        % plot the blob
        if blob(ID).removed ~= 1
            hold on
            plot(blob(ID).snakeNum(i-blob(ID).startFrame+1,:,1),blob(ID).snakeNum(i-blob(ID).startFrame+1,:,2), 'LineWidth', 1.5, 'Color', blobColor)
        end
    end
    hold off
    axis image
    axis off
                 
    % titles the figure
    toTitle = ['Click to select regions for removal.  Enter to go to the next image. ' '(Image Number ' num2str(picture(i).number) ')'];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % gets points for region removal
    [toRemove(i).y, toRemove(i).x] = getpts(fig);

    % find regions to remove
    for m=1:length(toRemove(i).x)
        badRegion = labeled(round(toRemove(i).x(m)), round(toRemove(i).y(m)));
        blob(region2ID(1,badRegion)).removed = 1;
    end
end

close(fig)

% remake frame2blob
frame2blob = cell(1, N); 
for b=1:length(blob)
    
    % the blob has not been removed, so add its frames to frame2blob    
    if blob(b).removed == 0
        for f = blob(b).startFrame:blob(b).endFrame
            frame2blob{1,f} = [frame2blob{1,f}, b];
        end
    end
    
end

