%%%%%%%% MOTION AS ECCENTRICITY %%%%%%%%
% bins the shapes by ranked eccentricity, then finds the mean aligned motion, protrusion, and retraction    
function motionAsEccentricity(numBins, motionAreaThresh, M, shape, inDirectory, frameTime, pixelsmm, frameDelta, savePath)

% find bin edges
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

allGoodEccsSort=sort(allGoodEccs); % sort the eccentricities
binIndices = round(linspace(1,length(allGoodEccsSort), numBins+1));
%binIndices = 1:floor(length(allGoodEccsSort)/numBins):length(allGoodEccsSort)
binEdges = allGoodEccsSort(binIndices);

% find the mean eccentricities in each bin
meanEccs = zeros(1,numBins);
for j=1:numBins
    meanEccs(1,j) = mean(allGoodEccsSort(floor((j-1)*length(allGoodEccsSort)/numBins)+1:floor(j*length(allGoodEccsSort)/numBins)));
end
            
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
                binMaskSmall = (shape(s).eccentricity(startFrame:endFrame) >= binEdges(b) & shape(s).eccentricity(startFrame:endFrame) < binEdges(b+1)); % 1 if the orientation is in the bin, 0 if not
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
                if max(max(abs(motionFront)))>motionAreaThresh*mean(shape(s).area(startFrame:endFrame)) % won't include shapes for which the motion measure is clearly wrong.
                    disp(['    discard motion data (shape ' num2str(s) '; bin ' num2str(b) ')'])
                    break
                end
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

count
% normalize the variables
for b=1:numBins
    shapeMean.motionFront(b,:) = motionFrontSum(b,:)/count(b);
    shapeMean.protrusionFront(b,:) = protrusionFrontSum(b,:)/count(b);
    shapeMean.retractionFront(b,:) = retractionFrontSum(b,:)/count(b);
end

% unit conversions
convertArea=(1000/pixelsmm)^2; 
convertAreaPerTime=(1000/pixelsmm)^2*(60/(frameDelta*frameTime)); 

