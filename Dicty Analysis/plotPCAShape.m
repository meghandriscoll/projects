%%%%%%%% PCA SHAPE %%%%%%%%
% plots the pca of shape

function plotPCAShape(M,pca,pcaShape)

% plot the pca components
figure
imagesc(pcaShape.zscores(:,1:50))
colorbar;
xlabel('Principal Component Index')
ylabel('Boundary Position (a.u.) (0-front; 100-back)')
title('Principal Components of Shape')

% plot the first four components 
figure
plot(pcaShape.zscores(:,1), 'LineWidth', 2, 'Color', 'r');
hold on
plot(pcaShape.zscores(:,2), 'LineWidth', 2, 'Color', 'g');
plot(pcaShape.zscores(:,3), 'LineWidth', 2, 'Color', 'b');
plot(pcaShape.zscores(:,4), 'LineWidth', 2, 'Color', 'm');
legend(' 1', ' 2', ' 3', ' 4');
xlabel('Boundary Position (a.u.)')
ylabel('Value (a.u.)');
title('The first four principal components of shape')

% plot the eigenvalue spectrum
figure
index = 1:1:50;
loglog(index, pcaShape.latent(1:50), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('Shape Eigenvalue Spectrum');

% fit the eigenvalue spectrum
figure
logIndex = log(1:1:50);
logShape = log(pcaShape.latent(1:50));
plot(logIndex, logShape, 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)

% % fit the eigenvalue spectrum
% spectrumFit = @(p, x) p(1).*x'.^(p(2));
% spectrumFitStart = [1000000, -3];
% spectrumFitLog = @(p, x) log(p(1))-p(2).*log(x');
% coefEsts = nlinfit(index, log(pcaShape.latent(1:50)), @(p, x)log(spectrumFit(p,x)), spectrumFitStart);
% coefEsts(1,1)
% coefEsts(1,2)
% hold on
% line(index, spectrumFit(coefEsts, index), 'LineWidth', 1.5, 'Color','r');
% title(['Shape Eigenvalue Spectrum with Alpha  ' num2str(coefEsts(1,2))]);

% plot the number of principal components needed
figure
plot(cumsum(100*pcaShape.latent(1:50)/sum(pcaShape.latent(1:50))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed')
axis([0 50 0 100])


% plot the loadings for a single shape
aCell = pca(1).shape(:,1:M-1)*pcaShape.zscores;

figure
imagesc(aCell)

figure
plot(aCell(:,1), 'r')
hold on
plot(aCell(:,2), 'g')
plot(aCell(:,3), 'b')

% plot the loadings for all the cells
allCells = pcaShape.toPCA*pcaShape.zscores;

figure
imagesc(allCells)