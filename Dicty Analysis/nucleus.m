%%%%%%%%%%%%%%%% NUCLEUS %%%%%%%%%%%%%%%%

% Analyses the shape of blobs. Set the directories, parameters and programs. 
tic

%%%%%%% SET DIRECTORIES %%%%%%%
% Assumes that all numbered images are in the image sequence to be analysed, 
% and that an unnumbered image, if present, shows the ROI for later processing.

inDirectory = '/Users/meghandriscoll/Desktop/DictyTest/';      % directory the images are stored in 
savePath = '/Users/meghandriscoll/Desktop/DictyTestOutLong/';  % directory the created variable will be stored in
 
%inDirectory = '/Users/meghandriscoll/Desktop/DictyTest3/';     % directory the images are stored in 
%savePath = '/Users/meghandriscoll/Desktop/DictyTestOutEight/'; % directory the created variable will be stored in

%%%%%%% SET PARAMETERS %%%%%%%
       
% findBoundaries parameters
minRegionSize = 80;         % the minimum size of a blob (in square pixels)
adjustGamma = 0.4;          % the adjusted gamma of the image prior to binarization (deals with varying blob brightness)
erodeImage = 3;             % number of pixels the binary image is eroded prior to labeling
dilateImage = 4;            % number of pixels the binary image is next dilated prior to labeling (smooths the outline)
dilateLargeCH = 4;          % number of pixels the binary image is dilated prior to finding the large convex hull

% trackBlobs parameters
centerTravelThresh = 8;     % the maximum number of pixels that a centroid is allowed to travel between two frames
areaChangeThresh = 0.4;     % the maximum percentage area change that a blob is allowed between two frames

% removeBlobs parameters
maxRegionSize = 500;        % the maximum mean size of a blob (in square pixels)
minSolidity = 0.82;         % the minimum mean solidity of a blob
minDuration = 10;            % the minimum duration of a blob (in frames)

% findSnake parameters      % There are many parameters at the top of findSnake.m.

% removeSnakes parameters
pinchThresh = 1;          % the maximum allowed distance, in pixels, for boundary points that are pinchBPThresh*pinchDownSample away from each other,1.2
pinchBPThresh = 6;          % the minimum number of boundary points that pinching is measured across, expressed as a multiplicative factor of pinchDownSample
pinchDownSample = 5;        % the factor by which the snake is down-sampled before looking for pinches

% selectSnakes parameters 
checkFrame = 5;             % only select snakes in frames checkFrame apart (measured in frames)

% measureShape parameters 
boundaryPoint = 10;         % number of boundary points curvature is found over  

%%%%%%% TURN PROGRAMS ON AND OFF %%%%%%%

run(1) = 2;     % find the approximate boundaries
run(2) = 2;     % track blobs
run(3) = 2;     % find the snaked boundaries
run(4) = 2;     % remove bad snakes automatically
run(5) = 2;     % remove bad snakes manually
run(6) = 1;     % initialize shapes
% run(6) = 0;     % measure shape
% run(7) = 0;     % measure intensity

verify(1) = 0;    % plot the approximate boundaries
verify(2) = 0;    % plot the tracked approximate boundaries
verify(3) = 0;    % plot the snake boundaries
verify(4) = 0;    % plot the automatically culled snake boundaries
verify(5) = 0;    % plot the manually culled snake boundaries
     
% plot(5) = 0;    % plot shape measures on images
%     plotMeasure = 'curvature';     % options: 'shape', 'curvature', 'intensity', 'intensityA'
%     
% plot(6) = 0;    % plot space-time plots
% plot(7) = 0;    % plot distributions

%%%%%%% RUN PROGRAMS %%%%%%%

% find the approximate blobs
if run(1) == 1
    display('Reading Directory');
    [N, parems, picture] = readDirectory(inDirectory);
    N=100;
    display('Finding Approximate Boundaries');
    picture = findBoundaries(N, picture, minRegionSize, adjustGamma, erodeImage, dilateImage, dilateLargeCH, inDirectory, savePath);
    %mkdir(savePath);
    save([savePath 'boundaries'],'N', 'parems', 'picture');
elseif run(1) == 2
    display('Loading Approximate Boundaries');
    load([savePath 'boundaries']); 
end

