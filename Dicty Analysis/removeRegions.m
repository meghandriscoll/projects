%%%%%%%%%%%%%%%% REMOVE REGIONS %%%%%%%%%%%%%%%%

% Select regions to remove from further analysis.

% Inputs:
%  toRemove
%  N                - the number of images
%  picture          - an output of findConvexHull.m
%  snake            - the output of findSnake.m

% Outputs:
%  snakeR   

function snakeR = removeRegions(toRemove, N, picture, snake)

for i=1:N
    
    % make a labeled mask of the regions
    imageMask = zeros(picture(i).size);
    for r=1:length(snake(i).nuclei)
        
        % label a single region
        regionMask = r.*poly2mask(snake(i).nuclei(r).posNum(1,:), snake(i).nuclei(r).posNum(2,:), picture(i).size(1,1), picture(i).size(1,2));
    
        % combine that region into the overall mask
        imageMask = imageMask+regionMask;
        
    end

    % find regions to remove
    badRegions = [];
    for r=1:length(toRemove(i).x)
        badRegions = [badRegions, imageMask(ceil(toRemove(i).x(r)), ceil(toRemove(i).y(r)))];
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
