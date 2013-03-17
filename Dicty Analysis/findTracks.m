%%%%%%%%%%%%%%%% FIND TRACKS %%%%%%%%%%%%%%%%

% Associate each nuclei in each image with a trackID

% If there is more than one trackID inside a region, or no trackID, the
% snake should be removed

function snakeT = findTracks(snake, N, picture, trackDirectory)
% load track data (smoothedTracks, etc ...)
baseDirectory = [trackDirectory '/MATLAB/'];
toLoad = sprintf('%s/allStatsROI1', baseDirectory);
load(toLoad);
toLoad = sprintf('%s/parems', baseDirectory);
load(toLoad);

smoothedTracks(3000,3)
smoothedTracks(10000,3)

% iterate through smoothedTracks in order to associate each trackID with a nuclei
[numTracks, cols] = size(smoothedTracks); 
lastFrame = -1; % using smoothed Tracks numbering
for t=1:9484%300%10157% 2885 %300 numTracks 
    t
    if lastFrame ~= smoothedTracks(t,3)
        
        % display progress
        %if mod(smoothedTracks(t,3),100) == 0
            disp([' frame: ' num2str(smoothedTracks(t,3))]); 
        %end
        
        % make a labeled mask of the regions
        
        imageMask = zeros(picture(lastFrame+2).size);
        for r=1:length(snake(lastFrame+2).nuclei)
        
            % label a single region
            regionMask = r.*poly2mask(snake(lastFrame+2).nuclei(r).posNum(1,:), snake(lastFrame+2).nuclei(r).posNum(2,:), picture(lastFrame+2).size(1,1), picture(lastFrame+2).size(1,2));
    
            % combine that region into the overall mask
            imageMask = imageMask+regionMask;
        end
        
%         centers=[];
%         for r=1:length(snake(lastFrame+2).nuclei)
%             centers = [centers; mean(snake(lastFrame+2).nuclei(r).posDist(1,:)), mean(snake(lastFrame+2).nuclei(r).posDist(2,:))];
%         end
        
        currentFrame = lastFrame+2;       

%         figure
%         imagesc(imageMask)
%         hold on
    end
%       dist = (centers(:,1)-round(smoothedTracks(t,1))).^2+(centers(:,2)-round(smoothedTracks(t,2))).^2; % the dist from the current centroid to all centroids
      region = imageMask(round(smoothedTracks(t,2)), round(smoothedTracks(t,1)));

%     plot(round(smoothedTracks(t,1)), round(smoothedTracks(t,2)),'Marker', '.', 'Color','k')
%     hold on
%     axis ij   
    
    if region
        if isfield(snake(currentFrame).nuclei(region), 'trackID')
            snake(currentFrame).nuclei(region).trackID = [snake(currentFrame).nuclei(region).trackID, smoothedTracks(t,4)];
        else
            snake(currentFrame).nuclei(region).trackID = smoothedTracks(t,4);
        end
    end

%     if min(dist) < 2
%         region = find(dist==min(dist));
%         if isfield(snake(currentFrame).nuclei(region), 'trackID')
%             snake(currentFrame).nuclei(region).trackID = [snake(currentFrame).nuclei(region).trackID, smoothedTracks(t,4)];
%         else
%             snake(currentFrame).nuclei(region).trackID = smoothedTracks(t,4);
%         end
%     end 

    lastFrame = smoothedTracks(t,3);
end

% add only good regions to snakeT
% (good regions are those that are associated with exactly one trackID)
for i=1:N
    label = 1;
    for r=1:length(snake(i).nuclei)
        if isfield(snake(i).nuclei(r), 'trackID') && length(snake(i).nuclei(r).trackID) == 1 
            snakeT(i).nuclei(label) = snake(i).nuclei(r);
            label = label+1;
        end
    end
end
