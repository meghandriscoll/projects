%%%%%%%%%%%%%%%% ACCUMULATE MOTION DM %%%%%%%%%%%%%%%%

% append relevant motion measures to the motionA measure 

% Inputs:
%  motionA      - accumulated motion data
%  parameters   - this movie's parameters
%  accumParems  - parameters for accumulation of data across movies
%  shape        - this movie's data

function motionA = accumulateMotionDM(motionA, shape, accumParams, M, pixelsmm, frameTime, frameDelta)

% establish unit conversions
convertAreaPerTime=(1000/pixelsmm)^2*(60/(frameDelta*frameTime)); 

% initialize variables
if motionA.ran==0 && accumParams.numLoopsRan==0
    motionA.goodEccs = [];
    motionA.protrusionEccSum = zeros(accumParams.numBinsEcc,(M-1)/2); % protrusive and retractive motion binned by eccentricity
    motionA.retractionEccSum = zeros(accumParams.numBinsEcc,(M-1)/2); 
    motionA.eccCount = zeros(1,accumParams.numBinsEcc);
end

% find and append the eccentricities, and averaged protrusive and retractive motion (bins, boundary points, runs)
motionEcc = findMotionAsEccentricityDM(motionA, accumParams.numLoopsRan, accumParams.numBinsEcc, accumParams.motionAreaThresh, M, shape, frameDelta);
if accumParams.numLoopsRan==0
    motionA.goodEccs = [motionA.goodEccs, motionEcc.goodEccs];
elseif accumParams.numLoopsRan==1
    for b=1:accumParams.numBinsEcc
        motionA.protrusionEccSum(b,:) = motionA.protrusionEccSum(b,:) + convertAreaPerTime*motionEcc.protrusionFrontSum(b,:);
        motionA.retractionEccSum(b,:) = motionA.retractionEccSum(b,:) + convertAreaPerTime*motionEcc.retractionFrontSum(b,:);
        motionA.eccCount(b) = motionA.eccCount(b) + motionEcc.count(b);
    end
end