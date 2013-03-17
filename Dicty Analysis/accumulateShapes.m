%%%%%%%%%%%%%%%%%%%%%%%%%%%% ACCUMULATE SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function accumulateShapes()

%%%%%%% TURN INDIVIDUAL SHAPE PROGRAMS ON AND OFF %%%%%%%%%%%%%%%%%%%%%%%%%
% extract and analyze shapes
parameters.run(1) = 0;     % read directory
parameters.run(2) = 0;     % find the approximate boundaries
parameters.run(3) = 0;     % track blobs
parameters.run(4) = 0;     % find the snaked boundaries
parameters.run(5) = 0;     % remove bad snakes automatically
parameters.run(6) = 0;     % remove bad snakes manually
parameters.run(7) = 0;     % initialize shapes
parameters.run(8) = 0;     % measure shape
parameters.run(9) = 0;     % measure motion
parameters.run(10) = 0;    % measure directed surfaces statistics
parameters.run(11) = 0;    % do pca
parameters.run(12) = 0;    % misc

% make image sequences
parameters.verify(1) = 0;    % plot the approximate boundaries
parameters.verify(2) = 0;    % plot the tracked approximate boundaries
parameters.verify(3) = 0;    % plot the snake boundaries
    parameters.snakeType = 'snakeManRemove';    % options: 'snakeTrack', 'snakeAutoRemove', 'snakeManRemove' (tracked, automatically culled, or manually culled snakes)
    parameters.backgroundSnake = 2;          % options: 0 (white backgroud), 1 (image background), 2 (accumulating image, no background)

parameters.verify(4) = 0;    % plot the shape measures on images
    parameters.plotMeasure = 'roi';     % options: 'shape', 'curvature', 'motion', 'centroid', 'frontBack', 'roi'
    parameters.backgroundMeasure = 0;        % options: 0 (white background), 1 (image background), 2 (accumulating image, no background)

% make plots
parameters.plots(1) = 0;    % plot plots for individual shapes
    parameters.plotPlots = 'motionArrow';       % options: 'pathSpeed', 'plotSpaceTime' (space-time plots), 'trackingArrow', 'motionArrow'
    parameters.shapeChoose = 'longestDuration';       % options: 'random', 'longestDuration', 'largestDisplacement'
    parameters.numToPlot = 5;                % the number of shapes to make plots for
    
parameters.plots(2) = 0;    % plot overall plots
    parameters.plotOverall = 'measureAutoCorrs';       % options: 'clusterMeasures', 'motionAsEccentricity', 'measureAutoCorrs'
    
parameters.plots(3) =  0;    % plot directed surfaces plots
    parameters.plotLine = 'motionAsLineAngle';       % options: 'measureCompare', 'motionAsLineAngle', 'areaAsLineAngle', 'eccentricityVsLineAngle', 'meanShape', 'spider';
    
parameters.plots(4) =  1;    % plot pca plots
    parameters.plotPCA = 'spectra';       % options: 'curvature', 'shape', 'motion', 'boundaryPointPositions', spectra;  


%%%%%%% TURN ACCUMULATORS ON AND OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

accumParams.run(1) = 0;  % accumulate motionArea by averaging over movies
accumParams.run(2) = 0;  % accumulate motionArea by combining data from different movies
    accumParams.numBinsEcc = 4;
    accumParams.motionAreaThresh = 0.2;
accumParams.run(3) = 0;  % count the number of shapes, the number of tracks, the track lengths distributions

%%%%%%% ANALYZE MOVIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set main directory
mainPath = '/Users/meghandriscoll/Desktop/Ridges/';

% reset the accum variables
motionA.ran = 0;
accumParams.numLoopsRan = 0; % counts the number of loops the data is accumulated over
keepRunning = true; % runs and accumulates the data

% start log file
dateStr = date;
diary([mainPath 'log' dateStr '.txt'])
display('~~~~~~~~~~~~ ACCUMULATING SHAPES ~~~~~~~~~~~~')

figure

while keepRunning
    