% % % plot protrusions and retractions
% % figure; 
% % colors = colormap(hsv(numBins)); 
% % for b=1:numBins
% %     plot(shapeMean.protrusionFront(numBins-b+1,:)*convertAreaPerTime, 'LineWidth', 2, 'Color', colors(numBins-b+1,:))
% %     hold on
% %     plot(shapeMean.retractionFront(numBins-b+1,:)*convertAreaPerTime, 'LineWidth', 2, 'Color', colors(numBins-b+1,:))   
% % end
% % colorbar;
% % title('Protrusive and retractive motion as a function of eccentricity rank');
% % xlabel('boundary position (a.u.)');
% % ylabel('local motion (square micrometers/minute)')
% % 
% % % plot protrusions and inverted retractions
% % figure; 
% % colors = colormap(hsv(numBins));
% % for b=1:numBins
% %     plot(shapeMean.protrusionFront(numBins-b+1,:)*convertAreaPerTime, 'LineWidth', 2, 'Color', colors(numBins-b+1,:))
% %     hold on
% %     plot(fliplr(-1*shapeMean.retractionFront(numBins-b+1,:)*convertAreaPerTime), 'LineStyle', '--', 'LineWidth', 2, 'Color', colors(numBins-b+1,:))   
% % end
% % colorbar;
% % title('Protrusive and retractive motion as a function of eccentricity rank');
% % xlabel('boundary position (a.u.)');
% % ylabel('local motion (square micrometers/minute)')
% 
% % fit the protrusions to a sum of two von Mises distributions
% % (get rid of the 20 points on the ends)
% oneVonMises = @(p,x) exp(p.*cos(x))./(2*pi*besseli(0,p));
% oneVonMisesStart = 2;
% twoVonMises = @(p,x) abs(p(1)).*exp(p(2).*cos(x))./(2*pi*besseli(0,p(2)))+abs(p(4)).*exp(p(3).*cos(x))./(2*pi*besseli(0,p(3)));
% twoVonMisesStart = [0.1, 5, 1, 0.9];
% angleToFit = linspace(0,pi,100);
% angleToFit = [fliplr(-1*angleToFit(2:end)), angleToFit];
% proToFit = [fliplr(shapeMean.protrusionFront(:,2:end)), shapeMean.protrusionFront];
% [proToFitRows, proToFitCols]= size(proToFit);
% coefEsts = cell(1,proToFitRows);
% coefEsts = zeros(1,proToFitRows);
% %figure
% for r=1:proToFitRows
%     proToFit(r,:) = proToFit(r,:)/(sum(proToFit(r,:))*(2*pi)/proToFitCols);
%     %nlinfit(angleToFit(25:175), proToFit(r,25:175), oneVonMises, oneVonMisesStart);
%     coefEsts(1,r) = nlinfit(angleToFit(25:175), proToFit(r,25:175), oneVonMises, oneVonMisesStart);
%     %plot(angleToFit, proToFit(r,:), 'LineWidth', 3, 'Color','b');
%     %line(angleToFit, oneVonMises(coefEsts(1,r), angleToFit), 'LineWidth', 1.5, 'Color','r');
%     %hold on
% end
% %figure
% %for r=1:proToFitRows
%     %plot(meanEccs,coefEsts, 'Marker', '.', 'MarkerSize', 20, 'Color', 'r', 'LineStyle', 'none')
%     %hold on
% %end
% 
% % figure
% % %for r=1:proToFitRows
% %     plot(meanEccs,coefEsts-1, 'Marker', '.', 'MarkerSize', 20)
% %     %hold on
% % %end
% % figure
% % plot(1-meanEccs,coefEsts-1, 'Marker', '.', 'MarkerSize', 20)
% 
% offsetExp = @(p,x) p(1)+p(2).*exp(p(3).*x);
% offsetStart = [1,1,1];
% coefExp = nlinfit(meanEccs, coefEsts, offsetExp, offsetStart);
% %line(meanEccs, offsetExp(coefExp, meanEccs), 'LineWidth', 1.5, 'Color','r');
% 
% concProtrusion = sum(count.*coefEsts)/sum(count);
% concProtrusion = coefEsts;
% 
% % fit the retractions to a von Mises distributions
% % (get rid of the 20 points on the ends)
% oneVonMises = @(p,x) exp(p.*cos(x))./(2*pi*besseli(0,p));
% oneVonMisesStart = 2;
% angleToFit = linspace(0,pi,100);
% angleToFit = [fliplr(-1*angleToFit(2:end)), angleToFit];
% retToFit = -1*[shapeMean.retractionFront, fliplr(shapeMean.retractionFront(:,2:end))];
% [retToFitRows, retToFitCols]= size(retToFit);
% coefEsts = zeros(1,retToFitRows);
% %figure
% for r=1:retToFitRows
%     retToFit(r,:) = retToFit(r,:)/(sum(retToFit(r,:))*(2*pi)/retToFitCols);
%     %nlinfit(angleToFit(25:175), retToFit(r,25:175), oneVonMises, oneVonMisesStart)
%     coefEsts(1,r) = nlinfit(angleToFit(25:175), retToFit(r,25:175), oneVonMises, oneVonMisesStart);
%     %plot(angleToFit, retToFit(r,:), 'LineWidth', 3, 'Color','b');
%     %line(angleToFit, oneVonMises(coefEsts(r), angleToFit), 'LineWidth', 1.5, 'Color','r');
%     %hold on
% end
% coefEsts
% %figure
% %plot(meanEccs,coefEsts, 'Marker', '.', 'MarkerSize', 20,  'Color', 'b', 'LineStyle', 'none')
% %xlabel('Mean Eccentricity');
% %ylabel('Kappa');
% %title(regexp(inDirectory, '[\d]*', 'match'));
% 
% concRetraction = sum(count.*coefEsts)/sum(count);
% concRetraction = coefEsts;
% [markerColor, marker, markerSize] = findColor(inDirectory);
% hold off
% hold on
% plot(concRetraction, concProtrusion, 'Marker', marker, 'MarkerSize', markerSize, 'Color', markerColor);
% hold on
% score = concProtrusion-concRetraction; 

% plot the differance between protrusions and inverted retractions
figure; 
colors = colormap(hsv(numBins));
for b=1:numBins
    plot(shapeMean.protrusionFront(numBins-b+1,:)*convertAreaPerTime-fliplr(-1*shapeMean.retractionFront(numBins-b+1,:)*convertAreaPerTime), 'LineWidth', 2, 'Color', colors(numBins-b+1,:))
    hold on  
