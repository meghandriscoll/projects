%%%%%%%%%%%%%%%% TRACK BLOBS %%%%%%%%%%%%%%%%

%  Tracks the blobs using the binarized images. Creates the blob{ID} 
%  structure and detects splits and merges.
%
% Inputs:
%  N                    - the number of images
%  centerTravelThresh   - the maximum number of pixels that a centroid is allowed to travel between two frames
%  areaChangeThresh     - the maximum percentage area change that a blob is allowed between two frames
%  minDuration          - the minimum duration of a blob (in frames)
%  maxRegionSize        - the maximum mean size of a blob (in square pixels)
%  minSolidity          - the minimum mean solidity of a blob
%  savePath             - the location of saved data
%
% Outputs:
%  blob{ID}
%   .startFrame     - the first frame in which the blob is tracked
%   .endFrame       - the last frame in which the blob is tracked
%   .labels         - the blob labels, in order, in the frames in which the blob has appeared
%   .clump          - 1 if a known clump, 0 if not a known clump
%   .area           - the list of areas, in pixels, of the blob
%   .solidity       - the list of solidities of the blob
%   .removed        - the track has been removed


function trackBlobs(N, centerTravelThresh, areaChangeThresh, minRegionSize, maxRegionSize, minSolidity, minDuration, savePath)

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)

%%% Temp Variables
% lastID         - the IDs in the previous frame indexed by label
% currentID      - the IDs in the current frame indexed by label
% freeID         - the largest available ID
% lastLabeled    - the labeled bw image of the previous frame
% currentLabeled - the labeled bw image of the current frame

% process the first image
blob=[];
for r=1:length(picture{1}.CHSstats)
    blob = initBlob(blob, r, r, 1, picture);
end
lastID = 1:1:length(picture{1}.CHSstats); 
freeID = length(picture{1}.CHSstats)+1;
load([savePath 'labeledImages/image' picture{1}.number]); % load the first labeled bw image
lastLabeled = labeled;

