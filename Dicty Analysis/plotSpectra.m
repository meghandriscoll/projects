%%%%%%%% PCA SPECTRA %%%%%%%%
% plots the eigenvalues of various principal components

function plotSpectra(pcaShape, pcaCurvature, pcaMotion, pcaLeastSquares, pcaBPP)

maxIndex = 30;

% plot the spectra
figure
index = 1:1:maxIndex;

loglog(index, pcaBPP.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'm', 'Marker', '.', 'MarkerSize', 20)
hold on
loglog(index, pcaShape.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'r', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaMotion.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'g', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaLeastSquares.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'c', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaCurvature.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlim([1 maxIndex])

legend(' BPP', ' Global Shape', ' Local Motion',  ' Global Motion', ' Curvature');
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('Eigenvalue Spectrums');

% plot the number of principal components needed
figure
index = 1:1:maxIndex;

plot(index, cumsum(100*pcaBPP.latent(1:maxIndex)/sum(pcaBPP.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'm', 'Marker', '.', 'MarkerSize', 20)
hold on
plot(index, cumsum(100*pcaShape.latent(1:maxIndex)/sum(pcaShape.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'r', 'Marker', '.', 'MarkerSize', 20)
plot(index, cumsum(100*pcaMotion.latent(1:maxIndex)/sum(pcaMotion.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'g', 'Marker', '.', 'MarkerSize', 20)
plot(index, cumsum(100*pcaLeastSquares.latent(1:maxIndex)/sum(pcaLeastSquares.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'c', 'Marker', '.', 'MarkerSize', 20)
plot(index, cumsum(100*pcaCurvature.latent(1:maxIndex)/sum(pcaCurvature.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
axis([0 maxIndex 0 100])

legend(' BPP', ' Global Shape', ' Local Motion',  ' Global Motion', ' Curvature');
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed');