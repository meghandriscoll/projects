%%%%%%%% AREA AS LINE ANGLE %%%%%%%%
% bins the shapes by orientation with respect to the lines, then finds the protrusive and retractive areas  
function areaAsLineAngle(numBins, numAreaBins, motionAreaThresh, M, shape, frameTime, pixelsmm, frameDelta, savePath)

% initialize variables
protrusionAreas = cell(numBins);
retractionAreas = cell(numBins);

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
                
                % make a bin mask using the orientation with respect to the lines
                binLower = (b-1)*(pi/2)/numBins; % the lower threshold of the bin
                binUpper = b*(pi/2)/numBins; % the upper threshold of the bin
                binMaskSmall=[];
                binMaskSmall = (shape(s).orientationLine(startFrame:endFrame) >= binLower & shape(s).orientationLine(startFrame:endFrame) < binUpper); % 1 if the orientation is in the bin, 0 if not
                binMask = repmat(binMaskSmall', 1, (M-1)); % an orientation mask the size of motion
                
                % find the protrusive and retractive areas
                motionFront = shape(s).motionAreaFront(startFrame:endFrame,:); % the aligned motion area while the shape is in the ROI
                motionFront = binMask.*motionFront; % the aligned motion while the shape is at the correct orientation
                if max(max(abs(motionFront)))>motionAreaThresh*mean(shape(s).area(startFrame:endFrame)) % won't include shapes for which the motion measure is clearly wrong.
                    disp(['    discard motion data (shape ' num2str(s) '; bin ' num2str(b) ')'])
                    break
                end
                
                toBinProtrusion = sum(motionFront.*(motionFront>0),2); % sup up the protrusive areas
                toBinProtrusion = toBinProtrusion(toBinProtrusion ~=0); % get rid of zero sums from other bins
                toBinRetraction = -1*sum(motionFront.*(motionFront<0),2); % sup up the retractive areas
                toBinRetraction = toBinRetraction(toBinRetraction ~=0); % get rid of zero sums from other bins
                
                protrusionAreas{b}=[protrusionAreas{b}; toBinProtrusion];
                retractionAreas{b}=[retractionAreas{b}; toBinRetraction];
            end
            
        end
        
    end
    
end

% unit conversions
convertAreaPerTime=(1000/pixelsmm)^2*(60/(frameDelta*frameTime)); 

% determine the area bins
maxArea=0;
for b=1:numBins
    maxArea = max([maxArea, max(protrusionAreas{b}), max(retractionAreas{b})]);
end
binStep = maxArea/numAreaBins;
edges = 0:binStep:maxArea; % bins for histc
plotBins = (binStep/2):binStep:(maxArea-binStep/2); % bins for plotting

% plot protrusive and retractive areas
figure; 
colors = colormap(hsv(numBins));
for b=1:numBins
    
    % plot protrusive area
    toPlot = histc(protrusionAreas{numBins-b+1},edges);
    plot(plotBins*convertAreaPerTime, toPlot(1:end-1), 'LineWidth', 2, 'Color', colors(numBins-b+1,:))
    hold on
    
    % plot retractive area
    toPlot = histc(retractionAreas{numBins-b+1},edges);
    plot(plotBins*convertAreaPerTime, toPlot(1:end-1), 'LineWidth', 2, 'LineStyle', '--', 'Color', colors(numBins-b+1,:))
    hold on
end
colorbar;
title('Protrusive and retractive area distributions as a function of cell orientation with respect to the lines');
xlabel('protrusive and retractive area (square micrometers/minute)');
ylabel('count')