%%%%%%%%%%%%%%%% PLOT PCA PLOTS %%%%%%%%%%%%%%%%

% Makes directed surfaces related plots.

% Inputs:
%  plotPCA     - sets the type of plots to make
%                       options: 'curvature' - 
%                                'shape' - 
%                                'motion' - 
%                                'boundaryPointPositions'
%  N            - the number of images
%  M            - the number of boundary points
%  frameTime    - the number of seconds between frames
%  pixelsmm     - the number of pixels per millimeter
%  frameDelta   - the number of frames over which the local motion measure is calculated 
%  savePath     - directory the outputed images are saved in

function plotPCAPlots(plotPCA, N, M, frameTime, pixelsmm, frameDelta, inDirectory, savePath)

% load saved variables
load([savePath 'pca']); % (loads 'pca' and others)

% determine which plots to make
if strcmp(plotPCA, 'curvature')
    plotPCACurvature(M, pca, pcaCurvature);
    
elseif strcmp(plotPCA, 'shape')
    plotPCAShape(M, pca, pcaShape);
    
elseif strcmp(plotPCA, 'motion')
    plotPCAMotion(M, pca, pcaMotion);
    
elseif strcmp(plotPCA, 'pcaLeastSquares')
    plotPCABPP(M, pca, pcaLeastSquares);

elseif strcmp(plotPCA, 'boundaryPointPositions')
    plotPCABPP(M, pca, pcaBPP);

elseif strcmp(plotPCA, 'spectra')
    plotSpectra(pcaShape, pcaCurvature, pcaMotion, pcaLeastSquares, pcaBPP);
    
end