%%%%%%%%%%%%%%%% PLOT SHAPE PLOTS %%%%%%%%%%%%%%%%

% Plots plots for individual shapes.

% Inputs:
%  plotPlots    - sets the type of plots to make
%                       options: 'plotFour' - plot the local and global shape and motion measures
%                                'trackingArrow' - plots the tracking mapping
%                                'motionArrow' - plots the local motion mapping
%  shapeChoose  - sets the method for selecting tracks
%                       options: 'random' - plots randomally chosen tracks
%                                'longestDuration' - plots the longest duration tracks
%                                'largestDisplacement' - plots the largest displacement tracks
%  numToPlot    - the number of shapes for which space-time plots are plotted
%  N            - the number of images
%  M            - the number of boundary points
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  inDirectory  - the directory the images are saved in
%  savePath     - directory the outputed images are saved in

function plotShapePlots(plotPlots, shapeChoose, numToPlot, N, M, frameDelta, inDirectory, savePath)

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
    IDs = indexSorted(1:numToPlot);
    
elseif strcmp(shapeChoose, 'largestDisplacement') % if largest displacement IDs
    
    % iterate through the shapes to find the displacements
    displacements=zeros(1,length(shape));
    for s=1:length(shape)
        displacements(s)=shape(s).centroid(end)-shape(s).centroid(1);
    end
    % sort the durations to find the IDs of the longest duration tracks
    [displacementsSorted, indexSorted] = sort(displacements); 
    IDs = indexSorted(1:numToPlot);
    
end

% iterate through the shapes to make the plots
for s=1:length(IDs)
    
    % plot the local and global shape and motion measures
    if strcmp(plotPlots, 'plotFour')
        plotFour(IDs(s), shape);
        
    % plot the least squares tracking arrows
    elseif strcmp(plotPlots, 'trackingArrow')
        index = 1:1:M-1;
        init = ones(shape(IDs(s)).duration,1)*index;
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {init, shape(IDs(s)).leastSquares, 2, 1}, {1,1}, 0, 1, 0, 0, 'trackingArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    % plot the local motion arrows
    elseif strcmp(plotPlots, 'motionArrow')
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {shape(IDs(s)).closestBP, shape(IDs(s)).cutMotion, 2, frameDelta}, {1,frameDelta}, 0, 1, 0, 0, 'motionArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    end
end

%%%% PLOT FOUR %%%%
% plots shape, curvature, least squares tracking distance, and local motion for a single tracked shape
function plotFour(ID, shape)

figure;

% plot shape
subplot(2,2,1)
imagesc(shape(ID).distance'); colorbar;
title(['Shape (ID: ' num2str(ID) ')'])

% plot curvature
subplot(2,2,2)
imagesc(shape(ID).curvature'); colorbar;
title(['Curvature (ID: ' num2str(ID) ')'])

% plot least squares tracking distance
subplot(2,2,3)
imagesc(shape(ID).leastSquares'); colorbar; 
title(['Least Squares Motion (ID: ' num2str(ID) ')'])

% plot local motion
subplot(2,2,4)
imagesc(shape(ID).cutMotion'); colorbar;
title(['Local Motion (ID: ' num2str(ID) ')'])
