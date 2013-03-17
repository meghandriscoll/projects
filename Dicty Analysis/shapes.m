%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shapes.m analyzes the shape and motion of cells. Before running this 
% program, set names in SET DIRECTORIES below and set parameter values in 
% SET PARAMETERS. Sections of this program can be turned on and off prior 
% to running in TURN PROGRAMS ON AND OFF.
%
% Operating modes:  This program may be run on its own to analyze a single 
%                   movie or may be called by accumulateShapes.m to analyze
%                   multiple movies. Run on its own, the input variable 
%                   'parameters' is usually left empty. (To run the program
%                   simply type "shapes" on the command line.) However, if 
%                   not left empty, any variable assigned to a field of the
%                   structure parameters, for instance
%                   parameters.frameTime, will overwrite the corresponding 
%                   variable defined below.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function shapes(parameters)

%%%%%%% SET DIRECTORIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assumes that all numbered images are in the image sequence to be analysed, 
% and that an unnumbered image, if present, shows the ROI for later processing.

inDirectory = '/Users/meghandriscoll/Desktop/DictyTest/';     % directory the images are stored in 
savePath = '/Users/meghandriscoll/Desktop/DictyTestOutLong/';       % directory the created variable will be stored in

% inDirectory = '/Users/meghandriscoll/Desktop/CanTest/';     % directory the images are stored in 
% savePath = '/Users/meghandriscoll/Desktop/CanTestOut/';       % directory the created variable will be stored in


%%%%%%% SET PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% movie parameters
frameTime = 4;              % the number of seconds between frames
pixelsmm = 1365.33;         % the number of pixels per millimeter

% directed surfaces parameters
useROI = 0;                 % determines if an ROI will be used (0 if not used or 1 if used)
lineAngle = mean([88.649, 88.655, 88.649 , 88.760 , 88.652 , 88.319]);  % the angle of surface directionality (if applicable)
       
% find approximate boundaries parameters
minRegionSize = 40;         % the minimum size of a blob (in square pixels)
noiseLevelAdd = 0.01;       % the maximum value of the uniform noise that is added to the image
adjustGammaPre = 0.6;       % the adjusted gamma of the image prior to brightness-contrast adjustment
adjustGammaPost = 0.4;      % the adjusted gamma of the image after brightness-contrast adjustment (deals with varying blob brightness)
erodeImage = 2;             % number of pixels the binary image is eroded prior to labeling
dilateImage = 2;            % number of pixels the binary image is next dilated prior to labeling (smooths the outline)
dilateLargeCH = 3;          % number of pixels the binary image is dilated prior to finding the large convex hull

% track approximate boundaries parameters
centerTravelThresh = 11;    % the maximum number of pixels that a centroid is allowed to travel between two frames
areaChangeThresh = 0.7;     % the maximum percentage area change that a blob is allowed between two frames
maxRegionSize = 1600;       % the maximum mean size of a blob (in square pixels) (2*sqrt(maxRegionSize/pi)/pixelsmm is the maximum diameter in microns)
minSolidity = 0.5;          % the minimum mean solidity of a blob
minDuration = 20;           % the minimum duration of a blob (in frames)

% find snaked boundaries parameters 
% (numIterFirst, numIterEvery, convergeThresh, and runLimit greatly affect the code speed)
paramsSnake.mu=0.1;
paramsSnake.alpha=0.00002;              % alpha and beta are the snake tension and rigidity
paramsSnake.beta=0.00005;
paramsSnake.gamma=1;                    % you probably don't want to change gamma and kappa
paramsSnake.kappa=0.6;			
paramsSnake.dmin=0.5;                   % the minimum number of pixels seperating boundary points after interpolation
paramsSnake.dmax=1.5;                   % the maximum number of pixels seperating boundary points after interpolation
paramsSnake.NoGVFIterations = 80;       % the number of iterations used to calculate the gradient vector field of the image
paramsSnake.EquidistantNum = 200;       % the number of boundary points per blob outputted by the 'posNum' variable (usually 400) (must be a multiple of 4 for measureMotion)
paramsSnake.widthImageB = 6;            % the width, in pixels, of the border added to each frame (must be larger than widthCellB)
paramsSnake.widthCellB = 5;             % the effective width, in pixels, of the border added to each blob's image

