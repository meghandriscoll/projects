%%%%%%%%%%%%%%%% MEASURE AUTO-CORRELATIONS %%%%%%%%%%%%%%%%
%
% Measure the auto-correlations of various measures
%
% Inputs:
%  frameDelta         - the number of frames over which motion is measured
%
% Saves:
%  shape
%   .areaCorr         - 

function measureAutoCorrs(shape, minDurationAutoCorr, frameDelta)

% initialize variables
autoCorrArea = zeros(1,minDurationAutoCorr+1); countArea = 0; autoCorrDataArea = []; tauListArea = [];
autoCorrPerimeter = zeros(1,minDurationAutoCorr+1); countPerimeter = 0; autoCorrDataPerimeter = []; tauListPerimeter = [];
autoCorrEcc = zeros(1,minDurationAutoCorr+1); countEcc = 0; autoCorrDataEcc = []; tauListEcc = [];
autoCorrSolidity = zeros(1,minDurationAutoCorr+1); countSolidity = 0; autoCorrDataSolidity = []; tauListSolidity = [];
autoCorrMNC = zeros(1,minDurationAutoCorr+1); countMNC = 0; autoCorrDataMNC = []; tauListMNC = [];
autoCorrLSD = zeros(1,minDurationAutoCorr+1); countLSD = 0; autoCorrDataLSD = []; tauListLSD = [];

% iterate through the shapes
for s=1:1:length(shape)
    
    if mod(s, 10) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % auto-correlations
    if shape(s).duration>=(minDurationAutoCorr+frameDelta)
        
        % determine a random range of length minDurationAutoCorr
        startIndex = floor(rand(1,1)*(shape(s).duration-minDurationAutoCorr-1))+1;
        endIndex = startIndex + minDurationAutoCorr;
        [autoCorrArea, countArea, autoCorrDataArea, tauListArea] = updateAutoCorr(shape(s).area(startIndex:endIndex), autoCorrArea, countArea, autoCorrDataArea, tauListArea);
        [autoCorrPerimeter, countPerimeter, autoCorrDataPerimeter, tauListPerimeter] = updateAutoCorr(shape(s).perimeter(startIndex:endIndex), autoCorrPerimeter, countPerimeter, autoCorrDataPerimeter, tauListPerimeter);
        [autoCorrEcc, countEcc, autoCorrDataEcc, tauListEcc] = updateAutoCorr(shape(s).eccentricity(startIndex:endIndex), autoCorrEcc, countEcc, autoCorrDataEcc, tauListEcc);
        [autoCorrSolidity, countSolidity, autoCorrDataSolidity, tauListSolidity] = updateAutoCorr(shape(s).solidity(startIndex:endIndex), autoCorrSolidity, countSolidity, autoCorrDataSolidity, tauListSolidity);
        [autoCorrMNC, countMNC, autoCorrDataMNC, tauListMNC] = updateAutoCorr(shape(s).meanNegCurvature(startIndex:endIndex), autoCorrMNC, countMNC, autoCorrDataMNC, tauListMNC);
        %[autoCorrLSD, countLSD, autoCorrDataLSD, tauListLSD] = updateAutoCorr(sum(abs(shape(s).leastSquares(startIndex:endIndex,:)),2)', autoCorrLSD, countLSD, autoCorrDataLSD, tauListLSD);
    end
    
end

% normalize auto-correlations
autoCorrArea = autoCorrArea./countArea;
autoCorrPerimeter = autoCorrPerimeter./countPerimeter;
autoCorrEcc = autoCorrEcc./countEcc;
autoCorrSolidity = autoCorrSolidity./countSolidity;
autoCorrMNC = autoCorrMNC./countMNC;
%autoCorrLSD = autoCorrLSD./countLSD;

% plot the area auto-correlation
figure
time = 0:4:4*minDurationAutoCorr;
plot(time, autoCorrArea, 'Color', 'r', 'LineWidth', 2);
hold on
%errorbar(1:minDurationAutoCorr+1, autoCorrArea, std(autoCorrDataArea,1)/sqrt(39), 'Color', 'r');
plot(time, autoCorrPerimeter, 'Color', 'y', 'LineWidth', 2);
plot(time, autoCorrEcc, 'Color', 'g', 'LineWidth', 2);
plot(time, autoCorrSolidity, 'Color', 'b', 'LineWidth', 2);
plot(time, autoCorrMNC, 'Color', 'm', 'LineWidth', 2);
%plot(time, autoCorrLSD, 'Color', 'c', 'LineWidth', 2);
xlabel('Time Dif (sec)')
ylabel('Auto Cor')
title(['Total number of tracks: ' num2str(countArea)])
hold off

disp(['Area Mean ' num2str(mean(tauListArea*4)) '; Error: ' num2str(std(tauListArea*4)/sqrt(countArea))])
disp(['Perimeter Mean ' num2str(mean(tauListPerimeter*4)) '; Error: ' num2str(std(tauListPerimeter*4)/sqrt(countPerimeter))])
disp(['Eccentricity Mean ' num2str(mean(tauListEcc*4)) '; Error: ' num2str(std(tauListEcc*4)/sqrt(countEcc))])
disp(['Solidity Mean ' num2str(mean(tauListSolidity*4)) '; Error: ' num2str(std(tauListSolidity*4)/sqrt(countSolidity))])
disp(['MNC Mean ' num2str(mean(tauListMNC*4)) '; Error: ' num2str(std(tauListMNC*4)/sqrt(countMNC))])
%disp(['LSD Mean ' num2str(mean(tauListLSD*4)) '; Error: ' num2str(std(tauListLSD*4)/sqrt(countLSD))])
% 
% size(autoCorrDataArea)
% figure
% plot(std(autoCorrDataArea,1))
% figure
% plot(std(autoCorrDataArea,1)/sqrt(39))

function [autoCorr, count, autoCorrData, tauList] = updateAutoCorr(series, autoCorr, count, autoCorrData, tauList)

% compute the auto-correlation and update the count
xOut = xcorr(zscore(series))/(length(series));
toAutoCorr = xOut(length(series):end);
autoCorr = autoCorr + toAutoCorr;
count = count + 1;
autoCorrData = [autoCorrData; toAutoCorr]; 

% find tau (where the auto-correlation is 1/e)
beforeIndex = find(toAutoCorr>exp(-1), 1, 'last');
afterIndex = find(toAutoCorr<exp(-1), 1, 'first');
percentageBeforeValue = 1 - (toAutoCorr(beforeIndex)-exp(-1))/(toAutoCorr(beforeIndex)-toAutoCorr(afterIndex));
tau = beforeIndex*percentageBeforeValue + afterIndex*(1-percentageBeforeValue);
tauList = [tauList, tau];


%%%%%%  streamline the code.

%%%%%% Find tau for each track, and then average
%%%%%% over the tracks.  Compare to the auto mutual information.  (When you
%%%%%% look at motion, consider how motion is smoothed across frames.)
%%%%%% Simplify the code by variables like aCorr.motion.autoCorr, then only
%%%%%% aCorr.motion has to be passsed around.  Initialization could also be
%%%%%% simplified by writing an init function.