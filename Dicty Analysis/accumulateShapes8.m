%%%%%%%%%%%%%%%%%%%%%%%%%%%% ACCUMULATE SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function accumulateShapes8()

%%%%%%% TURN INDIVIDUAL SHAPE PROGRAMS ON AND OFF %%%%%%%%%%%%%%%%%%%%%%%%%
% extract and analyze shapes
parameters.run(1) = 0;     % read directory (did this!)
parameters.run(2) = 0;     % find the approximate boundaries (did this!)
parameters.run(3) = 0;     % track blobs
parameters.run(4) = 0;     % find the snaked boundaries
parameters.run(5) = 0;     % remove bad snakes automatically
parameters.run(6) = 0;     % remove bad snakes manually
parameters.run(7) = 0;     % initialize shapes
parameters.run(8) = 0;     % measure shape
parameters.run(9) = 1;     % measure motion
parameters.run(10) = 1;    % measure directed surfaces statistics
parameters.run(11) = 0;    % shape space statistics
parameters.run(12) = 0;    % measure means

% make image sequences
parameters.verify(1) = 0;    % plot the approximate boundaries
parameters.verify(2) = 0;    % plot the tracked approximate boundaries
parameters.verify(3) = 0;    % plot the snake boundaries
    parameters.snakeType = 'snakeAutoRemove';    % options: 'snakeTrack', 'snakeAutoRemove', 'snakeManRemove' (tracked, automatically culled, or manually culled snakes)
    parameters.backgroundSnake = 1;          % options: 0 (white backgroud), 1 (image background), 2 (accumulating image, no background)

parameters.verify(4) = 0;    % plot the shape measures on images
    parameters.plotMeasure = 'frontBack';     % options: 'shape', 'curvature', 'motion', 'centroid', 'frontBack', 'roi'
    parameters.backgroundMeasure = 1;        % options: 0 (white background), 1 (image background), 2 (accumulating image, no background)

% make plots
parameters.plots(1) = 0;    % plot plots for individual shapes
    parameters.plotPlots = 'plotSpaceTime';       % options: 'pathSpeed', 'plotSpaceTime' (space-time plots), 'trackingArrow', 'motionArrow'
    parameters.shapeChoose = 'longestDuration';       % options: 'random', 'longestDuration', 'largestDisplacement'
    parameters.numToPlot = 5;                % the number of shapes to make plots for
    
parameters.plots(2) = 0;    % plot overall plots
    parameters.plotOverall = 'clusterMeasures';       % options: 'clusterMeasures', 'motionAsEccentricity'
    
parameters.plots(3) =  0;    % plot directed surfaces plots
    parameters.plotLine = 'measureCompare';       % options: 'measureCompare', 'motionAsLineAngle', 'areaAsLineAngle', 'eccentricityVsLineAngle', 'meanShape', 'spider';
    
%%%%%%% TURN ACCUMULATORS ON AND OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% ANALYZE MOVIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set main directory
mainPath = '/Users/meghandriscoll/Desktop/Ridges/';

% start log file
dateStr = date;
diary([mainPath 'log8' dateStr '.txt'])
display('~~~~~~~~~~~~ ACCUMULATING SHAPES ~~~~~~~~~~~~')

% %%%%%%% ax3 glass (090818) %%%%%%%
% directoryPath = '090818';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)

% %%%%%%% ax3 glass (090819) %%%%%%%
% directoryPath = '090819';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)

