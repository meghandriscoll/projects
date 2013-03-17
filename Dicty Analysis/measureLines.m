%%%%%%%%%%%%%%%% MEASURE LINES %%%%%%%%%%%%%%%%
%
% Calculate line (ridges, grooves, etc...) specifc statistics. An ROI is assumed to be in use.
%
% Inputs:
%  N                - the number of images
%  M                - the number of boundary points plus one
%  lineAngle        - the angle of surface directionality within the ROI
%  frameVelocity    - the number of frames speed is found over
%  savePath         - the directory where data is saved
%
% Saves:
%  shape
%  shapeLine        - a backup copy of shape that will not be overwritten by other programs
%  meanOnLine       - mean statistics for shapes on lines

%%%%%% This is slow!!!!!! %%%%%%

function measureLines(N, M, lineAngle, frameVelocity, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)
save([savePath 'roi']); % loads frame2inROI and frame2outROI

% initialize variables
inTracks=0; outTracks=0;
inSpeed=[]; outSpeed=[]; % mean measures inside and outside of the ROI
inEcc=[]; outEcc=[];
inArea=[]; outArea=[];
inSolidity=[]; outSolidity=[];

%inOrient=[]; outOrient=[]; % mean measures inside and outside of the ROI measured with respect to line directionality
%inVelDir=[]; outVelDir=[];

% iterate through the shapes
for s=1:length(shape) 
    
    % display progress
    if mod(s, 100) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % find the mean and standard deviation of measures inside and outside the ROI
    for t=1:length(shape(s).durationInROI) % iterate through the tracks inside the roi, appending variables
        startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
        endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1; % last track in shape's time space
        if shape(s).durationInROI(t) >= frameVelocity
            inSpeed = [inSpeed, shape(s).speed(startFrame+(frameVelocity-1)/2:endFrame-(frameVelocity-1)/2)];
        end
        inEcc = [inEcc, shape(s).eccentricity(startFrame:endFrame)]; 
        inArea = [inArea, shape(s).area(startFrame:endFrame)];
        inSolidity=[inSolidity, shape(s).solidity(startFrame:endFrame)];
        inTracks=inTracks+1;
    end
        
    for t=1:length(shape(s).durationOutROI) % iterate through the tracks outside of the roi, appending variables
        startFrame = shape(s).startFrameOutROI(t)-shape(s).startFrame+1; % first track in shape(s) time space
        endFrame = shape(s).endFrameOutROI(t)-shape(s).startFrame+1; % last track in shape(s) time space
        if shape(s).durationOutROI(t) >= frameVelocity
            outSpeed = [outSpeed, shape(s).speed(startFrame+(frameVelocity-1)/2:endFrame-(frameVelocity-1)/2)];
        end
        outEcc = [outEcc, shape(s).eccentricity(startFrame:endFrame)]; 
        outArea = [outArea, shape(s).area(startFrame:endFrame)];
        outSolidity=[outSolidity, shape(s).solidity(startFrame:endFrame)];
        outTracks=outTracks+1;
    end
    
    % find the velocity direction and the orientation with respect to the line direction (outputs in radians)
    shape(s).velocityDirLine = mod(mod(shape(s).velocityDirection, 2*pi)-mod(lineAngle*(2*pi)/360, 2*pi), 2*pi);
    shape(s).orientationLine = mod(mod(shape(s).orientation*(2*pi)/360, 2*pi)-mod(lineAngle*(2*pi)/360, 2*pi), pi); % fold orientation into two quadrants
    shape(s).orientationLine = (pi-shape(s).orientationLine).*(shape(s).orientationLine>pi/2)+shape(s).orientationLine.*(shape(s).orientationLine<pi/2); % fold orientation into one quadrant
    % !!!!!!!!!!!!shape(s).orientationLine = (shape(s).orientationLine-pi).*(shape(s).orientationLine>pi/2)+shape(s).orientationLine.*(shape(s).orientationLine<pi/2); % fold orientation into one quadrant
%     % do something with these
%     inOrient=[]; outOrient=[]; % mean measures inside and outside of the ROI measured with respect to line directionality
%     inVelDir=[]; outVelDir=[];
    
end

% calculate mean values inside and outside the ROI
meanOnLine.inSpeed = mean(inSpeed); 
meanOnLine.outSpeed = mean(outSpeed);
meanOnLine.inEcc = mean(inEcc);
meanOnLine.outEcc = mean(outEcc);
meanOnLine.inArea = mean(inArea);
meanOnLine.outArea = mean(outArea);
meanOnLine.inSolidity = mean(inSolidity);
meanOnLine.outSolidity = mean(outSolidity);

% calculate the standard deviation of values inside and outside the ROI
meanOnLine.inSpeedSTD = std(inSpeed); 
meanOnLine.outSpeedSTD = std(outSpeed);
meanOnLine.inEccSTD = std(inEcc);
meanOnLine.outEccSTD = std(outEcc);
meanOnLine.inAreaSTD = std(inArea);
meanOnLine.outAreaSTD = std(outArea);
meanOnLine.inSoliditySTD = std(inSolidity);
meanOnLine.outSoliditySTD = std(outSolidity);

% calculate an error for values inside and outside the ROI
% the calculated error is just the std/sqrt(num of tracks)
meanOnLine.inSpeedError = meanOnLine.inSpeedSTD/sqrt(inTracks); 
meanOnLine.outSpeedError = meanOnLine.outSpeedSTD/sqrt(outTracks);
meanOnLine.inEccError = meanOnLine.inEccSTD/sqrt(inTracks);
meanOnLine.outEccError = meanOnLine.outEccSTD/sqrt(outTracks);
meanOnLine.inAreaError = meanOnLine.inAreaSTD/sqrt(inTracks);
meanOnLine.outAreaError = meanOnLine.outAreaSTD/sqrt(outTracks);
meanOnLine.inSolidityError = meanOnLine.inSoliditySTD/sqrt(inTracks);
meanOnLine.outSolidityError = meanOnLine.outSoliditySTD/sqrt(outTracks);

% save the variables
save([savePath 'shape'],'shape', 'frame2shape');
save([savePath 'shapeLine'],'shape', 'frame2shape');
save([savePath 'meanOnLine'],'meanOnLine');