%     %%%%%%%%%% ax3 glass (090818) %%%%%%%
%     directoryPath = '090818';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = 0;
%     parameters.lineSep = 0;
%     parameters.type='ax3_glass';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
% 
%     %%%%%% ax3 glass (090819) %%%%%%%
%     directoryPath = '090819';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = 0;
%     parameters.lineSep = 0;
%     parameters.type='ax3_glass';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%      
%     %%%%%%% ax3 glass (091111_2) %%%%%%%
%     directoryPath = '091111_2';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = 0;
%     parameters.lineSep = 0;
%     parameters.type='ax3_glass';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%% ax3 glass (091111_3) %%%%%%%
%     directoryPath = '091111_3';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = 0;
%     parameters.lineSep = 0;
%     parameters.type='ax3_glass';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
% 
%     %%%%% ax3 glass (100120_2) %%%%%%%
%     directoryPath = '100120_2';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = 0;
%     parameters.lineSep = 0;
%     parameters.type='ax3_glass';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
% 
%     % % %%%%%%% ax3 glass (100120_3) %%%%%%%
%     % % directoryPath = '100120_3';
%     % % parameters.inDirectory = [mainPath directoryPath '/'];
%     % % parameters.savePath = [mainPath directoryPath '/saveData/'];
%     % % parameters.lineAngle = 0;
%     % % parameters.lineSep = 0;
%     % % parameters.type='ax3_glass';
%     % % shapes(parameters)
%     % % motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%       
    %%%%% glass (110316) %%%%%%%
    directoryPath = '110316';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = 0;
    parameters.lineSep = 0;
    parameters.type='glass';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);
    
    %%%%% glass (120430) %%%%%%%
    directoryPath = '120430';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = 0;
    parameters.lineSep = 0;
    parameters.type='glass';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);
      
    %%%% square film (101025) %%%%%%%
    directoryPath = '101025';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = 0;
    parameters.lineSep = 0;
    parameters.type='squareFilm';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);
  
    %%%%% film (120508) %%%%%%%
    directoryPath = '120508';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = 0;
    parameters.lineSep = 0;
    parameters.type='film';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%      
