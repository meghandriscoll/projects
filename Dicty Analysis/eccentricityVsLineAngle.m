%%%%%%%% ECCENTRICITY VS LINE ANGLE %%%%%%%%
% tries to remove the effects of eccentricity on motionAsLineAngle  
function eccentricityVsLineAngle(numPerBin, motionAreaThresh, M, shape, frameTime, pixelsmm, frameDelta, savePath)

% chooses the average bin size such that, on average, numPerBin cells are in each bin
allGoodEccs = [];
for s=1:length(shape) % iterate through the shapes to accumulate the eccentricities
    
	% iterate through the times the shape is in the ROI
    for t=1:length(shape(s).durationInROI) 
        startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
        endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1-frameDelta; % last track in shape's time space that is not larger than the length of motion
        
        % check that the track is inside the ROI for long enough to calculate local motion
        if endFrame >= startFrame
            
            % accumulate the eccentricities
            allGoodEccs=[allGoodEccs, shape(s).eccentricity(startFrame:endFrame)]; 
            
        end
    end
end

allGoodEccsSort = sort(allGoodEccs); % sort the eccentricities
meanDistEcc = mean(allGoodEccsSort(2:end)-allGoodEccsSort(1:end-1)); % find the mean distance between eccentricities
distEcc = 2*numPerBin*meanDistEcc; % the eccentricity range of each eccentricity bin
numEccBins = 1/distEcc; % the number of eccentricity bins

% initialize variables
motionFrontAllDif = zeros(1,(M-1)/2);
protrusionFrontAllDif = zeros(1,(M-1)/2);
retractionFrontAllDif = zeros(1,(M-1)/2);
countAll = 0;

% iterate through the shapes
for s=1:length(shape)
    
    % display progress update
    if mod(s,10)==0
        disp(['   shape ' num2str(s) ' out of ' num2str(length(shape))])
    end
    
	% iterate through the times the shape is in the ROI
    for t=1:length(shape(s).durationInROI) 
        startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
        endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1-frameDelta; % last track in shape's time space that is not larger than the length of motion
        
        % check that the track is inside the ROI for long enough to calculate local motion
        if endFrame >= startFrame
            
            % iterate through the eccentricity bins
            for c=1:numEccBins
                
                % initialize variables
                motionFrontSum = zeros(2,(M-1)/2);
                protrusionFrontSum = zeros(2,(M-1)/2);
                retractionFrontSum = zeros(2,(M-1)/2);
                count = zeros(1,2);
                
                % make an eccentricity mask 
                binLower = (c-1)/numEccBins; % the lower threshold of the bin
                binUpper = c/numEccBins; % the upper threshold of the bin
                eccMaskSmall = (shape(s).eccentricity(startFrame:endFrame) >= binLower & shape(s).eccentricity(startFrame:endFrame) < binUpper);
                eccMask = repmat(eccMaskSmall', 1, (M-1)/2);
                
                % iterate through the angle bins
                for b=1:2
                
                    % make a bin mask using the orientation with respect to the lines
                    binLower = (b-1)*(pi/2)/2; % the lower threshold of the bin
                    binUpper = b*(pi/2)/2; % the upper threshold of the bin
                    binMaskSmall = (shape(s).orientationLine(startFrame:endFrame) >= binLower & shape(s).orientationLine(startFrame:endFrame) < binUpper); % 1 if the orientation is in the bin, 0 if not
                    binMask = repmat(binMaskSmall', 1, (M-1)/2); % an orientation mask the size of motion

                    % find the summed aligned motion variables
                    motionFront = shape(s).motionAreaFront(startFrame:endFrame,:); % the aligned motion while the shape is in the ROI
                    motionFront = fliplr(motionFront(:,1:(M-1)/2)+fliplr(motionFront(:,(M-1)/2+1:(M-1))));% fold the left side of the cell onto the right side
                    motionFront = eccMask.*binMask.*motionFront; % the aligned motion while the shape is at the correct orientation
                    if max(max(abs(motionFront)))>motionAreaThresh*mean(shape(s).area(startFrame:endFrame)) % won't include shapes for which the motion measure is clearly wrong.
                        disp(['    discard motion data (shape ' num2str(s) '; bin ' num2str(b) ')'])
                        break
                    end
                    motionFrontSum(b,:) = motionFrontSum(b,:)+sum(motionFront, 1); % sum the aligned motion
                    protrusionsFront = eccMask.*binMask.*motionFront.*(motionFront>0); % select for positive motion values
                    protrusionFrontSum(b,:) = protrusionFrontSum(b,:)+sum(protrusionsFront, 1); % sum the aligned protrusive motion values
                    retractionsFront = eccMask.*binMask.*motionFront.*(motionFront<0);
                    retractionFrontSum(b,:) = retractionFrontSum(b,:)+sum(retractionsFront, 1);
                    count(b) = count(b) + sum(eccMaskSmall.*binMaskSmall); % update the count
                end
                
                % find the subtracted values, then sums them
                if count(1,1) && count(1,2)
                    motionFrontAllDif = motionFrontAllDif+motionFrontSum(1,:)/count(1,1)-motionFrontSum(2,:)/count(1,2);
                    protrusionFrontAllDif = protrusionFrontAllDif+protrusionFrontSum(1,:)/count(1,1)-protrusionFrontSum(2,:)/count(1,2);
                    retractionFrontAllDif = retractionFrontAllDif+retractionFrontSum(1,:)/count(1,1)-retractionFrontSum(2,:)/count(1,2);
                    countAll = countAll+1;
                end
                
            end
            
        end
        
    end
    
end

% normalize the variables
shapeMean.motionFront = motionFrontAllDif/countAll;
shapeMean.protrusionFront = protrusionFrontAllDif/countAll;
shapeMean.retractionFront = retractionFrontAllDif/countAll;

% unit conversions
convertAreaPerTime=(1000/pixelsmm)^2*(60/(frameDelta*frameTime)); 

% plot protrusions and retractions
figure; 
plot(shapeMean.protrusionFront*convertAreaPerTime, 'LineWidth', 2, 'Color', 'r')
hold on
plot(shapeMean.retractionFront*convertAreaPerTime, 'LineWidth', 2, 'Color', 'b')   
title('Average Differance (Line Angle Different, Eccentricity the Same)');
xlabel('boundary position (a.u.)');
ylabel('local motion differance (square micrometers/minute)')

% plot protrusions and retractions
figure; 
plot(shapeMean.protrusionFront*convertAreaPerTime, 'LineWidth', 2, 'Color', 'r')
hold on
plot(fliplr(-1*shapeMean.retractionFront*convertAreaPerTime), 'LineStyle', ':', 'LineWidth', 2, 'Color', 'b')   
title('Average Differance (Line Angle Different, Eccentricity the Same)');
xlabel('boundary position (a.u.)');
ylabel('local motion differance (square micrometers/minute)')
