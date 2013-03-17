%%%%%%%%%%%%%%%% COMPARE PCA %%%%%%%%%%%%%%%%
%
% Compare the principal components of ensmebles of cells.
%
% Inputs:
%  savePath           - the directory that data is saved in
%
% Saves:


function comparePCA(frameDelta, savePath)

% set parameters
numBins = 3;

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)
load([savePath 'pca']); % pca data (loads pca and more)

% initialize new variables
speeds = [];

% iterate through the shapes to bin the comparison measures for PCA
for s=1:length(shape) 
     
    % accumulate the speeds
    speeds = [speeds, shape(s).speed(1:end-frameDelta)];
    
end

% sort the speeds
speedsSorted = sort(speeds);
speedsSorted = speedsSorted(isfinite(speedsSorted));
%speedsBinned = ceil(speeds.*(numBins/max(speeds))+0.0000001);

% run PCA
for n = 1:numBins
    
    % do pca on the shape measure binned by speed
    lowerSpeed = speeds(floor((length(speeds)-1)*(n-1)/numBins+1))
    upperSpeed = speeds(floor((length(speeds)-1)*n/numBins+1))
    speedsInRank = (speeds > lowerSpeed) & (speeds < upperSpeed);
	pcaCompareShapes(n).toPCA = pcaShape.toPCA(speedsInRank' == 1, :);  % pcaShape.toPCA may have too many dimensions
    [pcaCompareShapes(n).pc, pcaCompareShapes(n).zscores, pcaCompareShapes(n).latent] = princomp(pcaCompareShapes(n).toPCA', 'econ');
    size(pcaCompareShapes(n).toPCA)
end

% plot the pca components
for n = 1:numBins
    figure
    imagesc(pcaCompareShapes(n).zscores(:,1:50))
    colorbar;
    xlabel('Principal Component Index')
    ylabel('Boundary Position (a.u.) (0-front; 100-back)')
    title(['Shape Principal Components of Bin ' num2str(n)])
end
