%%%%%%%% SPIDER %%%%%%%%
% bins the shapes by orientation with respect to the lines, then finds the mean shape 

function spider(numBins, spiderDuration, numTracks, eccCutoff, shape, pixelsmm)
figure

% unit conversions
convertDistance=(1000/pixelsmm); 

% initialize variables
trackData = []; % a matrix of size z by 3 where the first column is the shape ID, the second the bin, and the third the start frame of the spider track

% iterate through the shapes
for s=1:length(shape)
    
	% iterate through the tracks in which the shape is in the ROI
    for t=1:length(shape(s).durationInROI) 
        startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
        endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1; % last track in shape's time space
        
        framePointer = startFrame; % assign a pointer to iterate through the frames
        
        % iterate through the frames in which the shape is in the ROI
        while framePointer < endFrame-spiderDuration+1
        
            % check to make sure that the eccentricty of the shape is large enough
            if shape(s).eccentricity(framePointer) < eccCutoff 
                framePointer=framePointer+1;
            
            % initiate a track if (1) this is the first track, (2) the last track initiated was for another shape, or (3) the current frame is at least spiderDuration after the last initiated track
            elseif isempty(trackData) || (trackData(end, 1) ~= s) || (trackData(end, 3)<framePointer-spiderDuration+1)
                    
                    % determine the bin (binned by initial orientation with respect to the lines)
                    binInit = ceil(shape(s).orientationLine(framePointer)*numBins/(pi/2)+0.00000001);
                    
                    %binInit could be wrong !!!!!!!!!!
                    trackData = [trackData; s, binInit, framePointer]; % initiate a track
                    framePointer=framePointer+1;
            
            % a track should not be initiated    
            else 
                framePointer=framePointer+1;
               
            end  
            
        end
    end
end
            
% find the maximum number of tracks in each bin, and determine which tracks to plot if there are too many tracks
binCount = NaN(numBins, 1);
tracksToPlot = cell(numBins,1);
indices=1:1:length(trackData);
for b=1:numBins
    binMask = (trackData(:,2)==b); 
    binCount(b,1) = sum(binMask); % find the number of tracks in the bin
    indicesBin = indices'.*(binMask);
    indicesBin = indicesBin(indicesBin ~=0); % find the indices of the tracks in the bin 
    indicesOrder = randperm(length(indicesBin)); % determine a random ordering of the tracks
    binOrder = indicesBin(indicesOrder); % find a randomally ordered list of track indices
    numToPlot = min([length(binOrder), numTracks]); % find the number of tracks to plot
    tracksToPlot{b,1} = binOrder(1:numToPlot); % find the indices, within trackData, of the tracks to be plotted for each bin
end

% plot spider plots for each bin
for b=1:numBins
    
    % construct a colormap
    colors = colormap(hsv(length(tracksToPlot{b,1})));
    
    % iterate through the tracks in the bin
    figure
    for t=1:length(tracksToPlot{b,1})
    
        % find the shape ID and start frame
        ID = trackData(tracksToPlot{b,1}(t),1);
        startFrame = trackData(tracksToPlot{b,1}(t),3);

        % plot the track
        plot(convertDistance*(shape(ID).centroid(startFrame:startFrame+spiderDuration-1, 1)-shape(ID).centroid(startFrame, 1)), convertDistance*(shape(ID).centroid(startFrame:startFrame+spiderDuration-1, 2)-shape(ID).centroid(startFrame, 2)), 'LineWidth', 2, 'Color', colors(t,:));
        hold on
    end
    title(['Spider Plot (Bin ' num2str(b) ')']);
    axis equal
    %axis off
    
end