paramsSnake.binLowerThresh = 0.7;       % the lower threshold when nearly binarizing the image (multiplied by the automatically calculated binarization threshold)
paramsSnake.binUpperThresh = 1.1;       % the upper threshold when nearly binarizing the image (multiplied by the automatically calculated binarization threshold)
paramsSnake.blobGamma = 0.4;            % the adjusted gamma of the nearly binarized image
paramsSnake.numIterFirst = 40;          % the number of initial snake iterations
paramsSnake.numIterEvery = 25;          % the number of subsequent snake iterations performed in every loop before checking convergence
paramsSnake.convergeThresh = 4;         % the maximum area change, in pixels, per loop that is considered converged
paramsSnake.runLimit = 30;              % the maximum number of iteration loops run

% remove snakes automatically parameters
pinchThreshLower = 0.5;     % the maximum allowed distance, in pixels, for boundary points that are pinchBPThreshLower*pinchDownSample away from each other
pinchBPThreshLower = 5;     % the minimum number of boundary points that pinching is measured across, expressed as a multiplicative factor of pinchDownSample
pinchThreshHigher = 1.5;    % the maximum allowed distance, in pixels, for boundary points that are pinchBPThreshHigher*pinchDownSample away from each other
pinchBPThreshHigher = 15;   % the minimum number of boundary points that pinching is measured across, expressed as a multiplicative factor of pinchDownSample
pinchDownSample = 1;        % the factor by which the snake is down-sampled before looking for pinches 2

% remove snakes manually parameters (boundary points every dmin)
remove = 'begin';           % options: 'begin', 'continue', 'continueAt' manually removing snakes 
startAt = [];               % options: null (for begin or continue) or a frame (for continueAt), the frame is specified in i space, meaning the fist frame's index is 1.
endAt = [];                 % the maximum frame to check (will only actually be checked if it, plus one, is a multiple of checkEveryNth)
checkEveryNth = 2;          % only select snakes in frames checkEveryNth apart (measured in frames)
removeRange = 11;           % frame range over which selected snakes are removed (centered at the clicked on frame and so must be an odd integer)
saveEvery = 5;              % saves every saveEvery time that a frame is checked (so, overall, every checkEveryNth*saveEvery frame)

% measure shape parameters
boundaryPoint = 10;         % number of boundary points curvature is found over 
curvatureThresh = 0.32;     % the maximum allowed value of the curvature measure

% measure motion parameters 
frameDelta = 3;             % the number of frames over which motion is measured
motionThresh = 4;           % the maximum allowed value of the local motion measure
smoothMotion = 38;          % the number of boundary points over which motion is first smoothed %12
smoothMotionAgain = 19;     % the number of boundary points over which motion is next smoothed
smoothCentroid = 5;         % the number of frames the centroid position is smoothed over prior to calculating the velocity     
frameVelocity = 3;          % the number of frames the centroid velocity is calculated over when finding velocity

%%%%%%% TURN PROGRAMS ON AND OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To run a section of code, set that element to 1

% extract and analyze shapes
run(1) = 1;     % read directories
run(2) = 1;     % find the approximate boundaries
run(3) = 1;     % track blobs
run(4) = 1;     % find the snaked boundaries
run(5) = 0;     % remove bad snakes automatically
run(6) = 0;     % remove bad snakes manually
run(7) = 0;     % initialize shapes
run(8) = 0;     % measure shape
run(9) = 0;     % measure motion
run(10) = 0;    % measure directed surfaces statistics
run(11) = 0;    % shape space statistics
run(12) = 0;    % misc.

% make image sequences
verify(1) = 0;    % plot the approximate boundaries
verify(2) = 0;    % plot the tracked approximate boundaries
verify(3) = 0;    % plot the snake boundaries
    snakeType = 'snakeManRemove';    % options: 'snakeTrack', 'snakeAutoRemove', 'snakeManRemove' (tracked, automatically culled, or manually culled snakes)
    backgroundSnake = 1;          % options: 0 (white backgroud), 1 (image background), 2 (accumulating image, no background)

verify(4) = 0;    % plot the shape measures on images
    plotMeasure = 'frontBack';    % options: 'shape', 'curvature', 'motion', 'centroid', 'frontBack', 'roi'
    backgroundMeasure = 1;        % options: 0 (white background), 1 (image background), 2 (accumulating image, no background)
    downSampleOutline = 4;        % only plot every downSampleOutline boundary point
    
