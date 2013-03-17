%%%%%%%% PLOT ACCUMULATED MOTION DM %%%%%%%%

function plotAccumMotionDM(motionA, accumParams)
motionA.eccCount
% notmalize protrusions and retractions
for b=1:accumParams.numBinsEcc
    protrusionFront(b,:) = motionA.protrusionEccSum(b,:)/motionA.eccCount(b);
    retractionFront(b,:) = motionA.retractionEccSum(b,:)/motionA.eccCount(b);
end

% plot protrusions and retractions
figure; 
colors = colormap(hsv(accumParams.numBinsEcc)); 
for b=1:accumParams.numBinsEcc
    plot(mean(protrusionFront(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))
    hold on
    plot(mean(retractionFront(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))   
end
colorbar;
title('Protrusive and retractive motion as a function of eccentricity rank');
xlabel('boundary position (a.u.)');
ylabel('local motion (square micrometers/minute)')

% plot protrusions and inverted retractions
figure; 
colors = colormap(hsv(accumParams.numBinsEcc));
for b=1:accumParams.numBinsEcc
    plot(mean(protrusionFront(accumParams.numBinsEcc-b+1,:,:),3), 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))
    hold on
    plot(fliplr(-1*mean(retractionFront(accumParams.numBinsEcc-b+1,:,:),3)), 'LineStyle', '--', 'LineWidth', 2, 'Color', colors(accumParams.numBinsEcc-b+1,:))   
end
colorbar;
title('Protrusive and retractive motion as a function of eccentricity rank');
xlabel('boundary position (a.u.)');
ylabel('local motion (square micrometers/minute)')