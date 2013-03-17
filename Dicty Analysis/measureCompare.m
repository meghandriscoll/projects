%%%%%%%% MEASURE COMPARE %%%%%%%%
% compare the values of meaures inside and outside the ROI
function measureCompare(meanOnLine, frameTime, pixelsmm)

% unit conversions
convertArea = (1000/pixelsmm)^2; 
convertSpeed = (1000/pixelsmm)/(frameTime/60); 

figure;
title('Compare measures inside and outside the ROI')

% plot speed
subplot(2,2,1)
toPlot = [meanOnLine.inSpeed*convertSpeed, meanOnLine.outSpeed*convertSpeed];
toPlotError = [meanOnLine.inSpeedError*convertSpeed, meanOnLine.outSpeedError*convertSpeed];
%bar(toPlot, 'k')
hold on
errorbar(toPlot,toPlotError, 'LineStyle', ':', 'LineWidth', 2, 'Color', 'r', 'Marker', '+', 'MarkerSize', 10)
title('Speed')
ylabel('Speed (micrometers/minute)')
xlabel('Inside ROI  -  Outside ROI')

% plot eccentricity
subplot(2,2,2)
toPlot = [meanOnLine.inEcc, meanOnLine.outEcc];
toPlotError = [meanOnLine.inEccError, meanOnLine.outEccError];
%bar(toPlot, 'k')
hold on
errorbar(toPlot,toPlotError, 'LineStyle', ':', 'LineWidth', 2, 'Color', 'r', 'Marker', '+', 'MarkerSize', 10)
title('Eccentricity')
ylabel('Eccentricity')
xlabel('Inside ROI  -  Outside ROI')

% plot area
subplot(2,2,3)
toPlot = [meanOnLine.inArea*convertArea, meanOnLine.outArea*convertArea];
toPlotError = [meanOnLine.inAreaError*convertArea, meanOnLine.outAreaError*convertArea];
%bar(toPlot, 'k')
hold on
errorbar(toPlot,toPlotError, 'LineStyle', ':', 'LineWidth', 2, 'Color', 'r', 'Marker', '+', 'MarkerSize', 10)
title('Area')
ylabel('Area (square micrometers)')
xlabel('Inside ROI  -  Outside ROI')

% plot solidity
subplot(2,2,4)
toPlot = [meanOnLine.inSolidity, meanOnLine.outSolidity];
toPlotError = [meanOnLine.inSolidityError, meanOnLine.outSolidityError];
%bar(toPlot, 'k')
hold on
errorbar(toPlot,toPlotError, 'LineStyle', ':', 'LineWidth', 2, 'Color', 'r', 'Marker', '+', 'MarkerSize', 10)
title('Solidity')
ylabel('Solidity')
xlabel('Inside ROI  -  Outside ROI')

