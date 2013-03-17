%%%%%%%% PCA MOTION %%%%%%%%
% plots the pca of motion

function plotPCAMotion(pcaMotion)

% plot the pca components
figure
imagesc(pcaMotion.zscores(:,1:50))
colorbar;
xlabel('Principal Component Index')
ylabel('Boundary Position (a.u.) (0-front; 100-back)')
title('Principal Components of Motion')

% plot the first four components 
figure
plot(pcaMotion.zscores(:,1), 'LineWidth', 2, 'Color', 'r');
hold on
plot(pcaMotion.zscores(:,2), 'LineWidth', 2, 'Color', 'g');
plot(pcaMotion.zscores(:,3), 'LineWidth', 2, 'Color', 'b');
plot(pcaMotion.zscores(:,4), 'LineWidth', 2, 'Color', 'm');
legend(' 1', ' 2', ' 3', ' 4');
xlabel('Boundary Position (a.u.)')
ylabel('Value (a.u.)');
title('The first four principal components of motion')

% plot the eigenvalue spectrum
figure
index = 1:1:50;
loglog(index, pcaMotion.latent(1:50), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Principal Component Index')
ylabel('Eigenvalue')
title('Motion Eigenvalue Spectrum');

% fit the eigenvalue spectrum
figure
plot(log(1:1:50), log(pcaMotion.latent(1:50)), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)

% % fit the eigenvalue spectrum
% spectrumFit = @(p, x) p(1).*x'.^(p(2));
% spectrumFitStart = [100000, -2];
% coefEsts = nlinfit(index, pcaMotion.latent(1:50), spectrumFit, spectrumFitStart);
% coefEsts(1,2)
% hold on
% line(index, spectrumFit(coefEsts, index), 'LineWidth', 1.5, 'Color','r');
% title(['Motion Eigenvalue Spectrum with Alpha  ' num2str(coefEsts(1,2))]);

% plot the number of principal components needed
figure
plot(cumsum(100*pcaMotion.latent(1:50)/sum(pcaMotion.latent(1:50))), 'LineWidth', 2, 'Color', 'b', 'Marker', '.', 'MarkerSize', 20)
xlabel('Number of Principal Components')
ylabel('Percentage Variance Represented')
title('Number of Principal Components Needed')
axis([0 50 0 100])