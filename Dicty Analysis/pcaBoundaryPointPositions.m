%%%%%%%% PCA BOUNDARY POINT POSITIONS %%%%%%%%
% plots the pca of the boundary point positions

function pcaBoundaryPointPositions(M, pca, pcaAll)

% plot the eigenvalue spectrum
figure
index= 1:1:50;
loglog(index, pcaAll.latentBpp(1:50), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('BPP Eigenvalue Spectrum');
% figure
% plot(log(1:1:50), log(pcaAll.latentBpp(1:50)), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
% xlabel('Principal Component Index')
% ylabel('Eigenvalue')
% title('BPP Eigenvalue Spectrum');

% plot the number of principal components needed
figure
plot(cumsum(100*pcaAll.latentBpp(1:50)/sum(pcaAll.latentBpp(1:50))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed')
axis([0 50 0 100])

% find the loadings for all of the shapes
allCells = pcaAll.toPCAbpp*pcaAll.zscoresBpp;

% find the mean shape
[rows, cols] = size(pcaAll.zscoresBpp);
meanShapeRow = sum(repmat(mean(allCells,1), rows,1).*pcaAll.zscoresBpp,2);
meanShape = [meanShapeRow(1:M-1), meanShapeRow(M:end)];
% figure
% plot(meanShape(:,1), meanShape(:,2))
% axis equal

% find the standard deviations of each of the modes
stdShapes  = std(allCells,0,1);

% plot the mean and standard deviations for the first nine mode
figure
title('Principal Components of Boundary Shape')
for f=1:6
    subplot(3,2,f)
    plot(meanShape(:,1), meanShape(:,2), 'LineWidth', 3, 'Color', 'k')
    hold on
    toPlot = 0.1*mean(mean(abs(meanShape)))*pcaAll.zscoresBpp(:,f)/mean(abs(pcaAll.zscoresBpp(:,f)));
    plot(meanShape(:,1) + toPlot(1:M-1), meanShape(:,2) + toPlot(M:end), 'LineWidth', 3, 'Color', [0,0,0.6])
    plot(meanShape(:,1) + 2*toPlot(1:M-1), meanShape(:,2) + 2*toPlot(M:end), 'LineWidth', 3, 'Color', [0.1,0.1,1])
    plot(meanShape(:,1) - toPlot(1:M-1), meanShape(:,2) - toPlot(M:end), 'LineWidth', 3, 'Color', [0.6,0,0])
    plot(meanShape(:,1) - 2*toPlot(1:M-1), meanShape(:,2) - 2*toPlot(M:end), 'LineWidth', 3, 'Color', [1,0.1,0.1])
    %v = axis;
    %axis(v*1.02)
    axis equal
    axis off
    title(num2str(f), 'FontSize', 20)
end


%%%%%%% DEBUG CODE %%%%%%%%%%

% % plot the first principal component
% figure
% x1 = [pcaAll.zscoresBpp(1:M-1,1); pcaAll.zscoresBpp(1,1)];
% y1 = [pcaAll.zscoresBpp(M:end,1); pcaAll.zscoresBpp(M,1)];
% plot(x1, y1, 'LineWidth', 2, 'Color', 'k');
% hold on
% plot(pcaAll.zscoresBpp(1,1), pcaAll.zscoresBpp(M,1), 'Marker', '.', 'MarkerSize', 20, 'Color', 'b');
% axis equal
% title('First Principal Component')
% 
% % plot the second principal component
% figure
% x2 = [pcaAll.zscoresBpp(1:M-1,2); pcaAll.zscoresBpp(1,2)];
% y2 = [pcaAll.zscoresBpp(M:end,2); pcaAll.zscoresBpp(M,2)];
% plot(x1, y1, 'LineWidth', 2, 'Color', 'k');
% hold on
% plot(x1+x2, y1+y2, 'LineWidth', 2, 'Color', 'r');
% axis equal
% title('Second Principal Component')
% 
% % plot the third principal component
% figure
% x3 = [pcaAll.zscoresBpp(1:M-1,3); pcaAll.zscoresBpp(1,3)];
% y3 = [pcaAll.zscoresBpp(M:end,3); pcaAll.zscoresBpp(M,3)];
% plot(x1, y1, 'LineWidth', 2, 'Color', 'k');
% hold on
% plot(x1+x3, y1+y3, 'LineWidth', 2, 'Color', 'r');
% axis equal
% title('Third Principal Component')
% 
% % plot the fourth principal component
% figure
% x4 = [pcaAll.zscoresBpp(1:M-1,4); pcaAll.zscoresBpp(1,4)];
% y4 = [pcaAll.zscoresBpp(M:end,4); pcaAll.zscoresBpp(M,4)];
% plot(x1, y1, 'LineWidth', 2, 'Color', 'k');
% hold on
% plot(x1+x4, y1+y4, 'LineWidth', 2, 'Color', 'r');
% axis equal
% title('Fourth Principal Component')
% 
% % plot the fifth principal component
% figure
% x5 = [pcaAll.zscoresBpp(1:M-1,5); pcaAll.zscoresBpp(1,5)];
% y5 = [pcaAll.zscoresBpp(M:end,5); pcaAll.zscoresBpp(M,5)];
% plot(x1, y1, 'LineWidth', 2, 'Color', 'k');
% hold on
% plot(x1+x5, y1+y5, 'LineWidth', 2, 'Color', 'r');
% axis equal
% title('Fifth Principal Component')