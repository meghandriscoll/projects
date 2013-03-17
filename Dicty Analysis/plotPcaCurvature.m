%%%%%%%% PCA CURVATURE %%%%%%%%
% plots the pca of curvature

function plotPCACurvature(M,pca,pcaCurvature)

% plot the pca components
figure
imagesc(pcaCurvature.zscores(:,1:50))
colorbar;
xlabel('Principal Component Index')
ylabel('Boundary Position (a.u.) (0-front; 100-back)')
title('Principal Components of Curvature')

% plot the first four components 
figure
plot(pcaCurvature.zscores(:,1), 'LineWidth', 2, 'Color', 'r');
hold on
plot(pcaCurvature.zscores(:,2), 'LineWidth', 2, 'Color', 'g');
plot(pcaCurvature.zscores(:,3), 'LineWidth', 2, 'Color', 'b');
plot(pcaCurvature.zscores(:,4), 'LineWidth', 2, 'Color', 'm');
legend(' 1', ' 2', ' 3', ' 4');
xlabel('Boundary Position (a.u.)')
ylabel('Value (a.u.)');
title('The first four principal components of curvature')

% plot the eigenvalue spectrum
figure
index= 1:1:50;
loglog(index, pcaCurvature.latent(1:50), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('Curvature Eigenvalue Spectrum');

% % fit the eigenvalue spectrum
% figure
% index = 2:1:29;
% plot(index, pcaCurvature.latent(2:29), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
% hold on
% spectrumFit = @(p, x) p(1).*exp(x'.*(1./p(2)));
% spectrumFitStart = [100, -10];
% coefEsts = lsqcurvefit(spectrumFit, spectrumFitStart, index, pcaCurvature.latent(2:29));
% coefEsts
% hold on
% line(index, spectrumFit(coefEsts, index), 'LineWidth', 1.5, 'Color','r');
% plot(index, pcaCurvature.latent(2:29), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)

% plot the number of principal components needed
figure
plot(cumsum(100*pcaCurvature.latent(1:50)/sum(pcaCurvature.latent(1:50))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed')
axis([0 50 0 100])

% find the loadings for all cells
allCells = pcaCurvature.toPCA*pcaCurvature.zscores;

figure
plot(allCells(:,3),allCells(:,4), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 5)
axis equal

figure
imagesc(cov(zscore(allCells(:,1:20)))-eye(20))


