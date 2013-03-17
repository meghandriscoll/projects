%%%%%%%%%%%%%%%% PLOT DISTRIBUTIONS %%%%%%%%%%%%%%%%

% 

% Inputs:             
%  N                - the number of images
%  picture          - an output of findConvexHull.m
%  shape
%  patients
%  drugs
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images in 'savePath'

function plotDistributions(N, picture, shape, intensityData, patients, drugs, savePath, inDirectory)

% iterate through the images
area = cell(length(patients), length(drugs));
perimeter = cell(length(patients), length(drugs));
ratio = cell(length(patients), length(drugs));
curvature = cell(length(patients), length(drugs));
negCurvature = cell(length(patients), length(drugs));
tort = cell(length(patients), length(drugs));
eccentricity = cell(length(patients), length(drugs));
equivDiameter = cell(length(patients), length(drugs));
majorAxisLength = cell(length(patients), length(drugs));
minorAxisLength = cell(length(patients), length(drugs));
meanIntensity = cell(length(patients), length(drugs));
stdIntensity = cell(length(patients), length(drugs));
intensity = cell(length(patients), length(drugs));
intensityBP = cell(length(patients), length(drugs));
intensityBPa = cell(length(patients), length(drugs));
numTroughs = cell(length(patients), length(drugs));