% process the remaining frames
for i=2:N
    if mod(i, 100) == 0
        disp(['   image ' num2str(i)]);
    end
    
    % load the current labeled bw image and initialize variables
    load([savePath 'labeledImages/image' picture{i}.number]);
    currentLabeled = labeled;
    currentID = NaN(1,length(picture{i}.CHSstats));
    
    % find the blob overlaps from frame to frame
    overlapMask = lastLabeled & currentLabeled; % 1 where past and current blobs overlap, 0 otherwise
    lastOverlap = reshape(lastLabeled.*overlapMask, 1, []); % list of last labels in the overlapped regions
    currentOverlap = reshape(currentLabeled.*overlapMask,1,[]); % list of current labels in the overlapped regions
    overlapLabels = unique([lastOverlap; currentOverlap]', 'rows'); % list of connections from frame to frame, sorted by label in last

    % look through the overlaps in the forwards time direction to find 1-1 continues and 1-many splits
    p = 2;  % keeps track of the overlapLabels index under analysis
    [rowsOverlapLabels, colsOverlapLabels] = size(overlapLabels);
    while p <= rowsOverlapLabels
        if (p == length(overlapLabels)) || (overlapLabels(p,1) ~= overlapLabels(p+1,1)) % (might be the last track in overlapLabels)

            % check that the centroids and area are similiar (the area difference is expressed as a percentage of the earlier area)
            centerDif = sqrt(sum((picture{i}.CHSstats(overlapLabels(p,2)).Centroid - picture{i-1}.CHSstats(overlapLabels(p,1)).Centroid).^2));
            areaDif = (picture{i}.CHSstats(overlapLabels(p,2)).Area - picture{i-1}.CHSstats(overlapLabels(p,1)).Area)/picture{i-1}.CHSstats(overlapLabels(p,1)).Area;
            
            % continue track 
            if  (centerDif <= centerTravelThresh) && (abs(areaDif) < areaChangeThresh) 
                blob = updateBlob(blob, lastID(overlapLabels(p,1)), overlapLabels(p,2), i, picture);
                currentID(overlapLabels(p,2)) = lastID(overlapLabels(p,1));
                p = p+1;
            
            % establish a new track 
            else 
                blob = initBlob(blob, freeID, overlapLabels(p,2), i, picture);
                currentID(overlapLabels(p,2)) = freeID;
                freeID = freeID + 1;
                p=p+1;
            end
            
        % a clump has split into muliple blobs    
        elseif overlapLabels(p,1) == overlapLabels(p+1,1)
            
            % label the clump as a clump
            blob{lastID(overlapLabels(p,1))}.clump = 1;

            % iterate through the split off tracks, assigning new IDs
            clumpPointer = 0;
            while (p+clumpPointer <= length(overlapLabels)) && (overlapLabels(p,1) == overlapLabels(p+clumpPointer,1))
                blob = initBlob(blob, freeID, overlapLabels(p+clumpPointer,2), i, picture);
                currentID(overlapLabels(p+clumpPointer,2)) = freeID;
                freeID = freeID + 1;
                clumpPointer = clumpPointer + 1;
            end
            p = p + clumpPointer;
            
        end
        
    end
    
    % if there is no overlap with the last image, all current regions are new regions
    overlapLabelsBack = sortrows(overlapLabels,2); % sort by current region index
    [rowsOverlapLabelsBack, colsOverlapLabelsBack] = size(overlapLabelsBack);
    p = 2;  % keeps track of the overlapLabels index under analysis
    r = 1;  % keep track of the next expected region in order to know when to start a new track
    if rowsOverlapLabelsBack==1
        while r <= length(picture{i}.CHSstats)
            blob = initBlob(blob, freeID, r, i, picture); 
            currentID(r) = freeID; 
            freeID = freeID + 1;
            r=r+1;
        end
    end
    
    % look through the overlaps in the backwards time direction to find many-1 merges and new regions 
    while (p <= rowsOverlapLabelsBack)
        
        % look for new regions
        while overlapLabelsBack(p,2) > r 
            % a new track must be initiated
            blob = initBlob(blob, freeID, r, i, picture);
            currentID(r) = freeID;
            freeID = freeID + 1;
            r=r+1;
        end
        
        % look for merges, but find none
        if (p == length(overlapLabelsBack)) || (overlapLabelsBack(p,2) ~= overlapLabelsBack(p+1,2)) 
            p=p+1; 
            r=r+1;
        
        % multiple blobs have merged into a clump     
        elseif overlapLabelsBack(p,2) == overlapLabelsBack(p+1,2)  
            
            % assign the clump an ID and label it as a clump
            blob = initBlob(blob, freeID, overlapLabelsBack(p,2), i, picture);
            currentID(overlapLabelsBack(p,2)) = freeID;
            blob{freeID}.clump = 1;
            freeID = freeID + 1;
            r=r+1;
            
            % iterate through the clump
            clumpPointer = 1;
            while (p+clumpPointer <= length(overlapLabelsBack)) && (overlapLabelsBack(p,2) == overlapLabelsBack(p+clumpPointer,2))
                clumpPointer = clumpPointer + 1;
            end
            p = p + clumpPointer;
            
        end
        
        % even after looking though overlapLabelsBack, there are still uninitiated regions remaining 
        while (p >= length(overlapLabelsBack)) && (r <= length(picture{i}.CHSstats)) 
            blob = initBlob(blob, freeID, r, i, picture);
            currentID(r) = freeID; 
            freeID = freeID + 1;
            r=r+1;
        end
        
    end
    
    % set 'current' variables to be 'last' variables
    lastID = currentID; 
    lastLabeled = currentLabeled;
end

% remove blobs that do not meet requirements and generate frame2blob (could call removeBlobs or shortenBlob)
[blob, frame2blob] = shortenBlob(N, blob, minDuration, minRegionSize, maxRegionSize, minSolidity);

% save the variables
save([savePath 'blob'], 'blob', 'frame2blob');

%%%%%%% Initialize Blob %%%%%%%
function blob = initBlob(blob, ID, label, frameNum, picture)

blob{ID}.startFrame = frameNum;
blob{ID}.endFrame = frameNum;
blob{ID}.labels = label;
blob{ID}.clump = 0;
blob{ID}.area = picture{frameNum}.CHSstats(label).Area;
blob{ID}.solidity = picture{frameNum}.CHSstats(label).Solidity;
blob{ID}.removed = 0;

%%%%%%% Update Blob %%%%%%%
function blob = updateBlob(blob, ID, label, frameNum, picture)

blob{ID}.endFrame = frameNum;
blob{ID}.labels = [blob{ID}.labels, label];
blob{ID}.area = [blob{ID}.area, picture{frameNum}.CHSstats(label).Area];
blob{ID}.solidity = [blob{ID}.solidity, picture{frameNum}.CHSstats(label).Solidity];