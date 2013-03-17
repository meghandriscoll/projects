%%%%%%%% PLOT ACCUMULATED MOTION %%%%%%%%

function plotAccumMotion(motionA, accumParams)

% find the number of movies averaged over
[rows, cols, numRuns] = size(motionA.protrusionEcc);

% plot protrusions and retractions
figure; 
colors = colormap(hsv(accumParams.numBinsEcc)); 
for b=1:accumParams.numBinsEcc
    plot(mean(motionA.protrusionEcc(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))
    hold on
    plot(mean(motionA.retractionEcc(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))   
end
colorbar;
title('Protrusive and retractive motion as a function of eccentricity rank');
xlabel('boundary position (a.u.)');
ylabel('local motion (square micrometers/minute)')

% plot protrusions and retractions with error bars
figure; 
colors = colormap(hsv(accumParams.numBinsEcc)); 
for b=1:accumParams.numBinsEcc
    plot(mean(motionA.protrusionEcc(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))
    errorToPlot = std(motionA.protrusionEcc(accumParams.numBinsEcc-b+1,:,:),0,3)/sqrt(numRuns);
    errorbar(mean(motionA.protrusionEcc(accumParams.numBinsEcc-b+1,:,:),3), errorToPlot, 'LineWidth', 1, 'Color', colors(accumParams.numBinsEcc-b+1,:));
    hold on
    plot(mean(motionA.retractionEcc(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))   
    errorToPlot = std(motionA.retractionEcc(accumParams.numBinsEcc-b+1,:,:),0,3)/sqrt(numRuns);
    errorbar(mean(motionA.retractionEcc(accumParams.numBinsEcc-b+1,:,:),3), errorToPlot, 'LineWidth', 1, 'Color', colors(accumParams.numBinsEcc-b+1,:));
end
colorbar;
title('Protrusive and retractive motion as a function of eccentricity rank');
xlabel('boundary position (a.u.)');
ylabel('local motion (square micrometers/minute)')

% plot protrusions and inverted retractions
figure; 
colors = colormap(hsv(accumParams.numBinsEcc));
for b=1:accumParams.numBinsEcc
    plot(mean(motionA.protrusionEcc(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))
    hold on
    plot(fliplr(-1*mean(motionA.retractionEcc(accumParams.numBinsEcc-b+1,:,:),3)), 'LineStyle', '--', 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))   
end
colorbar;
title('Protrusive and retractive motion as a function of eccentricity rank');
xlabel('boundary position (a.u.)');
ylabel('local motion (square micrometers/minute)')