% make plots
plots(1) = 0;    % plot plots for individual shapes
    plotPlots = 'plotSpaceTime';       % options: 'pathSpeed', 'plotSpaceTime' (space-time plots), 'trackingArrow', 'motionArrow'
    shapeChoose = 'longestDuration';       % options: 'random', 'longestDuration', 'largestDisplacement'
    numToPlot = 5;                % the number of shapes to make plots for
    
plots(2) = 0;    % plot overall plots
    plotOverall = 'clusterMeasures';       % options: 'clusterMeasures', 'motionAsEccentricity'
    
plots(3) =  0;    % plot directed surfaces plots
    plotLine = 'eccentricityVsLineAngle';       % options: 'measureCompare', 'motionAsLineAngle', 'areaAsLineAngle', 'eccentricityVsLineAngle', 'meanShape', 'spider';  

plots(4) =  0;    % plot pca plots
    plotPCA = 'curvature';       % options: 'curvature', 'shape', 'motion', 'boundaryPointPositions';  

    
% make text files
text(1) = 0;    % write the boundary points to text files
    textBP = 'constDist';
text(2) = 0;    % write measures to text files
    textMeasure = 'motion';    
    
%%%%%%% RUN PROGRAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display the run time of the program
tic 

%%%%%%%%%% ASSIGN PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Assigning Parameters');
assign_parameters;
mkdir(savePath);
save([savePath 'save_parameters'],'inDirectory', 'savePath', 'frameTime', 'pixelsmm', 'useROI', 'lineAngle', 'minRegionSize', 'adjustGammaPre',...
    'adjustGammaPost', 'erodeImage', 'dilateImage', 'dilateLargeCH', 'centerTravelThresh', 'areaChangeThresh', 'maxRegionSize', ...
    'minSolidity', 'minDuration', 'paramsSnake', 'pinchThreshLower', 'pinchBPThreshLower', 'pinchThreshHigher', 'pinchBPThreshHigher', 'pinchDownSample', 'remove', 'startAt', ...
    'endAt', 'checkEveryNth', 'removeRange', 'saveEvery', 'boundaryPoint', 'curvatureThresh', 'frameDelta', 'motionThresh', ...
    'smoothMotion', 'smoothMotionAgain', 'smoothCentroid', 'frameVelocity', 'downSampleOutline', 'backgroundSnake', ...
    'plotMeasure', 'backgroundMeasure', 'plotPlots', 'shapeChoose', 'numToPlot', 'plotOverall', 'plotLine');

%%%%%%%%%% READ DIRECTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(1) == 1
    display('Reading Directory');
    N = readDirectory(useROI, inDirectory, savePath);
    %N=20; % uncomment to only analyze the first x frames
else 
    load([savePath 'N']);
    %N=20; % uncomment to only analyze the first x frames
end
display(['  ' num2str(N) ' frames in total']);


%%%%%%%%%% FIND APPROXIMATE BOUNDARIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(2) == 1
    display('Finding Approximate Boundaries');
    findBoundaries(N, minRegionSize, noiseLevelAdd, adjustGammaPre, adjustGammaPost, erodeImage, dilateImage, dilateLargeCH, inDirectory, savePath);
end

%%%%%%%%%% TRACK THE SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(3) == 1
    display('Tracking the Blobs');
    trackBlobs(N, centerTravelThresh, areaChangeThresh, minRegionSize, maxRegionSize, minSolidity, minDuration, savePath);
end

%%%%%%%%%% SNAKE THE SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(4) == 1
    display('Snaking Boundaries');
    M = findSnakes(N, paramsSnake, inDirectory, savePath);
elseif max(run(5:end)) || max(verify(3:end)) || max(plots) % load M
    load([savePath 'M']);
end

%%%%%%%%%% AUTOMATICALLY REMOVE BAD SNAKES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(5) == 1
    display('Automatically Removing Bad Snakes');
    removeSnakes(N, pinchThreshLower, pinchBPThreshLower, pinchThreshHigher, pinchBPThreshHigher, pinchDownSample, minRegionSize, maxRegionSize, minSolidity, minDuration, inDirectory, savePath);
end

%%%%%%%%%% MANUALLY REMOVE BAD SNAKES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(6) == 1
    display('Manually Removing Snakes');
    selectSnakes(N, remove, startAt, endAt, checkEveryNth, removeRange, saveEvery, inDirectory, savePath);
end

