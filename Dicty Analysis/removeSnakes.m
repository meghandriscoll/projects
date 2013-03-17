%%%%%%%%%%%%%%%% REMOVE SNAKES %%%%%%%%%%%%%%%%
%
% Removes snakes that are pinched (have regions where the snake is folded
% over on itself) or that are too small.  Also runs removeBlobs.m.
%
% Inputs:
%  N                 - the number of images
%  pinchThresh       - the maximum allowed distance, in pixels, for boundary points that are pinchBPThresh*pinchDownSample away from each other
%  pinchBPThresh     - the minimum number of boundary points that pinching is measured across, expressed as a multiplicative factor of pinchDownSample
%  pinchDownSample   - the factor by which the snake is down-sampled before looking for pinches
%  minRegionSize     - the minimum size of a blob (in square pixels)
%  minDuration       - the minimum duration of a blob (in frames)
%  maxRegionSize     - the maximum mean size of a blob (in square pixels)
%  minSolidity       - the minimum mean solidity of a blob
%  savePath          - the directory that data is saved in
%
% Saves:
%  blob              - .removed is set to 1 for snakes that are pinched, new snakes are initiated
%  frame2blob        - a cell array of size {1,number of frames}, each cell lists the IDs of the non-removed blobs in that frame
%  blobAutoRemove    - the same structures as blob and frame2blob, but this variable will not be overwritten by other programs

% This can't be easily parallelized because of cutBlob.

function removeSnakes(N, pinchThreshLower, pinchBPThreshLower, pinchThreshHigher, pinchBPThreshHigher, pinchDownSample, minRegionSize, maxRegionSize, minSolidity, minDuration, inDirectory, savePath)

% load saved variables
load([savePath 'blobSnake']); % tracked boundaries (loads blob and frame2blob)

% find the smallest free ID
freeID = length(blob)+1;

% iterate through the frames
for i=1:N
    
    display(['   image ' num2str(i)])
    
    % iterate through the blobs
    for r = 1:length(frame2blob{1,i})
        
        % get blob ID
        ID = frame2blob{1,i}(r);
        
        % check to see if the snake is pinched
        sampledSnake = blob{ID}.snakeDist{1,i-blob{ID}.startFrame+1}(:,1:pinchDownSample:end); % downsample the snake
        reject = 0; 
        for s=pinchBPThreshLower:length(sampledSnake)-pinchBPThreshLower+1 % iterate through the rotations of the down-sampled snake
            minDist = min(sqrt(sum(squeeze((sampledSnake - circshift(sampledSnake, [0 s])).^2),1))); % the minimum distance between boundary points in this rotation
            
            if minDist < pinchThreshLower || (s>pinchBPThreshHigher &&  s<(length(sampledSnake)-pinchBPThreshHigher+1) &&  minDist<pinchThreshHigher)
                reject = 1;
                break
            end
        end
        
        % check to see if the snake is too small
        if ~reject && blob{ID}.area(i-blob{ID}.startFrame+1) < minRegionSize
            reject = 1;
        end
         
        % if the snake has been rejected, remove the snake in this frame and initiate new blobs.
        if reject == 1;
            [blob, freeID] = cutBlob(blob, ID, freeID, i);
            display(['      rejected blob (ID: ' num2str(ID) ')'])
        end
    
    end
    
    % update frame2blob 
    frame2blob = cell(1, N);
    for b=1:length(blob)   
        if blob{b}.removed == 0
            for f = blob{b}.startFrame:blob{b}.endFrame 
                frame2blob{1,f} = [frame2blob{1,f}, b];
            end
        end
    end

end

%  More are getting rejected than are getting removed!!!! (in frame 4)
% The same ID is getting rejected multiple times, cutBlob?
%Need to update frame2blob!! after every cut

% run removeBlobs again to check for tracks that are too short, etc..., and to remake frame2blob
[blob, frame2blob] = shortenBlob(N, blob, minDuration, minRegionSize, maxRegionSize, minSolidity);

% save the variables
save([savePath 'blob'],'blob', 'frame2blob');
save([savePath 'blobAutoRemove'],'blob', 'frame2blob');

%%%%%%% Cut Blob %%%%%%%
function [blob, freeID] = cutBlob(blob, oldID, freeID, frameNum)