end
grid on
colorbar;
%title(['Protrusive - retractive motion as a function of eccentricity rank ']);
title([regexp(inDirectory, '[\d]*', 'match')]);
xlabel('boundary position (a.u.)');
ylabel('local motion dif (square micrometers/minute)')


% figure
% %for r=1:proToFitRows
%     plot(meanEccs,1./sqrt(coefEsts), 'Marker', '.', 'MarkerSize', 20)
%     hold on

% plot area versus eccentricity
figure
for s=1:length(shape)
    plot(mean(shape(s).area*convertArea), mean(shape(s).eccentricity), 'Marker','.', 'MarkerSize', 7, 'LineStyle', 'none');
    hold on
end
hold off

% find the color and marker type of the run
function [markerColor, marker, markerSize] = findColor(inDirectory)
directory = regexp(inDirectory, '[0-9_]*', 'match');

% associate directories with types and lineSep
switch char(directory)
    case '090818'
        type = 'ax3';
        lineSep = NaN;
    case '090819'
        type = 'ax3';
        lineSep = NaN;
    case '091111_2'
        type = 'ax3';
        lineSep = NaN;
    case '091111_3'
        type = 'ax3';
        lineSep = NaN;
    case '100120_2'
        type = 'ax3';
        lineSep = NaN;  
    case '100120_3'
        type = 'ax3';
        lineSep = NaN;
    
    case '110316'
        type = 'aca-';
        lineSep = NaN;
    case '120430'
        type = 'aca-';
        lineSep = NaN;
    case '101025'
        type = 'aca-';
        lineSep = NaN;
    case '120508'
        type = 'aca-';
        lineSep = NaN;
        
    case '101020'
        type = 'ridge';
        lineSep = 0.4;
    case '101024'
        type = 'ridge';
        lineSep = 0.4;
    case '110317'
        type = 'ridge';
        lineSep = 0.6;
    case '110926'
        type = 'ridge';
        lineSep = 0.6;
    case '110210'
        type = 'ridge';
        lineSep = 0.8;
    case '110421'
        type = 'ridge';
        lineSep = 0.8;
    case '120512_1'
        type = 'ridge';
        lineSep = 1;
    case '120517_2'
        type = 'ridge';
        lineSep = 1;
    case '120423'
        type = 'ridge';
        lineSep = 1.2;
    case '120512_2'
        type = 'ridge';
        lineSep = 1.2;
    case '120517_3'
        type = 'ridge';
        lineSep = 1.2;
    case '120424'
        type = 'ridge';
        lineSep = 1.5;
    case '120520_2'
        type = 'ridge';
        lineSep = 1.5;
    case '110318'
        type = 'ridge';
        lineSep = 2;
    case '110419'
        type = 'ridge';
        lineSep = 2;
    case '120504'
        type = 'ridge';
        lineSep = 3;
    case '120509'
        type = 'ridge';
        lineSep = 3;
    case '120510'
        type = 'ridge';
        lineSep = 3;
    case '120517_1'
        type = 'ridge';
        lineSep = 5;
    case '120520_1'
        type = 'ridge';
        lineSep = 5;
    case '110630'
        type = 'ridge';
        lineSep = 10;
    case '110721'
        type = 'ridge';
        lineSep = 10;
    case '110805'
        type = 'ridge';
        lineSep = 10;
        
    case '110601'
        type = 'myoII-';
        lineSep = NaN;         
end

% find the marker type
if strfind(type, 'ax3')
    marker = 's';
    markerSize = 10;
elseif strfind(type, 'aca-')
    marker = 'o';
    markerSize = 10;
elseif strfind(type, 'ridge')
    marker = '.';
    markerSize = 20;
elseif strfind(type, 'myoII-')
    marker = '*';
    markerSize = 12;
end

% find the markerColor
markerColor = 'k';
if strfind(type, 'ridge')
    lineSeperations=[0.4, 0.6, 0.8, 1, 1.2, 1.5, 2, 3, 5, 10];
    colors = colormap(sqrt(hsv(10)));
    colorIndex = find(lineSep==lineSeperations);
    markerColor = colors(colorIndex,:);
end

        
        