%%%%%%%%%% INITIALIZE THE SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(7) == 1
    display('Initializing Shape');
    makeShape(N, useROI, minDuration, minRegionSize, maxRegionSize, minSolidity, savePath);
    initShape(M, savePath);
end

%%%%%%%%%% MEASURE SHAPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(8) == 1
    display('Measuring Shape');
    measureShape(M, boundaryPoint, curvatureThresh, savePath);
end

%%%%%%%%%% MEASURE MOTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(9) == 1
    display('Measuring Motion');
    measureMotion(N, M, frameDelta, motionThresh, smoothMotion, smoothMotionAgain, smoothCentroid, frameVelocity, savePath);
end

%%%%%%%%%% MEASURE DIRECTED SURFACE STATISTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(10) == 1
    display('Initializing ROI');
    initROI(N, useROI, savePath);
    display('Measuring Line Statistics');
    measureLines(N, M, lineAngle, frameVelocity, savePath);
end

%%%%%%%%%% MEASURE PCA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(11) == 1
    display('Measuring PCA')
    measurePCA(N, M, frameDelta, savePath)
end

%%%%%%%%%% MISC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if run(12) == 1
%     display('Measuring Mean Motion');
%     measureMotionMean(N, M, frameDelta, savePath)
    display('Compare PCA')
    comparePCA(frameDelta, savePath)
%     display('Entering Shape Space');
%     enterShapeSpace(N, M, frameDelta, savePath);
%     display('Measuring Shape in Shape Space');
%     measureShapeInShapeSpace(N, M, frameDelta, savePath);
end


%%%%%%% VERIFY: MAKE IMAGE SEQUENCES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PLOT THE APPROXIMATE BOUNDARIES ON THE ORIGINAL IMAGES %%%%%%%%%
if verify(1)
    display('Plotting Approximate Boundaries')
    plotApproxBoundaries(N, inDirectory, savePath)
end

%%%%%%%%%% PLOT THE TRACKED BOUNDARIES ON THE ORIGINAL IMAGES %%%%%%%%%%%%%
if verify(2)
    display('Plotting Tracked Approximate Boundaries')
    plotBlobs(N, inDirectory, savePath)
end

%%%%%%%%%% PLOT THE SNAKED BOUNDARIES ON THE ORIGINAL IMAGES %%%%%%%%%%%%%%
if verify(3)
    display('Plotting Snaked Boundaries')
    plotSnakes(snakeType, backgroundSnake, N, minDuration, minRegionSize, maxRegionSize, minSolidity, inDirectory, savePath);
end

%%%%%%%%%% PLOT MEASURES ON THE ORIGINAL IMAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%
if verify(4)
    display('Plotting Measures on Images')
    plotMeasuresOnImage(plotMeasure, backgroundMeasure, N, M, frameDelta, downSampleOutline, inDirectory, savePath);
end


%%%%%%% CONSTRUCT PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PLOTS CORRESPONDING TO INDIVIDUAL TRACKS %%%%%%%%%%%%%%%%%%%%%%%
if plots(1)
    display('Plotting plots for individual shapes')
    plotShapePlots(plotPlots, shapeChoose, numToPlot, N, M, frameTime, pixelsmm, frameDelta, inDirectory, savePath);
end

%%%%%%%%%% PLOTS OF OVERALL STATISTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plots(2)
    display('Plotting overall plots')
    plotOverallPlots(plotOverall, N, M, inDirectory, frameTime, pixelsmm, frameDelta, savePath);
end

%%%%%%%%%% OVERALL STATISTICS ON DIRECTED SURFACES %%%%%%%%%%%%%%%%%%%%%%%%
if plots(3)
    display('Plotting directed surfaces plots')
    plotLinePlots(plotLine, N, M, frameTime, pixelsmm, frameDelta, lineAngle, inDirectory, savePath);
end

%%%%%%%%%% PCA PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plots(4)
    display('Plotting PCA plots')
    plotPCAPlots(plotPCA, N, M, frameTime, pixelsmm, frameDelta, inDirectory, savePath);
end

%%%%%%% MAKE TEXT FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% MAKE BOUNDARY POINT TEXT FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if text(1)
    display('Making Boundary Point Text Files')
    makeTextBP(textBP, savePath);
end

%%%%%%%%%% MAKE MEASURE TEXT FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if text(2)
    display('Making Measure Text Files')
    makeTextMeasure(textMeasure, savePath);
end

% close images
%close all

% display the run time of the program
toc