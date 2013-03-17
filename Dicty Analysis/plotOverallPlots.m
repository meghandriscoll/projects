%%%%%%%%%%%%%%%% PLOT OVERALL PLOTS %%%%%%%%%%%%%%%%

% Makes plots related to all of the cells

% Inputs:
%  plotOverall  - sets the type of plots to make
%                       options: 'clusterMeasures' - clusters the measures and plots a covariance plot
%                                'motionAsEccentricity' - plots the aligned front motion binned by eccentricty rank
%  N            - the number of images
%  M            - the number of boundary points
%  frameTime    - the number of seconds between frames
%  pixelsmm     - the number of pixels per millimeter
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  savePath     - directory the outputed images are saved in

function plotOverallPlots(plotLine, N, M, inDirectory, frameTime, pixelsmm, frameDelta, savePath)

% determine which plots to make

% cluster measures and plot a covariance plot
if strcmp(plotLine, 'clusterMeasures')
    skip=1;
    load([savePath 'shape']); % load mean statistics
    clusterMeasures(skip, shape, M, frameDelta); 

% determine how aligned motion changes as a function of eccentricity rank
elseif strcmp(plotLine, 'motionAsEccentricity');
    numBins = 6;
    motionAreaThresh=0.2;
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    motionAsEccentricity(numBins, motionAreaThresh, M, shape, inDirectory, frameTime, pixelsmm, frameDelta, savePath); 

% determine how aligned motion changes as a function of eccentricity rank
elseif strcmp(plotLine, 'measureAutoCorrs');
    minDurationAutoCorr = 15*5;   % the minimum number of frames needed for tracks to be included in auto-correlations
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    measureAutoCorrs(shape, minDurationAutoCorr, frameDelta);   
    
end
