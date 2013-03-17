%%%%%%%% FIND MOTION AS ECCENTRICITY %%%%%%%%

% bins the shapes by ranked eccentricity, then finds the mean aligned motion, protrusion, and retraction    

function shapeMean = findMotionAsEccentricityDM(motionA, numLoopsRan, numBins, motionAreaThresh, M, shape, frameDelta)
 
% find  eccentricities
if numLoopsRan == 0
    allGoodEccs = [];

    for s=1:length(shape) % iterate through the shapes

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
    
    shapeMean.goodEccs = allGoodEccs;
 
% need to pass bineEdges into this function somehow!!!!    
elseif numLoopsRan == 1;
    
    % initialize variables
    motionFrontSum = zeros(numBins,(M-1)/2);
    protrusionFrontSum = zeros(numBins,(M-1)/2);
    retractionFrontSum = zeros(numBins,(M-1)/2);
    count = zeros(1,numBins);

    % iterate through the shapes
    for s=1:length(shape)

        % iterate through the times the shape is in the ROI
        for t=1:length(shape(s).durationInROI) 
            startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
            endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1-frameDelta; % last track in shape's time space that is not larger than the length of motion

            % check that the track is inside the ROI for long enough to calculate local motion
            if endFrame >= startFrame

                % iterate through the bins
                for b=1:numBins 

                    % bin by eccentricity
                    binMaskSmall=[];
                    binMaskSmall = (shape(s).eccentricity(startFrame:endFrame) >= motionA.binEdges(b) & shape(s).eccentricity(startFrame:endFrame) < motionA.binEdges(b+1)); % 1 if the orientation is in the bin, 0 if not
                    binMask = repmat(binMaskSmall', 1, (M-1)/2); % an orientation mask the size of motion

                    % make a mask to exclude motionAreas that are too large
                    motionFrontTest = shape(s).motionAreaFront(startFrame:endFrame,:); % the aligned motion while the shape is in the ROI
                    motionCutoff = motionAreaThresh*mean(shape(s).area(startFrame:endFrame)); % determine the area cutoff for the measure associated with each boundary point
                    motionFrontLargeMask = (abs(motionFrontTest) > motionCutoff); % remove motionAreas that are too large
                    motionMaskSmall = (1-max(motionFrontLargeMask'));
                    motionMask = repmat(motionMaskSmall', 1, (M-1)/2);

                    % find the summed aligned motion variables
                    motionFront = shape(s).motionAreaFront(startFrame:endFrame,:); % the aligned motion while the shape is in the ROI
                    motionFront = fliplr(motionFront(:,1:(M-1)/2)+fliplr(motionFront(:,(M-1)/2+1:(M-1))));% fold the left side of the cell onto the right side
                    motionFront = motionMask.*binMask.*motionFront; % the aligned motion while the shape is at the correct orientation
 
                    motionFrontSum(b,:) = motionFrontSum(b,:)+sum(motionFront, 1); % sum the alligned motion
                    protrusionsFront = motionMask.*binMask.*motionFront.*(motionFront>0); % select for positive motion values
                    protrusionFrontSum(b,:) = protrusionFrontSum(b,:)+sum(protrusionsFront, 1); % sum the alligned protrusive motion values
                    retractionsFront = motionMask.*binMask.*motionFront.*(motionFront<0);
                    retractionFrontSum(b,:) = retractionFrontSum(b,:)+sum(retractionsFront, 1);
                    count(b) = count(b) + sum(motionMaskSmall.*binMaskSmall); % update the count
                end

            end

        end

    end
    
    for b=1:numBins
        shapeMean.protrusionFrontSum(b,:) = protrusionFrontSum(b,:);
        shapeMean.retractionFrontSum(b,:) = retractionFrontSum(b,:);
        shapeMean.count(b) = count(b);
    end
    
end



