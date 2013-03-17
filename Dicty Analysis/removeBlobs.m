%%%%%%%%%%%%%%%% REMOVE BLOBS %%%%%%%%%%%%%%%%
%
%  Removes blobs that are likely clumps, whose mean solidity is too low,
%  whose mean area is too high, or who exist for too few frames.  Adds the
%  good IDs to frame2blob.
%
% Inputs:
%  N                - the number of frames.
%  blob             - contains approximate bounadary info
%  minDuration      - the minimum duration of a blob (in frames)
%  maxRegionSize    - the maximum mean size of a blob (in square pixels)
%  minSolidity      - the minimum mean solidity of a blob
%
% Saves:
%  blob             - contains approximate bounadary info
%   .removed        - set to 1 if the blob has been removed
%  frame2blob       - a cell array of size {1,number of frames}, each cell lists the IDs of the non-removed blobs in that frame

function [blob, frame2blob] = removeBlobs(N, blob, minDuration, maxRegionSize, minSolidity)

% initialize variables
frame2blob = cell(1, N); 

% iterate through the blobs to remove blobs that are unlikely cells
for b=1:length(blob)
    
    % remove clumps
    if blob(b).clump == 1
        blob(b).removed = 1;
        
    % remove blobs whose duration is too short
    elseif (blob(b).endFrame - blob(b).startFrame + 1) < minDuration 
        blob(b).removed = 1;
    
    % remove blobs whose mean area is too large
    elseif mean(blob(b).area) > maxRegionSize 
        blob(b).removed = 1;
     
    % remove blobs whose mean solidity is too low
    elseif mean(blob(b).solidity) < minSolidity
        blob(b).removed = 1; 
    end
    
    % if the blob has not been removed, add its frames to frame2blob    
    if blob(b).removed == 0
        for f = blob(b).startFrame:blob(b).endFrame
            frame2blob{1,f} = [frame2blob{1,f}, b];
        end
    end
end
