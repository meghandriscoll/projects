%%%%%%%%%%%%%%%% MAKE TEXT BOUNDARY POINT %%%%%%%%%%%%%%%%
%
%  Removes blobs that are likely clumps, whose mean solidity is too low,
%  whose mean area is too high, or who exist for too few frames.  Adds the
%  good IDs to frame2blob.
%
% Inputs:
%  textBP               - options:
%                           constDist - 

% Saves:

function makeTextBP(textBP, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% make an overall directory
mkdir([savePath 'TextBoundaryPointsConstDist'])

% iterate through the shapes
for s=1:length(shape)
    
    % display progress
    if mod(s, 100) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % make a directory for each shape
    shapePathName = [savePath 'TextBoundaryPointsConstDist/shape' num2str(s)];
    mkdir(shapePathName)
    
    % iterate through the frames that the shape is in
    for f=1:shape(s).duration
        frameNum = f+shape(s).startFrame-1;
        if strcmp(textBP, 'constDist')
            dlmwrite([shapePathName '/frame' num2str(frameNum) '.txt'], shape(s).snakeDist{1,f});
        end
    end
    
end