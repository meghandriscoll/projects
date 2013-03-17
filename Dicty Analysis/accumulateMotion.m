%%%%%%%%%%%%%%%% ACCUMULATE MOTION %%%%%%%%%%%%%%%%

% append relevant motion measures to the motionA measure 

% Inputs:
%  motionA      - accumulated motion data
%  parameters   - this movie's parameters
%  accumParems  - parameters for accumulation of data across movies
%  shape        - this movie's data

function motionA = accumulateMotion(motionA, shape, accumParams, M, pixelsmm, frameTime, frameDelta)

% establish unit conversions
convertAreaPerTime=(1000/pixelsmm)^2*(60/(frameDelta*frameTime)); 

% initialize variables
if motionA.ran==0
    
    motionA.protrusionEcc=[]; motionA.retractionEcc=[]; % protrusive and retractive motion binned by eccentricity
    
end

% find and append the averaged protrusive and retractive motion (bins, boundary points, runs)
motionEcc = findMotionAsEccentricity(accumParams.numBinsEcc, accumParams.motionAreaThresh, M, shape, frameDelta);
if motionA.ran == 0
    motionA.protrusionEcc = convertAreaPerTime*motionEcc.protrusionFront;
    motionA.retractionEcc = convertAreaPerTime*motionEcc.retractionFront;
else
    motionA.protrusionEcc(:,:,end+1) = convertAreaPerTime*motionEcc.protrusionFront;
    motionA.retractionEcc(:,:,end+1) = convertAreaPerTime*motionEcc.retractionFront;
end




motionA.ran=1;