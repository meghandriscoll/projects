%%%%%%%%%%%%%%%% SELECT REGIONS %%%%%%%%%%%%%%%%

% Select regions to remove from further analysis.

% Inputs:             
%  N                - the number of images
%  picture          - an output of findConvexHull.m
%  snake            - the output of findSnake.m
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs:
%  toRemove(i).x    - coordinates within regions that should be removed
%  toRemove(i).y    

% make a bad id list and check each nuclei against it.
% don't match snakes to ids if the centroids are too far apart.


function snakeR = selectRegions(N, picture, snake, minRegionSize, inDirectory)

% define the boundary colors
colors=colormap(hsv(32));

% remove the IDs on this list from further consideration
removeIDs = []; 

fig=figure;
for i=1:N
    
    % plot the background image
    imshow(imadjust(im2double(imread([inDirectory picture(i).name]))));
             
    % plot the snake boundaries
    badRegions = [];
    for r = 1:length(snake(i).nuclei)
        if isempty(find(removeIDs==snake(i).nuclei(r).trackID))
            hold on
            %randColor = colors(ceil(32*rand(1)),:);
            colorID = colors(mod(snake(i).nuclei(r).trackID,32)+1,:);
            plot(snake(i).nuclei(r).posNum(1,:),snake(i).nuclei(r).posNum(2,:), 'LineWidth', 1.5, 'Color', colorID)
        else
            badRegions = [badRegions, r];
        end

    end
    hold off
    axis image
    axis off
    
    % titles the figure
    toTitle = ['Click to select regions for removal.  Enter to go to the next image. ' '(Patient ' num2str(picture(i).patient) '; Drug ' num2str(picture(i).drug) '; Image Number ' num2str(picture(i).number) ')'];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % gets points for region removal
    [toRemove(i).y, toRemove(i).x] = getpts(fig);
    
    % make a labeled mask of the regions
    imageMask = zeros(picture(i).size);
    for r=1:length(snake(i).nuclei)
        
        % label a single region
        regionMask = r.*poly2mask(snake(i).nuclei(r).posNum(1,:), snake(i).nuclei(r).posNum(2,:), picture(i).size(1,1), picture(i).size(1,2));
    
        % combine that region into the overall mask
        imageMask = imageMask+regionMask;
        
    end

    % find regions to remove
    for m=1:length(toRemove(i).x)
        bad = imageMask(ceil(toRemove(i).x(m)), ceil(toRemove(i).y(m)));
        badRegions = [badRegions, bad];
        removeIDs = [removeIDs, snake(i).nuclei(bad).trackID];
    end
      
    % remove the bad regions
    if ~isempty(badRegions)   
        label = 1;
        for r=1:length(snake(i).nuclei)           
            if isempty(badRegions(badRegions==r))
                snakeR(i).nuclei(label) = snake(i).nuclei(r);
                label = label+1;
            end
        end
    else
       snakeR(i) = snake(i);
    end

end

close(fig)