%%%%%%%%%%%%%%%% MAKE SHAPE %%%%%%%%%%%%%%%%
%
% Converts the blob(ID) structure into the shape(ID) structure.
%
% Inputs:
%  N                 - the number of images
%  useROI            - 1 if an ROI is being used, 0 otherwise
%  minDuration       - the minimum duration of a blob (in frames)
%  maxRegionSize     - the maximum mean size of a blob (in square pixels)
%  minSolidity       - the minimum mean solidity of a blob
%  savePath          - directrory that data is stored in
%
% Saves:
%  shape(ID)         - stores information about the tracked shapes
%  frame2shape       - a cell array of size {1,number of frames}, each cell lists the IDs of the shapes in that frame

function makeShape(N, useROI, minDuration, minRegionSize, maxRegionSize, minSolidity, savePath)

% load saved variables
load([savePath 'blob']); % tracked  boundaries (loads blob and frame2blob)

% run removeBlobs again to check for tracks that are too short, etc..., and to remake frame2blob
[blob, frame2blob] = shortenBlob(N, blob, minDuration, minRegionSize, maxRegionSize, minSolidity);

% initialize variables
shape=[];
frame2shape = cell(1, N); 
freeID = 1;

% iterate through the blobs to remove blobs that are unlikely cells
for b=1:length(blob)
    
    % check to see if the shape has been removed
    if blob{b}.removed == 0
        
        % initialize the shape
        shape(freeID).startFrame = blob{b}.startFrame;
        shape(freeID).endFrame = blob{b}.endFrame;
        shape(freeID).duration = blob{b}.endFrame - blob{b}.startFrame + 1;
        shape(freeID).regionLabels = blob{b}.labels;
        shape(freeID).snake = blob{b}.snakeNum;
        shape(freeID).snakeDist = blob{b}.snakeDist;
        shape(freeID).regions = [];  % can be used as an index for the shape in the frame
        
        % if an ROI is in use
        if useROI 
            shape(freeID).inROI = zeros(shape(freeID).duration,1);
            
            shape(freeID).startFrameInROI = [];
            shape(freeID).endFrameInROI = [];
            shape(freeID).durationInROI = [];
            
            shape(freeID).startFrameOutROI = [];
            shape(freeID).endFrameOutROI = [];
            shape(freeID).durationOutROI = [];
        end
    
        % include the shape's frames in frame2shape   
        for f = shape(freeID).startFrame:shape(freeID).endFrame
            frame2shape{1,f} = [frame2shape{1,f}, freeID];
            shape(freeID).regions(f-shape(freeID).startFrame+1) = length(frame2shape{1,f});
        end
        
        freeID = freeID+1;
    end   
end

% construct an index for a random permutation of the shapes
randPermShape = randperm(length(shape));

% save the variables
save([savePath 'shape'],'shape', 'frame2shape');
save([savePath 'randShape'],'randPermShape');