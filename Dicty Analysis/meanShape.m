%%%%%%%% MEAN SHAPE %%%%%%%%
% bins the shapes by orientation with respect to the lines, then finds the mean shape 
function meanShape(numBins, M, shape, frameDelta, pixelsmm, frameTime)
figure

% unit conversions
convertDistance=(1000/pixelsmm); 
convertSpeed=(1000/pixelsmm)*(60/(frameDelta*frameTime)); 

% initialize variables
shapeSum = zeros(numBins, M, 2);
count = zeros(1,numBins);

% iterate through the shapes
for s=1:length(shape)
    
	% iterate through the times the shape is in the ROI
    for t=1:length(shape(s).durationInROI) 
        startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
        endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1; % last track in shape's time space
            
        % iterate through the bins
        for b=1:numBins

            % make a bin mask using the orientation with respect to the lines
            binLower = (b-1)*(pi/2)/numBins; % the lower threshold of the bin
            binUpper = b*(pi/2)/numBins; % the upper threshold of the bin
            binMaskSmall=[];
            binMaskSmall = (shape(s).orientationLine(startFrame:endFrame) >= binLower & shape(s).orientationLine(startFrame:endFrame) < binUpper); % 1 if the orientation is in the bin, 0 if not
            count(b) = count(b) + sum(binMaskSmall); % update the count
            binMask = repmat(binMaskSmall', 1, M); % an orientation mask of the correct size

%             % make a velocity mask (to use just replace binMask below with velMask.*binMask in its 2 locations) 
%             velMaskSmall = (shape(s).speed(startFrame:endFrame)*convertSpeed >= 0.3);
%             velMask = repmat(velMaskSmall', 1, M);

            % find the summed aligned motion variables
            shapeAlignX = binMask.*squeeze(shape(s).snakeReorient(startFrame:endFrame,:, 1)); % the x-coordinate of the aligned shape while the shape is in the ROI and in the bin
            shapeSum(b,:,1) = shapeSum(b,:,1)+sum(shapeAlignX, 1); % sum over the aligned x-coordinate
            shapeAlignY = binMask.*squeeze(shape(s).snakeReorient(startFrame:endFrame,:, 2));
            shapeSum(b,:,2) = shapeSum(b,:,2)+sum(shapeAlignY, 1); 

        end
        
    end
    
end

% normalize the variables
for b=1:numBins
    shapeMean.shape(b,:,:) = shapeSum(b,:,:)/count(b);
end

% plot overlaid mean shapes as a function of cell orientation with respect to the lines
figure; 
colors = colormap(hsv(numBins));
for b=1:numBins
    plot(shapeMean.shape(numBins-b+1,:,1)*convertDistance, shapeMean.shape(numBins-b+1,:,2)*convertDistance, 'LineWidth', 2, 'Color', colors(numBins-b+1,:))
    hold on
end
axis equal
colorbar;
title('Mean shape as a function of cell orientation with respect to the lines');
xlabel('x-coordinate (micrometers)');
ylabel('y-coordinate (micrometers)');

% plot mean shapes in seperate figures
minX = min(min(shapeMean.shape(:,:,1)*convertDistance));
maxX = max(max(shapeMean.shape(:,:,1)*convertDistance));
minY = min(min(shapeMean.shape(:,:,2)*convertDistance));
maxY = max(max(shapeMean.shape(:,:,2)*convertDistance));

for b=1:numBins
    figure;
    plot(shapeMean.shape(numBins-b+1,:,1)*convertDistance, shapeMean.shape(numBins-b+1,:,2)*convertDistance, 'LineWidth', 3, 'Color', 'k')
    axis([minX-5 maxX+5 minY-5 maxY+5])
    axis equal
    axis off
    title(['Mean Shape (bin ' num2str(b) ') with Velocity cutoff'])
end