% %%%%%%% ax3 glass (091111_2) %%%%%%%
% directoryPath = '091111_2';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)
% 
% %%%%%%% ax3 glass (091111_3) %%%%%%%
% directoryPath = '091111_3';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)
% 
% %%%%%%% ax3 glass (100120_2) %%%%%%%
% directoryPath = '100120_2';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)
% 
% %%%%%%% ax3 glass (100120_3) %%%%%%%
% directoryPath = '100120_3';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='ax3_glass';
% shapes(parameters)
% 
% %%%%%%% glass (110316) %%%%%%%
% directoryPath = '110316';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='glass';
% shapes(parameters)
% 
% %%%%%%% glass (120430) %%%%%%%
% directoryPath = '120430';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='glass';
% shapes(parameters)
% 
% %%%%%%% film (101025) %%%%%%%
% directoryPath = '101025';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='film';
% shapes(parameters)
% 
% %%%%%%% ridges, 0.4 (101020) %%%%%%%
% directoryPath = '101020';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([90.143, 90.366, 90.287]);
% parameters.lineSep = 0.4;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 0.4 (101024) %%%%%%%
% directoryPath = '101024';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([92.268, 92.132, 91.857, 92.291, 91.843, 91.857, 91.882, 92.021]);
% parameters.lineSep = 0.4;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 0.6 (110317) %%%%%%%
% directoryPath = '110317';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([83.701, 84.177, 84.308, 84.041, 83.727, 84.270, 83.904]);
% parameters.lineSep = 0.6;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%% ridges, 0.6 (110926) %%%%%%%
% directoryPath = '110926';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([88.649, 88.655, 88.649 , 88.760 , 88.652 , 88.319]);
% parameters.lineSep = 0.6;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%% here!!!!
% %%%%%%% ridges, 0.8 (110210) %%%%%%%
% directoryPath = '110210';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([5.356, 5.849, 5.548, 5.605, 5.669]);
% parameters.lineSep = 0.8;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 0.8 (110421) %%%%%%%
% directoryPath = '110421';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([90.141, 90.141, 90.000, 89.829, 90.000]);
% parameters.lineSep = 0.8;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 1.2 (120423) %%%%%%%
% directoryPath = '120423';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([-87.858, -87.871, -87.871, -87.875, -87.883, -87.871, -87.875]);
% parameters.lineSep = 1.2;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 1.5 (120424) %%%%%%%
% directoryPath = '120424';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([-89.775, -89.888, -90, -90, -90, -90, -90, -89.776]);
% parameters.lineSep = 1.5;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 2 (110318) %%%%%%%
% directoryPath = '110318';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([-84.167, -84.067, -84.055, -84.167, -84.190, -83.979, -84.090, -84.090, -84.090, -83.968]);
% parameters.lineSep = 2;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 2 (110419) %%%%%%%
% directoryPath = '110419';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([3.764, 3.715, 3.715, 3.599, 3.686, 3.731, 3.861, 4.036, 3.987]);
% parameters.lineSep = 2;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 10 (110630) %%%%%%%
% directoryPath = '110630';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([92.91,93.14,93.49,92.91,93.37]);
% parameters.lineSep = 10;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 10 (110721) %%%%%%%
% directoryPath = '110721';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([90.23,90.23,90.46,90.26]);
% parameters.lineSep = 10;
% parameters.type='ridges';
% shapes(parameters)
% 
% %%%%%%% ridges, 10 (110805) %%%%%%%
% directoryPath = '110805';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([93.555,93.562,93.669,93.677,93.555]);
% parameters.lineSep = 10;
% parameters.type ='ridges';
% shapes(parameters)
% 
%%%%%%% thin ridges, 2 (110510) %%%%%%%
directoryPath = '110510';
parameters.inDirectory = [mainPath directoryPath '/'];
parameters.savePath = [mainPath directoryPath '/saveData/'];
parameters.lineAngle = mean([-92.752, -92.735, -93.079, -92.735, -92.845, -92.827, -92.675, -92.667, -92.985]);
parameters.lineSep = 2;
parameters.type ='thin_ridges';
shapes(parameters)


%%%%%%% grooves, 2 (110418) %%%%%%%
directoryPath = '110418';
parameters.inDirectory = [mainPath directoryPath '/'];
parameters.savePath = [mainPath directoryPath '/saveData/'];
parameters.lineAngle = mean([3.142, 2.924, 3.136, 3.149, 3.036, 3.136, 3.142, 3.161, 3.142, 3.036]);
parameters.lineSep = 2;
parameters.type='grooves';
shapes(parameters)

%%%%%%% grooves, 2 (110508) %%%%%%%
directoryPath = '110508';
parameters.inDirectory = [mainPath directoryPath '/'];
parameters.savePath = [mainPath directoryPath '/saveData/'];
parameters.lineAngle = mean([91.134,91.132,91.139,91.132,91.134,91.245,91.126]);
parameters.lineSep = 2;
parameters.type='grooves';
shapes(parameters)
% 
% %%%%%%% grooves, 10 (110701) %%%%%%%
% directoryPath = '110701';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([95.27, 95.59, 95.15, 95.15, 95.17]);
% parameters.lineSep = 10;
% parameters.type='grooves';
% shapes(parameters)
% 
% %%%%%%% thin grooves, 0.6 (110524) %%%%%%%
% directoryPath = '110524';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([-74.964, -74.915, -74.470, -74.783, -74.337, -74.175, -74.369, -74.391]);
% parameters.lineSep = 0.6;
% parameters.type='thin_grooves';
% shapes(parameters)
% 
% %%%%%%% sawtooth (110415) %%%%%%%
% directoryPath = '110415';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([-84.637, -84.587, -84.495, -84.505, -84.425, -84.615, -84.526, -84.626, -84.532, -84.472]);
% parameters.lineSep = 0.8;
% parameters.type='sawtooth';
% shapes(parameters)
% 
% %%%%%%% sawtooth (110509) %%%%%%%
% directoryPath = '110509';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([93.652, 93.890,93.961,93.852,94.020,93.875,93.914,93.921,93.867,94.168]);
% parameters.lineSep = 0.8;
% parameters.type='sawtooth';
% shapes(parameters)
% 
% %%%%%% myoII null, glass (110601) %%%%%%%
% directoryPath = '110601';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = 0;
% parameters.lineSep = 0;
% parameters.type='myoII';
% shapes(parameters)
% 
% %%%%%% myoII null, grooves, 0.8 (110907) %%%%%%%
% directoryPath = '110907';
% parameters.inDirectory = [mainPath directoryPath '/'];
% parameters.savePath = [mainPath directoryPath '/saveData/'];
% parameters.lineAngle = mean([95.767, 95.891, 95.868, 96.080, 95.926, 95.991, 96.068, 96.266, 96.355]);
% parameters.lineSep = 0.8;
% parameters.type='myoII_grooves';
% shapes(parameters)

diary off