% track the blobs and remove blobs that aren't likely cells
if run(2) == 1
    display('Tracking the Blobs');
    blob = trackBlobs(N, picture, centerTravelThresh, areaChangeThresh, savePath);
    display('Removing Blobs');
    [blob, frame2blob] = removeBlobs(N, blob, minDuration, maxRegionSize, minSolidity);
    save([savePath 'blob'],'blob', 'frame2blob');
elseif run(2) == 2
    display('Loading Tracked Blobs');
    load([savePath 'blob']); 
end

% find the snake boundaries
if run(3) == 1
    display('Snaking Boundaries');
    blobSnake = findSnake(N, blob, frame2blob, picture, inDirectory);
    save([savePath 'snakes'],'blobSnake');
elseif run(3) == 2
    display('Loading Snaked Boundaries');
    load([savePath 'snakes']); 
end

% remove bad snakes automatically
if run(4) == 1
    display('Automatically Removing Bad Snakes');
    [blobRemove, frame2blobRemove] = removeSnakes(N, blobSnake, frame2blob, pinchThresh, pinchBPThresh, pinchDownSample, minRegionSize, minDuration, maxRegionSize, minSolidity);
    save([savePath 'removed'],'blobRemove', 'frame2blobRemove');
elseif run(4) == 2
    display('Loading Removed Snakes');
    load([savePath 'removed']); 
end

% remove bad snakes manually
if run(5) == 1
    display('Manually Removing Snakes');
    [blobMan, frame2blobMan] = selectSnakes(N, blobRemove, frame2blobRemove, checkFrame, picture, inDirectory, savePath);
    save([savePath 'removedMan'],'blobMan', 'frame2blobMan');
elseif run(5) == 2
    display('Loading Manually Removed Snakes');
    load([savePath 'removedMan']); 
end

% initializing shape
if run(6) == 1
    display('Initializing Shape');
    [shape, frame2shape] = makeShape(N, blobMan);
    save([savePath 'initShape'],'shape', 'frame2shape');
elseif run(6) == 2
    display('Loading Shape Initialization');
    load([savePath 'initShape']); 
end

% % measure shape
% if run(5) == 1
%     display('Measure Shape');
%     [shape, snakeTShift] = measureShape(N, picture, snakeT, boundaryPoint, inDirectory);
%     save([savePath 'measureShape'],'shape', 'snakeTShift');
% elseif run(5) == 2
%     display('Loading Shape Measurements');
%     load([savePath 'measureShape']); 
% end
% 
% % measure intensity
% if run(6) == 1
%     display('Measure Intensity');
%     [intensity] = measureIntensity(N, picture, shape, snakeTShift, inDirectory);
%     save([savePath 'measureIntensity'],'intensity');
% elseif run(6) == 2
%     display('Loading Intensity Measurements');
%     load([savePath 'measureIntensity']); 
% end

%%%%%%% VERIFY: MAKE IMAGE SEQUENCES %%%%%%%

% plot the approximate boundaries on the original images
if verify(1)
    display('Plotting Approximate Boundaries')
    plotApproxBoundaries(N, picture, inDirectory, savePath)
end

% plot the tracked approximate boundaries
if verify(2)
    display('Plotting Tracked Approximate Boundaries')
    plotBlobs(N, blob, frame2blob, picture, inDirectory, savePath)
end

% plot the snaked boundaries on the original images
if verify(3)
    display('Plotting Snaked Boundaries')
    plotSnakes(N, blobSnake, frame2blob, picture, inDirectory, savePath);
end

% plot the good snaked boundaries on the original images
if verify(4)
    display('Plotting Automatically Culled Snaked Boundaries')
    plotSnakes(N, blobRemove, frame2blobRemove, picture, inDirectory, savePath);
end
 
% plot the culled snaked boundaries on the original images
if verify(5)
    display('Plotting Manually Culled Snaked Boundaries')
    plotSnakes(N, blobMan, frame2blobMan, picture, inDirectory, savePath);
end
% 
% % plot shape measures on images
% if plot(5)
%     display('Plotting Shape Measures on Images')
%     plotMeasuresOnImage(plotMeasure, N, picture, snakeTShift, shape, intensity, inDirectory, savePath);
% end
% 
% % plot space-time plots
% if plot(6)
%     display('Plotting Space-time Plots')
%     plotSpaceTime(N, picture, shape, boundaryPoint, patients, drugs, savePath)
% end
% 
% % plot distributions
% if plot(7)
%     display('Plotting Distributions')
%     plotDistributions(N, picture, shape, intensity, patients, drugs, savePath, inDirectory)
% end

toc