%     %%%%%%% ridges, 0.4 (101020) %%%%%%%
%     directoryPath = '101020';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([90.143, 90.366, 90.287]);
%     parameters.lineSep = 0.4;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 0.4 (101024) %%%%%%%
%     directoryPath = '101024';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([92.268, 92.132, 91.857, 92.291, 91.843, 91.857, 91.882, 92.021]);
%     parameters.lineSep = 0.4;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%% ridges, 0.6 (110317) %%%%%%%
%     directoryPath = '110317';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([83.701, 84.177, 84.308, 84.041, 83.727, 84.270, 83.904]);
%     parameters.lineSep = 0.6;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 0.6 (110926) %%%%%%%
%     directoryPath = '110926';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([88.649, 88.655, 88.649 , 88.760 , 88.652 , 88.319]);
%     parameters.lineSep = 0.6;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%% ridges, 0.8 (110210) %%%%%%%
%     directoryPath = '110210';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([5.356, 5.849, 5.548, 5.605, 5.669]);
%     parameters.lineSep = 0.8;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 0.8 (110421) %%%%%%%
%     directoryPath = '110421';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([90.141, 90.141, 90.000, 89.829, 90.000]);
%     parameters.lineSep = 0.8;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 1.0 (120512) %%%%%%%
%     directoryPath = '120512_1';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-83.454, -83.621, -83.506, -83.724, -83.583, -83.596, -83.477]);
%     parameters.lineSep = 1.0;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%% the good one!!!
%     %%%%%%% ridges, 1.0 (120517) %%%%%%%
%     directoryPath = '120517_2';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-84.735, -84.634, -84.755, -84.490, -84.592, -84.592, -84.390]);
%     parameters.lineSep = 1.0;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%    
%     %%%%%%% ridges, 1.2 (120423) %%%%%%%
%     directoryPath = '120423';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-87.858, -87.871, -87.871, -87.875, -87.883, -87.871, -87.875]);
%     parameters.lineSep = 1.2;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%%% ridges, 1.2 (120512) %%%%%%%
%     directoryPath = '120512_2';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-83.709, -83.524, -83.487, -83.487, -83.362, -83.512, -83.598]);
%     parameters.lineSep = 1.2;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%% the second good one!!!
%     %%%%%% ridges, 1.2 (120517) %%%%%%%
%     directoryPath = '120517_3';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-84.967, -84.958, -84.856, -84.735, 84.948, -84.948]);
%     parameters.lineSep = 1.2;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%%% ridges, 1.5 (120424) %%%%%%%
%     directoryPath = '120424';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-89.775, -89.888, -90, -90, -90, -90, -90, -89.776]);
%     parameters.lineSep = 1.5;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 1.5 (120520) %%%%%%%
%     directoryPath = '120520_2';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-91.348, -91.460, -91.348, -91.367, -91.478, -91.250, -91.353]);
%     parameters.lineSep = 1.5;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%      
%     %%%%%%%% ridges, 2 (110318) %%%%%%%
%     directoryPath = '110318';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-84.167, -84.067, -84.055, -84.167, -84.190, -83.979, -84.090, -84.090, -84.090, -83.968]);
%     parameters.lineSep = 2;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 2 (110419) %%%%%%%
%     directoryPath = '110419';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([3.764, 3.715, 3.715, 3.599, 3.686, 3.731, 3.861, 4.036, 3.987]);
%     parameters.lineSep = 2;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 3 (120504) %%%%%%%
%     directoryPath = '120504';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([1.348, 1.457, 1.681, 1.460, 1.566, 1.460, 1.348]);
%     parameters.lineSep = 3;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 3 (120509) %%%%%%%
%     directoryPath = '120509';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-88.540, -88.431, -88.428, -88.424, -88.428]);
%     parameters.lineSep = 3;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 3 (120510) %%%%%%%
%     directoryPath = '120510';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-94.736, -94.848, -94.838, -94.980, -94.886, -94.857]);
%     parameters.lineSep = 3;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%    
%     %%%%%%% ridges, 5 (120517) %%%%%%%
%     directoryPath = '120517_1';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([1.248, 1.367, 1.369, 1.260, 1.250, 1.248, 1.356]);
%     parameters.lineSep = 5;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%   
%     %%%%%%% ridges, 5 (120520) %%%%%%%
%     directoryPath = '120520_1';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-89.660, -89.662, -89.770, -89.658, -89.660, -89.545]);
%     parameters.lineSep = 5;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% ridges, 10 (110630) %%%%%%%
%     directoryPath = '110630';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([92.91,93.14,93.49,92.91,93.37]);
%     parameters.lineSep = 10;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 10 (110721) %%%%%%%
%     directoryPath = '110721';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([90.23,90.23,90.46,90.26]);
%     parameters.lineSep = 10;
%     parameters.type='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% ridges, 10 (110805) %%%%%%%
%     directoryPath = '110805';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([93.555,93.562,93.669,93.677,93.555]);
%     parameters.lineSep = 10;
%     parameters.type ='ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%      
%     %%%%%%% thin ridges, 2 (110510) %%%%%%%
%     directoryPath = '110510';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-92.752, -92.735, -93.079, -92.735, -92.845, -92.827, -92.675, -92.667, -92.985]);
%     parameters.lineSep = 2;
%     parameters.type ='thin_ridges';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% grooves, 2 (110418) %%%%%%%
%     directoryPath = '110418';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([3.142, 2.924, 3.136, 3.149, 3.036, 3.136, 3.142, 3.161, 3.142, 3.036]);
%     parameters.lineSep = 2;
%     parameters.type='grooves';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% grooves, 2 (110508) %%%%%%%
%     directoryPath = '110508';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([91.134,91.132,91.139,91.132,91.134,91.245,91.126]);
%     parameters.lineSep = 2;
%     parameters.type='grooves';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% grooves, 10 (110701) %%%%%%%
%     directoryPath = '110701';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([95.27, 95.59, 95.15, 95.15, 95.17]);
%     parameters.lineSep = 10;
%     parameters.type='grooves';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%% thin grooves, 0.6 (110524) %%%%%%%
%     directoryPath = '110524';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-74.964, -74.915, -74.470, -74.783, -74.337, -74.175, -74.369, -74.391]);
%     parameters.lineSep = 0.6;
%     parameters.type='thin_grooves';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
%     %%%%%%% sawtooth (110415) %%%%%%%
%     directoryPath = '110415';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([-84.637, -84.587, -84.495, -84.505, -84.425, -84.615, -84.526, -84.626, -84.532, -84.472]);
%     parameters.lineSep = 0.8;
%     parameters.type='sawtooth';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
    
