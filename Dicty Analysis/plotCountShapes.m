%%%%%%%%%%%%%%%% PLOT COUNT SHAPES %%%%%%%%%%%%%%%%
%
% Plot the distribution of track lengths and display the total number of
% shapes and tracks.
%
% Inputs:
%  motionA          - 


function plotCountShapes(motionA)

% plot the track length distributions
trackLengthIndex=1:1:1500;
figure
plot(trackLengthIndex, motionA.trackCounts, 'LineWidth', 1.5)
title('Distribution of Track Lengths')
xlabel('Track Lengths')
ylabel('Count')

figure
plot(trackLengthIndex, fliplr(cumsum(fliplr(motionA.trackCounts)/sum(fliplr(motionA.trackCounts)))), 'LineWidth', 1.5);
title('Cumulative Distribution of Track Lengths')
xlabel('Track Lengths')
ylabel('Cumulative Count')

% display the number of tracks and shapes
display(['    There are ' num2str(sum(motionA.trackCounts)) ' tracks and ' num2str(sum(trackLengthIndex.*motionA.trackCounts)) ' shapes.']);