%%%%%%%%%%%%%%%% MEASURE MEAN MOTION %%%%%%%%%%%%%%%%
%
% Measure mean motion properties, including boundary point motion.
%
% Inputs:
%  N                  - the number of images
%  M                  - the number of boundary points in each snake
%  frameDelta         - the number of frames over which motion is measured
%  savePath           - the directory that data is saved in
%
% Saves:
%  shapeMean 
%   .motion           - 
%   .protrusion       - 
%   .retraction       - 

% note that 200 isn't quite the center of the stretched protrusions/retarctions plot

%%%% This code is slow %%%%%

function measureMotionMean(N, M, frameDelta, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% initialize variables
motionFrontSum = zeros(1,M-1);
protrusionFrontSum = zeros(1,M-1);
retractionFrontSum = zeros(1,M-1);
motionBackSum = zeros(1,M-1);
protrusionBackSum = zeros(1,M-1);
retractionBackSum = zeros(1,M-1);
motionSum = zeros(1,400);
protrusionSum = zeros(1,400);
retractionSum = zeros(1,400);
count = 0;

% iterate through the shapes
for s=1:length(shape)
    
    % display a progress update
    if mod(s, 10) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % sum the front aligned motion variables
    motionFrontSum = motionFrontSum+sum(shape(s).motionFront, 1); % sum the alligned motion
    protrusionsFront = shape(s).motionFront.*(shape(s).motionFront>0); % select for positive motion values
    protrusionFrontSum = protrusionFrontSum+sum(protrusionsFront, 1); % sum the alligned protrusive motion values
    retractionsFront = shape(s).motionFront.*(shape(s).motionFront<0);
    retractionFrontSum = retractionFrontSum+sum(retractionsFront, 1);
    
    % sum the back aligned motion variables
    motionBackSum = motionBackSum+sum(shape(s).motionBack, 1); % sum the alligned motion
    protrusionsBack = shape(s).motionBack.*(shape(s).motionBack>0); % select for positive motion values
    protrusionBackSum = protrusionBackSum+sum(protrusionsBack, 1); % sum the alligned protrusive motion values
    retractionsBack = shape(s).motionBack.*(shape(s).motionBack<0);
    retractionBackSum = retractionBackSum+sum(retractionsBack, 1);
    
    % find and sum the both front and back aligned variables (this could be faster!!!!)
    protrusion = shape(s).motion.*(shape(s).motion>0);
    retraction = shape(s).motion.*(shape(s).motion<0);
    for f=1:shape(s).duration-frameDelta
        
        if shape(s).front(f) < shape(s).back(f)-1 % deal with the periodic boundary conditions by considering two cases
            % align and stretch the motion variable
            motionOne = imresize([shape(s).motion(f,shape(s).back(f):M-1), shape(s).motion(f,1:shape(s).front(f)-1)], [1 200], 'bilinear');
            motionTwo = imresize(shape(s).motion(f,shape(s).front(f):shape(s).back(f)-1), [1 200], 'bilinear');
            motionSum = motionSum+[motionOne, motionTwo];

            % align and stretch the protrusions
            protrusionOne = imresize([protrusion(f,shape(s).back(f):M-1), protrusion(f,1:shape(s).front(f)-1)], [1 200], 'bilinear');
            protrusionTwo = imresize(protrusion(f,shape(s).front(f):shape(s).back(f)-1), [1 200], 'bilinear');
            protrusionSum = protrusionSum+[protrusionOne, protrusionTwo];

            % align and stretch the retractions
            retractionOne = imresize([retraction(f,shape(s).back(f):M-1), retraction(f,1:shape(s).front(f)-1)], [1 200], 'bilinear');
            retractionTwo = imresize(retraction(f,shape(s).front(f):shape(s).back(f)-1), [1 200], 'bilinear');
            retractionSum = retractionSum+[retractionOne, retractionTwo];

        else
            % align and stretch the motion variable
            motionOne = imresize(shape(s).motion(f,shape(s).back(f):shape(s).front(f)-1), [1 200], 'bilinear');
            motionTwo = imresize([shape(s).motion(f,shape(s).front(f):M-1), shape(s).motion(f,1:shape(s).back(f)-1)], [1 200], 'bilinear');
            motionSum = motionSum+[motionOne, motionTwo];

            % align and stretch the protrusions
            protrusionOne = imresize(protrusion(f,shape(s).back(f):shape(s).front(f)-1), [1 200], 'bilinear');
            protrusionTwo = imresize([protrusion(f,shape(s).front(f):M-1), protrusion(f,1:shape(s).back(f)-1)], [1 200], 'bilinear');
            protrusionSum = protrusionSum+[protrusionOne, protrusionTwo];

            % align and stretch the retractions
            retractionOne = imresize(retraction(f,shape(s).back(f):shape(s).front(f)-1), [1 200], 'bilinear');
            retractionTwo = imresize([retraction(f,shape(s).front(f):M-1), retraction(f,1:shape(s).back(f)-1)], [1 200], 'bilinear');
            retractionSum = retractionSum+[retractionOne, retractionTwo];
        end
    end
    
    % update the count
    count = count + shape(s).duration-frameDelta; 
    
end

% normalize
shapeMean.motionFront = motionFrontSum/count;
shapeMean.protrusionFront = protrusionFrontSum/count;
shapeMean.retractionFront = retractionFrontSum/count;

shapeMean.motionBack = motionBackSum/count;
shapeMean.protrusionBack = protrusionBackSum/count;
shapeMean.retractionBack = retractionBackSum/count;

shapeMean.motion = motionSum/count;
shapeMean.protrusion = protrusionSum/count;
shapeMean.retraction = retractionSum/count;

figure
plot(shapeMean.motionFront, 'LineWidth', 2, 'Color', 'g')
hold on
plot(shapeMean.protrusionFront, 'LineWidth', 2, 'Color', 'r')
plot(shapeMean.retractionFront, 'LineWidth', 2, 'Color', 'b')

figure
plot(shapeMean.motionBack, 'LineWidth', 2, 'Color', 'g')
hold on
plot(shapeMean.protrusionBack, 'LineWidth', 2, 'Color', 'r')
plot(shapeMean.retractionBack, 'LineWidth', 2, 'Color', 'b')

figure
plot(shapeMean.motion, 'LineWidth', 2, 'Color', 'g')
hold on
plot(shapeMean.protrusion, 'LineWidth', 2, 'Color', 'r')
plot(shapeMean.retraction, 'LineWidth', 2, 'Color', 'b')

% save the variables
save([savePath 'shapeMean'],'shapeMean');