%     %%%%%%% sawtooth (110509) %%%%%%%
%     directoryPath = '110509';
%     parameters.inDirectory = [mainPath directoryPath '/'];
%     parameters.savePath = [mainPath directoryPath '/saveData/'];
%     parameters.lineAngle = mean([93.652, 93.890,93.961,93.852,94.020,93.875,93.914,93.921,93.867,94.168]);
%     parameters.lineSep = 0.8;
%     parameters.type='sawtooth';
%     shapes(parameters)
%     motionA = meldMeasures(accumParams, motionA, parameters.savePath);
%     
    %%%%% myoII null, glass (110601) %%%%%%%
    directoryPath = '110601';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = 0;
    parameters.lineSep = 0;
    parameters.type='myoII';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);
    
    %%%%%% myoII null, grooves, 0.8 (110907) %%%%%%%
    directoryPath = '110907';
    parameters.inDirectory = [mainPath directoryPath '/'];
    parameters.savePath = [mainPath directoryPath '/saveData/'];
    parameters.lineAngle = mean([95.767, 95.891, 95.868, 96.080, 95.926, 95.991, 96.068, 96.266, 96.355]);
    parameters.lineSep = 0.8;
    parameters.type='myoII_grooves';
    shapes(parameters)
    motionA = meldMeasures(accumParams, motionA, parameters.savePath);

    %%%%%%% ANALYZE AND PLOT ACCUMULATED DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot accumulated motionArea averaged across movies
    if accumParams.run(1) == 1
        plotAccumMotion(motionA, accumParams)
    end
    
    % plot accumulated motionArea accumulating multiple movies
    if accumParams.run(2) == 1 && accumParams.numLoopsRan == 0;
        motionA = findBinEdgesForMotion(motionA, accumParams);
    elseif accumParams.run(2) == 1 && accumParams.numLoopsRan == 1;
        plotAccumMotionDM(motionA, accumParams); %%% non-existant!
    end
    
    if accumParams.run(3)==1
       plotCountShapes(motionA)
    end
    
    %%%%%%% UPDATE VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % decide whether to go through the runs again
    if (accumParams.run(2) == 1) && (accumParams.numLoopsRan == 0)
        keepRunning = true;
    else
        keepRunning = false;
    end
    
    % update the number of loops run
    accumParams.numLoopsRan = accumParams.numLoopsRan+1;    
end    

diary off
    
%%%%%%% MELD MEASURES SUBFUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function motionA = meldMeasures(accumParams, motionA, savePath)

% load parameters
load([savePath 'save_parameters']);
load([savePath 'M']);

% display progress
disp(' ')
disp(['Accumulating ' inDirectory])

% load measures 
if max(accumParams.run) == 1;
    disp('   loading variables');
    load([savePath 'shape']);
end

% accumulate motionArea data averaged across movies
if accumParams.run(1) == 1
    disp('   accumulating motion');
    motionA = accumulateMotion(motionA, shape, accumParams, M, pixelsmm, frameTime, frameDelta);
end

% accumulate motionArea data accumulating across movies
if accumParams.run(2) == 1
    disp('   accumulating motion');
    motionA = accumulateMotionDM(motionA, shape, accumParams, M, pixelsmm, frameTime, frameDelta);
end

% count shapes
if accumParams.run(3) == 1
    disp('   counting shapes');
    motionA = countShapes(motionA, shape, accumParams);
end

motionA.ran=1; % keeps track of whether or not meldMeasures has been run
