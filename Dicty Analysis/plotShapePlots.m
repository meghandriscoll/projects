%%%%%%%%%%%%%%%% PLOT SHAPE PLOTS %%%%%%%%%%%%%%%%

% Plots plots for individual shapes.

% Inputs:
%  plotPlots    - sets the type of plots to make
%                       options: 'pathSpeed' - plots the shape's path and speed
%                                'plotSpaceTime' - plot the local and global shape and motion measures
%                                'trackingArrow' - plots the tracking mapping
%                                'motionArrow' - plots the local motion mapping
%  shapeChoose  - sets the method for selecting tracks
%                       options: 'random' - plots randomally chosen tracks
%                                'longestDuration' - plots the longest duration tracks
%                                'largestDisplacement' - plots the largest displacement tracks
%  numToPlot    - the number of shapes for which space-time plots are plotted
%  N            - the number of images
%  M            - the number of boundary points
%  frameTime    - the number of seconds between frames
%  pixelsmm     - the number of pixels per millimeter
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  inDirectory  - the directory the images are saved in
%  savePath     - directory the outputed images are saved in

function plotShapePlots(plotPlots, shapeChoose, numToPlot, N, M, frameTime, pixelsmm, frameDelta, inDirectory, savePath)

% load saved variables
load([savePath 'shape']); % tracked shapes (loads shape and frame2shape)
load([savePath 'boundaries']); % frmae information (loads picture)
load([savePath 'randShape']); % the indices for randomally chosen shapes (loads randShape)

% determine ID's for plotting
if strcmp(shapeChoose, 'random') % if randomally chosen IDs
    IDs = randPermShape(1:numToPlot);
    
elseif strcmp(shapeChoose, 'longestDuration') % if longest duration IDs
    
    % iterate through the shapes to find the durations
    durations=zeros(1,length(shape));
    for s=1:length(shape)
        durations(s)=shape(s).duration;
    end
    % sort the durations to find the IDs of the longest duration tracks
    [durationsSorted, indexSorted] = sort(durations); 
    IDs = fliplr(indexSorted(end-numToPlot+1:end));
    
elseif strcmp(shapeChoose, 'largestDisplacement') % if largest displacement IDs
    
    % iterate through the shapes to find the displacements
    displacements=zeros(1,length(shape));
    for s=1:length(shape)
        displacements(s)=shape(s).centroid(end)-shape(s).centroid(1);
    end
    % sort the durations to find the IDs of the longest duration tracks
    [displacementsSorted, indexSorted] = sort(displacements); 
    IDs = fliplr(indexSorted(end-numToPlot+1:end));
    
end

% iterate through the shapes to make the plots
for s=1:length(IDs)
    
    % plot the path and speed
    if strcmp(plotPlots, 'pathSpeed')
        pathSpeed(IDs(s), shape, frameTime, pixelsmm);
    
    % plot the local and global shape and motion measures
    elseif strcmp(plotPlots, 'plotSpaceTime')
        plotSpaceTime(IDs(s), shape, frameTime, pixelsmm);
        
    % plot the least squares tracking arrows
    elseif strcmp(plotPlots, 'trackingArrow')
        index = 1:1:M-1;
        everyNthVector = 4;
        init = ones(shape(IDs(s)).duration,1)*index;
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {init, shape(IDs(s)).leastSquares, everyNthVector, 1}, {1,1}, 0, 1, 0, 0, 'trackingArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    % plot the local motion arrows
    elseif strcmp(plotPlots, 'motionArrow')
        everyNthVector = 4;
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {shape(IDs(s)).closestBP, shape(IDs(s)).motion, everyNthVector, frameDelta}, {1,frameDelta}, 0, 1, 0, 0, 'motionArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    end
end

%%%% PLOT PATH AND SPEED %%%%
% plots the path and speed of the shape
function pathSpeed(ID, shape, frameTime, pixelsmm)

% unit conversions
convertDistance = 1000/pixelsmm; 
convertTime = frameTime/60;
convertSpeed=convertDistance/convertTime; 

% plot path
figure;
subplot(1,2,1) 
plot(shape(ID).centroid(:,1)*convertDistance, shape(ID).centroid(:,2)*convertDistance, 'LineWidth', 2, 'Color', 'k');
xlabel('x (micrometers)')
ylabel('y (micrometers)')
title(['Path (ID: ' num2str(ID) ')'])
axis equal

% plot speed
subplot(1,2,2)
time=1:length(shape(ID).speed);
plot(time*convertTime, shape(ID).speed*convertSpeed, 'LineWidth', 2, 'Color', 'k');
xlabel('time (minutes)')
ylabel('speed (micrometers/minute)')
title(['Speed (ID: ' num2str(ID) ')'])


%%%% PLOT SPACE-TIME PLOTS %%%%
% plots shape, curvature, least squares tracking distance, and local motion for a single tracked shape
function plotSpaceTime(ID, shape, frameTime, pixelsmm)

% unit conversions
convertDistance = 1000/pixelsmm; 
convertTime = frameTime/60;
convertSpeed=convertDistance/convertTime; 
convertAreaPerTime=convertDistance^2/convertTime; 

% plot shape
figure;
subplot(3,2,1)
[rows,cols]=size(shape(ID).distance');
imagesc([0,convertTime*cols], [0,rows], convertDistance*shape(ID).distance'); colorbar;
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Shape (ID: ' num2str(ID) ')'])

% plot curvature
subplot(3,2,2)
[rows,cols]=size(shape(ID).curvature');
imagesc([0,convertTime*cols], [0,rows], shape(ID).curvature'); colorbar;
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Curvature (ID: ' num2str(ID) ')'])

% plot least squares tracking distance
subplot(3,2,3)
[rows,cols]=size(shape(ID).leastSquares');
imagesc([0,convertTime*cols], [0,rows], convertSpeed*shape(ID).leastSquares'); colorbar; 
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Least Squares Motion (ID: ' num2str(ID) ')'])

% plot local motion
subplot(3,2,4)
[rows,cols]=size(shape(ID).cutMotion');
imagesc([0,convertTime*cols], [0,rows], convertSpeed*shape(ID).cutMotion'); colorbar;
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Local Motion (ID: ' num2str(ID) ')'])

% plot motion (not cutoff)
subplot(3,2,5)
[rows,cols]=size(shape(ID).motion');
imagesc([0,convertTime*cols], [0,rows], convertSpeed*shape(ID).motion'); colorbar;
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Non-cutoff Motion (ID: ' num2str(ID) ')'])

% plot motion scaled by area
subplot(3,2,6)
[rows,cols]=size(shape(ID).motionArea');
imagesc([0,convertTime*cols], [0,rows], convertAreaPerTime*shape(ID).motionArea'); colorbar;
xlabel('time (minutes)')
ylabel('boundary position (a.u.)')
title(['Motion Area (ID: ' num2str(ID) ')'])