for i=1:N
        
    % determine the patient and drug
    row = find(patients==picture(i).patient);
    col = find(strcmp(picture(i).drug, drugs));
    
    % iterate through the nuclei
    for r = 1:length(shape(i).nuclei)
        
        % put data in bins
        area{row, col} = [area{row, col}, shape(i).nuclei(r).area];
        perimeter{row, col} = [perimeter{row, col}, shape(i).nuclei(r).perimeter];
        ratio{row, col} = [ratio{row, col}, shape(i).nuclei(r).ratio];
        curvature{row, col} = [curvature{row, col}, shape(i).nuclei(r).uncutCurvatureDist];
        negCurvature{row, col} = [negCurvature{row, col}, shape(i).nuclei(r).sumNegCurvatureDist/length(shape(i).nuclei(r).curvatureDist)];
        tort{row, col} = [tort{row, col}, shape(i).nuclei(r).tort];   
        eccentricity{row, col} = [eccentricity{row, col}, shape(i).nuclei(r).eccentricity];
        equivDiameter{row, col} = [equivDiameter{row, col}, shape(i).nuclei(r).equivDiameter];
        majorAxisLength{row, col} = [majorAxisLength{row, col}, shape(i).nuclei(r).majorAxisLength];
        minorAxisLength{row, col} = [minorAxisLength{row, col}, shape(i).nuclei(r).minorAxisLength];
        meanIntensity{row, col} = [meanIntensity{row, col}, shape(i).nuclei(r).meanIntensity*255];
        stdIntensity{row, col} = [stdIntensity{row, col}, shape(i).nuclei(r).stdIntensity*255];
        intensity{row, col} = [intensity{row, col}, shape(i).nuclei(r).intensityValues'*255];
%        intensityBP{row, col} = [intensityBP{row, col}, intensityData(i).nuclei(r).mean];
%        intensityBPa{row, col} = [intensityBPa{row, col}, (intensityData(i).nuclei(r).mean/255-shape(i).nuclei(r).meanIntensity)/shape(i).nuclei(r).stdIntensity];
        numTroughs{row, col} = [numTroughs{row, col}, shape(i).nuclei(r).numTroughs];
    end
end

% make plots
plotMeasureDist(area, 'Area', '(square pixels)', 12, patients, drugs, savePath)
plotMeasureDist(perimeter, 'Perimeter', '(pixels)', 12, patients, drugs, savePath)
% plotMeasureDist(ratio, 'Non-circularity', '', 16, patients, drugs, savePath)
% plotMeasureDist(curvature, 'Curvature', '', 130, patients, drugs, savePath)
% plotMeasureDist(negCurvature, 'Mean Negative Curvature', '', 12, patients, drugs, savePath)
plotMeasureDist(tort, 'Tortuosity', '', 15, patients, drugs, savePath)
% plotMeasureDist(eccentricity, 'Eccentricity', '', 8, patients, drugs, savePath)
% plotMeasureDist(equivDiameter, 'Mean Radius', '(pixels)', 12, patients, drugs, savePath)
% plotMeasureDist(majorAxisLength, 'Major Axis Length', '(pixels)', 12, patients, drugs, savePath)
% plotMeasureDist(mainorAxisLength, 'Minor Axis Length', '(pixels)', 12, patients, drugs, savePath)
%plotMeasureDist(meanIntensity, 'Mean Pixel Value', '', 16, patients, drugs, savePath)
%plotMeasureDist(stdIntensity, 'Standard Deviation of Intensity', '', 18, patients, drugs, savePath)
%plotMeasureDist(intensityBP, 'Intensity Near Boundary Points', '', 40, patients, drugs, savePath)
%plotMeasureDist(intensityBPa, 'Adjusted Intensity Near Boundary Points', '', 20, patients, drugs, savePath)

minValue = Inf; maxValue = -Inf;
for row = 1:length(patients)
    for col = 1:length(drugs)
        minValue = min([minValue, intensity{row,col}]);
        maxValue = max([maxValue, intensity{row,col}]);
    end
end
%plotMeasureDist(intensity, 'Pixel Value', '', maxValue-minValue, patients, drugs, savePath)

maxValue = -Inf;
numTroughsMean = zeros(length(patients), length(drugs));
numTroughsSTD = zeros(length(patients), length(drugs));
numTroughsSE = zeros(length(patients), length(drugs));
negCurvatureMean = zeros(length(patients), length(drugs));
negCurvatureSTD = zeros(length(patients), length(drugs));
negCurvatureSE = zeros(length(patients), length(drugs));
tortMean = zeros(length(patients), length(drugs));
tortSTD = zeros(length(patients), length(drugs));
tortSE = zeros(length(patients), length(drugs));
for row = 1:length(patients)
    for col = 1:length(drugs)
        maxValue = max([maxValue, numTroughs{row,col}]);
        numTroughsMean(row, col) = mean(numTroughs{row,col});
        numTroughsSTD(row, col) = std(numTroughs{row,col});
        numTroughsSE(row, col) = std(numTroughs{row,col})/sqrt(length(numTroughs{row,col}));
        negCurvatureMean(row, col) = mean(negCurvature{row,col});
        negCurvatureSTD(row, col) = std(negCurvature{row,col});
        negCurvatureSE(row, col) = std(negCurvature{row,col})/sqrt(length(negCurvature{row,col}));
        tortMean(row, col) = mean(tort{row,col});
        tortSTD(row, col) = std(tort{row,col});
        tortSE(row, col) = std(tort{row,col})/sqrt(length(tort{row,col}));
    end
end
plotMeasureDist(numTroughs, 'Number of Invaginations', '', maxValue, patients, drugs, savePath)
% numTroughsMean
% numTroughsSTD
% numTroughsSE
% negCurvatureMean*1000
% negCurvatureSTD*1000
% negCurvatureSE*1000
% tortMean*1000
% tortSTD*1000
% tortSE*1000

%%%%%%% Plot One Measure %%%%%
function plotMeasureDist(measureBins, measureName, measureUnit, numBins, patients, drugs, savePath)

% find the minimum and maximum values of the measure
minValue = Inf; maxValue = -Inf;
for row = 1:length(patients)
    for col = 1:length(drugs)
        minValue = min([minValue, measureBins{row,col}]);
        maxValue = max([maxValue, measureBins{row,col}]);
    end
end

range = maxValue-minValue;
edges = minValue:(range/numBins):maxValue;
%mids = (minValue+range/(2*numBins)):(range/numBins):(maxValue-range/(2*numBins));
mids = (minValue):(range/numBins):(maxValue-range/numBins);

% iterate through the patients
fig=figure;
for row = 1:length(patients)
    
    % iterate through the drugs
    colors = colormap(hsv(length(drugs)));
    numNuclei = 0;
    subplot(3,1,row);
    for col = 1:length(drugs)
        n = histc(measureBins{row,col},edges);
        n = n./length(measureBins{row,col});
        numNuclei = numNuclei + length(measureBins{row,col});
        plot(mids, n(1:numBins), 'LineWidth', 1.5, 'Color',colors(col,:), 'Marker', '.', 'MarkerSize', 15)
        axis([minValue maxValue 0 1])
        hold on
    end
    hold off
    
    % title the figure
    title([measureName ' (Patient ' num2str(patients(row)) ', ' num2str(numNuclei) ' total points)']);
    xlabel([measureName ' ' measureUnit]);
    ylabel('Percentage');
    legend(drugs)
end
