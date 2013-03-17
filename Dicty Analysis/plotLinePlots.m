%%%%%%%%%%%%%%%% PLOT LINE PLOTS %%%%%%%%%%%%%%%%

% Makes directed surfaces related plots.

% Inputs:
%  plotLine     - sets the type of plots to make
%                       options: 'measureCompare' - compares mean measure values inside and outside the ROI
%                                'motionAsLineAngle' - bins the shapes by orientation with respect to the lines, then finds the mean aligned motions    
%                                'areaAsLineAngle' - bins the shapes by orientation with respect to the lines, then finds the protrusive and retractive areas 
%                                'eccentricityVsLineAngle'
%                                'meanShape' - plots the mean shape as a function of orientation with respect to the lines
%                                'spider' - plots spider plots as a function of orientation with respect to the lines
%  N            - the number of images
%  M            - the number of boundary points
%  frameTime    - the number of seconds between frames
%  pixelsmm     - the number of pixels per millimeter
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  savePath     - directory the outputed images are saved in

function plotLinePlots(plotLine, N, M, frameTime, pixelsmm, frameDelta, lineAngle, inDirectory, savePath)

% load saved variables
%load([savePath 'roi']); % (loads frame2inROI', 'frame2outROI')

% determine which plots to make
% compare the values of meaures inside and outside the ROI
if strcmp(plotLine, 'measureCompare')
    load([savePath 'meanOnLine']); % load mean statistics
    measureCompare(meanOnLine, frameTime, pixelsmm);

% determine how aligned motion changes as a function of angle with respect to the lines
elseif strcmp(plotLine, 'motionAsLineAngle');
    %load([savePath 'meanOnLine']); % load mean statistics
    numBins = 3;
    motionAreaThresh=0.2;
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    motionAsLineAngle(numBins, motionAreaThresh, M, shape, inDirectory, frameTime, pixelsmm, frameDelta, savePath); 
      
% bins the shapes by orientation with respect to the lines, then finds the protrusive and retractive areas     
elseif strcmp(plotLine, 'areaAsLineAngle');
    numBins = 3;
    numAreaBins = 100;
    motionAreaThresh=0.2; % old method of discarding large motionAreas
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    areaAsLineAngle(numBins, numAreaBins, motionAreaThresh, M, shape, frameTime, pixelsmm, frameDelta, savePath); 

% tries to remove the effects of eccentricity on motionAsLineAngle
elseif strcmp(plotLine, 'eccentricityVsLineAngle');
    numPerBin = 5;
    motionAreaThresh=0.2;
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    eccentricityVsLineAngle(numPerBin, motionAreaThresh, M, shape, frameTime, pixelsmm, frameDelta, savePath)
    
% plot the mean shape as a function of orientation with respect to the lines
elseif strcmp(plotLine, 'meanShape');
    numBins = 5;
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    meanShape(numBins, M, shape, frameDelta, pixelsmm, frameTime); 
    
% plot spider plots as a function of orientation with respect to the lines
elseif strcmp(plotLine, 'spider');
    numBins = 1;
    spiderDuration = 150; % the duration, in frames, of the tracks in the spider plots
    numTracks = 12; % the maximum number of tracks plotted in each spider plot
    eccCutoff = 0; % only start a track if the cell has at least this eccentricity 
    load([savePath 'shape']); % load tracked shapes (loads shape and frame2shape)
    spider(numBins, spiderDuration, numTracks, eccCutoff, shape, pixelsmm); 

end
