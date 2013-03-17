%%%%%%%%%%%%%%%% CLUSTER MEASURES %%%%%%%%%%%%%%%%

% Clusters the measures and plots a covariance plot

%%%% List of Measures %%%% 
%  1: area
%  2: perimeter
%  3: mean radius  
%  4: minimum distance from centroid
%  5: maximum distance from centroid          
%  6: minorAxisLength        
%  7: majorAxisLength 
%  8: eccentricity 
%  9: 1/circularity 
% 10: 1-solidity  
% 11: mean negative curvature  
% 12: number of indents   
% 13: mean motion
% 14: largest retraction (motion)
% 15: largest protrusion (motion)
% 16: size of protrusive region along the boundary
% 17: size of retractive region along the boundary
% 18: protrusive area
% 19: retractive area
% 20: mean magnitude of the least squares tracking mapping   

%%%%% 11: tortuousity     
%%%%%  7: mean curvature   
%%%%%  8: standard deviation of curvature 

function clusterMeasures(skip, shape, M, frameDelta)

% initialize variables
area = [];
perimeter = [];
meanRadius = [];
minRadius = [];
maxRadius = [];  
minorAxisLength  = []; 
majorAxisLength  = []; 
eccentricity  = []; 
circularity = [];
solidity = []; 
%meanCurvature = []; 
%stdCurvature = [];
meanNegCurvature = [];
numIndents = [];        
%tort = [];                   
%speed = [];
meanMotion = [];
minMotion = [];
maxMotion = [];
protrusiveBoundaryRegion = [];
retractiveBoundaryRegion = [];
protrusiveArea = [];
retractiveArea = [];
meanLeastSquares = [];

% iterate through the shapes, putting each measure in a variable
for s=1:length(shape)
    
    % display progress update
    if mod(s,100)==0
        disp(['    Shape ' num2str(s) ' out of ' num2str(length(shape))])
    end
    
    area = [area, shape(s).area(1,1:skip:end-frameDelta)];
    perimeter = [perimeter, shape(s).perimeter(1,1:skip:end-frameDelta)];
    meanRadius = [meanRadius, mean(shape(s).distance(1:skip:end-frameDelta,:)')]; 
    minRadius = [minRadius, min(shape(s).distance(1:skip:end-frameDelta,:)')];
    maxRadius = [maxRadius, max(shape(s).distance(1:skip:end-frameDelta,:)')]; 
    minorAxisLength = [minorAxisLength, shape(s).minorAxisLength(1,1:skip:end-frameDelta)]; 
    majorAxisLength = [majorAxisLength, shape(s).majorAxisLength(1,1:skip:end-frameDelta)]; 
    eccentricity = [eccentricity, shape(s).eccentricity(1,1:skip:end-frameDelta)];  
    circularity = [circularity, 1./shape(s).circularity(1,1:skip:end-frameDelta)];   
    solidity = [solidity, 1-shape(s).solidity(1,1:skip:end-frameDelta)]; 
    %meanCurvature = [meanCurvature, mean(shape(s).uncutCurvature(1:skip:end-frameDelta,:),2)']; 
    %stdCurvature = [stdCurvature, std(shape(s).uncutCurvature(1:skip:end-frameDelta,:),0,2)'];
    meanNegCurvature = [meanNegCurvature, shape(s).meanNegCurvature(1,1:skip:end-frameDelta)];
    numIndents = [numIndents, shape(s).numIndents(1,1:skip:end-frameDelta)];        
    %tort = [tort, shape(s).tort(1,1:skip:end-frameDelta)];                   
    meanMotion = [meanMotion, mean(shape(s).motion(1:skip:end,:)')];
    minMotion = [minMotion, -1*min(shape(s).motion(1:skip:end,:)')];
    maxMotion = [maxMotion, max(shape(s).motion(1:skip:end,:)')];
    protrusiveBoundaryRegion = [protrusiveBoundaryRegion, sum(shape(s).motion(1:skip:end,:)'>0)/(M-1)];
    retractiveBoundaryRegion = [retractiveBoundaryRegion, sum(shape(s).motion(1:skip:end,:)'<0)/(M-1)];
    protrusiveArea = [protrusiveArea, sum(shape(s).motionArea(1:skip:end,:)'.*(shape(s).motionArea(1:skip:end,:)'>0))];
    retractiveArea = [retractiveArea, -1*sum(shape(s).motionArea(1:skip:end,:)'.*(shape(s).motionArea(1:skip:end,:)'<0))];
    meanLeastSquares = [meanLeastSquares, mean(shape(s).leastSquares(1:skip:end-frameDelta+1,:),2)']; 
end

% put the measures into a single plot to send to the covariance function
toCovar = [area; perimeter; meanRadius; minRadius; maxRadius; minorAxisLength; majorAxisLength;   ...
    eccentricity; circularity; solidity; meanNegCurvature; numIndents; ...        
    meanMotion; minMotion; maxMotion; protrusiveBoundaryRegion; retractiveBoundaryRegion; ...
    protrusiveArea; retractiveArea; meanLeastSquares];

% cluster the measures
y = pdist(zscore(toCovar')', 'correlation');
Z = linkage(y);

% plot the dendrogram
figure; 
[H,T,perm] = dendrogram(Z,'orientation','left');
set(H,'LineWidth',2)
title('Dendrogram of the Measures')

% reorder the measures to the order in the dendrogram
toCovarSort=[];
for p=1:length(perm)
    toCovarSort=[toCovarSort, toCovar(perm(p),:)'];
end

% plot the covariance matrix
colormap(jet(256))
figure;
imagesc(cov(zscore(toCovarSort))); colorbar;
title('Covariance of the Measures')
axis xy
axis off
