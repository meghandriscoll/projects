%%%%%%%%%%%%%%%% PLOT SHAPES %%%%%%%%%%%%%%%%

% Plots space-time plots.

% Inputs:
%  plotST       - sets the type of plots to make
%                       options: 'plotFour' - plot the local and global shape and motion measures
%                       options: 'trackingArrow' - plots the tracking mapping
%                       options: 'motionArrow' - plots the local motion mapping
%  shapeChoose  - sets the method for selecting tracks
%                       options: 'random' - randomally choses tracks to plot
%  numToPlot    - the number of shapes for which space-time plots are plotted
%  N            - the number of images
%  M            - the number of boundary points
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  inDirectory  - the directory the images are saved in
%  savePath     - directory the outputed images are saved in

function plotShapes(plotST, shapeChoose, numToPlot, N, M, frameDelta, inDirectory, savePath)

% load saved variables
load([savePath 'shape']); % tracked shapes (loads shape and frame2shape)
load([savePath 'boundaries']); % frmae information (loads picture)
load([savePath 'randShape']); % the indices for randomally chosen shapes (loads randShape)

% determine ID's for plotting
if strcmp(shapeChoose, 'random') % if randomally chosen ID's
    IDs = randPermShape(1:numToPlot);
end

% iterate through the shapes
for s=1:length(IDs)
    
    % plot the local and global shape and motion measures
    if strcmp(plotST, 'plotFour')
        plotFour(IDs(s), shape);
        
    % plot the least squares tracking arrows
    elseif strcmp(plotST, 'trackingArrow')
        index = 1:1:M-1;
        init = ones(shape(IDs(s)).duration,1)*index;
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {init, shape(IDs(s)).leastSquares, 2, 1}, {1,1}, 0, 1, 0, 0, 'trackingArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    % plot the local motion arrows
    elseif strcmp(plotST, 'motionArrow')
        plotMeasuresOnShape(shape(IDs(s)).duration, M, 1, {shape(IDs(s)).closestBP, shape(IDs(s)).cutMotion, 2, frameDelta}, {1,frameDelta}, 0, 1, 0, 0, 'motionArrow', shape, IDs(s), picture, inDirectory, savePath);
    
    end
end

%%%% PLOT FOUR %%%%
% plots shape, curvature, least squares tracking distance, and local motion for a single tracked shape
function plotFour(ID, shape)

figure

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