% initiate the first section of the cut track (if the cut doesn't occur at the beginning)
if frameNum > blob{oldID}.startFrame
    blob{freeID}.startFrame = blob{oldID}.startFrame;
    blob{freeID}.endFrame = frameNum-1;
    blob{freeID}.clump = blob{oldID}.clump;
    blob{freeID}.labels = blob{oldID}.labels(1:frameNum-1-blob{oldID}.startFrame+1);
    blob{freeID}.area = blob{oldID}.area(1:frameNum-1-blob{oldID}.startFrame+1);
    blob{freeID}.solidity = blob{oldID}.solidity(1:frameNum-1-blob{oldID}.startFrame+1);
    blob{freeID}.removed = blob{oldID}.removed;
    
    % initialize and update snakeDist
    blob{freeID}.snakeDist = cell(1,frameNum-1-blob{oldID}.startFrame+1);
    for f=1:(blob{freeID}.endFrame-blob{oldID}.startFrame+1)
        blob{freeID}.snakeDist{1,f} = blob{oldID}.snakeDist{1,f};
    end
     
    % update snakeNum
    blob{freeID}.snakeNum = blob{oldID}.snakeNum(1:frameNum-1-blob{oldID}.startFrame+1,:,:);
    freeID = freeID+1;
end

% initiate the second section of the cut track (if the cut doesn't occur at the end)
if frameNum < blob{oldID}.endFrame
    blob{freeID}.startFrame = frameNum+1;
    blob{freeID}.endFrame = blob{oldID}.endFrame;
    blob{freeID}.clump = blob{oldID}.clump;
    blob{freeID}.labels = blob{oldID}.labels(frameNum+1-blob{oldID}.startFrame+1:end);
    blob{freeID}.area = blob{oldID}.area(frameNum+1-blob{oldID}.startFrame+1:end);
    blob{freeID}.solidity = blob{oldID}.solidity(frameNum+1-blob{oldID}.startFrame+1:end);
    blob{freeID}.removed = blob{oldID}.removed;
    
    % initialize and update snakeDist
    blob{freeID}.snakeDist = cell(1,length(blob{oldID}.snakeDist)-(blob{freeID}.startFrame-blob{oldID}.startFrame+1));
    for f=1:(length(blob{oldID}.snakeDist)-(blob{freeID}.startFrame-blob{oldID}.startFrame+1)+1)
        blob{freeID}.snakeDist{1,f} = blob{oldID}.snakeDist{1,f-1+blob{freeID}.startFrame-blob{oldID}.startFrame+1};
    end
    
    % update snakeNum
    blob{freeID}.snakeNum = blob{oldID}.snakeNum(frameNum+1-blob{oldID}.startFrame+1:end,:,:);
    freeID = freeID+1;
end

% remove the old, complete shape
blob{oldID}.removed=1;


% % load saved variables
% load([savePath 'blobSnake']); % tracked boundaries (loads blob and frame2blob)
% 
% % find the smallest free ID
% freeID = length(blob)+1;
%
% % iterate through the frames
% for i=1:N
%     
%     display(['   image ' num2str(i)])
%     
%     % iterate through the blobs
%     for r = 1:length(frame2blob{1,i})
%         
%         % get blob ID
%         ID = frame2blob{1,i}(r);
%         
%         % check to see if the snake is pinched
%         sampledSnake = blob(ID).snakeDist{1,i-blob(ID).startFrame+1}(1:pinchDownSample:end,:); % downsample the snake
%         reject = 0; 
%         for s=pinchBPThreshLower:length(sampledSnake)-pinchBPThreshLower+1 % iterate through the rotations of the down-sampled snake
%             minDist = min(sqrt(sum(squeeze((sampledSnake - circshift(sampledSnake, [0 s])).^2),1))); % the minimum distance between boundary points in this rotation
%             
%             if minDist < pinchThreshLower || (s>pinchBPThreshHigher &&  s<(length(sampledSnake)-pinchBPThreshHigher+1) &&  minDist<pinchThreshHigher)
%                 reject = 1;
%                 break
%             end
%         end
%         
%         % check to see if the snake is too small
%         if ~reject && blob(ID).area(i-blob(ID).startFrame+1) < minRegionSize
%             reject = 1;
%         end
%          
%         % if the snake has been rejected, remove the snake in this frame and initiate new blobs.
%         if reject == 1;
%             % blob(ID).removed = 1;
%             [blob, freeID] = cutBlob(blob, ID, freeID, i);
%             blob(ID).removed=1;
%             display(['      rejected blob (ID: ' num2str(ID) ')'])
%         end
%     
%     end
% 
% end
% 
% % run removeBlobs again to check for tracks that are too short, etc..., and to remake frame2blob
% [blob, frame2blob] = shortenBlob(N, blob, minDuration, maxRegionSize, minSolidity);
% 
% % save the variables
% save([savePath 'blob'],'blob', 'frame2blob');
% save([savePath 'blobAutoRemove'],'blob', 'frame2blob');