%%%%%%%% PCA SPECTRA %%%%%%%%
% plots the eigenvalues of various principal components

function plotSpectra(pcaShape, pcaCurvature, pcaMotion, pcaLeastSquares, pcaBPP)

maxIndex = 50;

% plot the spectra
figure
index = 1:1:maxIndex;

loglog(index, pcaCurvature.latentCurvature(1:maxIndex), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
hold on
loglog(index, pcaMotion.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'c', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaShape.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'r', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaLeastSquares.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'y', 'Marker', '.', 'MarkerSize', 20)
loglog(index, pcaBpp.latent(1:maxIndex), 'LineWidth', 2, 'Color', 'm', 'Marker', '.', 'MarkerSize', 20)

legend(' Curvature (Local Shape)', ' Local Motion',  ' Global Shape', ' Global Motion',' BPP');
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('Eigenvalue Spectrums');

% plot the number of principal components needed

figure
index = 1:1:maxIndex;

loglog(index, cumsum(100*pcaCurvature.latent(1:maxIndex)/sum(pcaCurvature.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
hold on
loglog(index, cumsum(100*pcaMotion.latent(1:maxIndex)/sum(pcaMotion.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'c', 'Marker', '.', 'MarkerSize', 20)
loglog(index, cumsum(100*pcaShape.latent(1:maxIndex)/sum(pcaShape.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'r', 'Marker', '.', 'MarkerSize', 20)
loglog(index, cumsum(100*pcaLeastSquares.latent(1:maxIndex)/sum(pcaLeastSquares.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'y', 'Marker', '.', 'MarkerSize', 20)
loglog(index, cumsum(100*pcaBPP.latent(1:maxIndex)/sum(pcaBPP.latent(1:maxIndex))), 'LineWidth', 2, 'Color', 'm', 'Marker', '.', 'MarkerSize', 20)

legend(' Curvature (Local Shape)', ' Local Motion',  ' Global Shape', ' Global Motion',' BPP');
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed');