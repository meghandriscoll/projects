%%%%%%%%%%%%%%%% MEASURE PCA %%%%%%%%%%%%%%%%
%
% Find the positions of the boundary points in shape space.
%
% Inputs:
%  N                  - the number of images
%  M                  - the number of boundary points in each snake
%  frameDelta         - the number of frames over which motion is measured
%  savePath           - the directory that data is saved in
%
% Saves:
%  pca 
%   .snakeReorient    - mean subtracted, reoriented (to zero degrees) and realigned so that boundary point 1 is at zero degrees


function measurePCA(N, M, frameDelta, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% initialize variables
pcaShape.toPCA=[];
pcaCurvature.toPCA=[];
pcaMotion.toPCA=[];
pcaLeastSquares.toPCA=[];
pcaBPP.toPCA=[];

% reorient the snake for PCA
disp(['   Reorienting the snakes']);
for s=1:length(shape)
    
    % display progress
    if mod(s, 100) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
   % subtract the mean position in a frame from that frame's positions
   pca(s).snakeReorient = shape(s).snake-repmat(mean(shape(s).snake, 2), 1, M); 

    % iterate through the frames
    for f=1:shape(s).duration-frameDelta
        
        frontAngle = atan2(-1*pca(s).snakeReorient(f,shape(s).front(f),2), pca(s).snakeReorient(f,shape(s).front(f),1)); % the angle of the front
        
        % compare the angle of the front to the orientation angle
        if abs(frontAngle-shape(s).orientation(f)*(2*pi)/360) < pi/2 
            orientation = shape(s).orientation(f)*(2*pi)/360;
        else 
            orientation = shape(s).orientation(f)*(2*pi)/360 + pi;
        end
        
        % align the boundary points so that the front occurs at boundary point 1
        pca(s).snakeReorient(f,:,:) = circshift(pca(s).snakeReorient(f,:,:),[0 -1*shape(s).front(f)+1 0]); 
        
        % reorient the snake
        [snake_theta,snake_rho] = cart2pol(pca(s).snakeReorient(f,:,1),pca(s).snakeReorient(f,:,2));
        snake_theta = snake_theta+orientation; 
        [pca(s).snakeReorient(f,:,1),pca(s).snakeReorient(f,:,2)] = pol2cart(snake_theta,snake_rho);
        
        % align the measures so that the front occurs at boundary point 1
        pca(s).shape(f,:) = circshift(shape(s).distance(f,:),[0 -1*shape(s).front(f)+1]); 
        pca(s).curvature(f,:) = circshift(shape(s).uncutCurvature(f,:),[0 -1*shape(s).front(f)+1]); 
        pca(s).motion(f,:) = circshift(shape(s).motion(f,:),[0 -1*shape(s).front(f)+1]);
        pca(s).leastSquares(f,:) = circshift(shape(s).leastSquares(f,:),[0 -1*shape(s).front(f)+1]); 
        
    end 
    
     % accumulate the measures for PCA
     pcaShape.toPCA = [pcaShape.toPCA; pca(s).shape(:,1:M-1)];
     if min(min(isfinite(pca(s).curvature)))  % remove infinities
        pcaCurvature.toPCA = [pcaCurvature.toPCA; pca(s).curvature(:,1:M-1)];
     end
     pcaMotion.toPCA = [pcaMotion.toPCA; pca(s).motion(:,1:M-1)];
     pcaLeastSquares.toPCA = [pcaLeastSquares.toPCA; pca(s).leastSquares(:,1:M-1)];
     pcaBPP.toPCA = [pcaBPP.toPCA; pca(s).snakeReorient(:,1:M-1,1), pca(s).snakeReorient(:,1:M-1,2)];
    
end
pca(s).snakeReorient(:,M,:) = pca(s).snakeReorient(:,1,:);


% run PCA on the global shape measures
[pcaShape.pc, pcaShape.zscores, pcaShape.latent] = princomp(pcaShape.toPCA', 'econ');

% run PCA on boundary curvature
[pcaCurvature.pc, pcaCurvature.zscores, pcaCurvature.latent] = princomp(pcaCurvature.toPCA', 'econ');

% run PCA on the local motion measure
[pcaMotion.pc, pcaMotion.zscores, pcaMotion.latent] = princomp(pcaMotion.toPCA', 'econ');

% run PCA on the global motion measure
[pcaLeastSquares.pc, pcaLeastSquares.zscores, pcaLeastSquares.latent] = princomp(pcaLeastSquares.toPCA', 'econ');

% run PCA on the boundary point positions
[pcaBPP.pc, pcaBPP.zscores, pcaBPP.latent] = princomp(pcaBPP.toPCA', 'econ');


% save variables
save([savePath 'pca'], 'pca', 'pcaShape', 'pcaCurvature', 'pcaMotion', 'pcaLeastSquares', 'pcaBPP');


%%%%%%% DEBUG CODE %%%%%%%

% % plot sample reorientations
% figure
% s=40;
% for f=30:50
%     plot(pca(s).snakeReorient(f,1:M-1,1), pca(s).snakeReorient(f,1:M-1,2))
%     hold on
%     plot(pca(s).snakeReorient(f,shape(s).front(f),1), pca(s).snakeReorient(f,shape(s).front(f),2), 'Marker', '.', 'Color', 'g', 'MarkerSize', 15)
%     plot(pca(s).snakeReorient(f,1,1), pca(s).snakeReorient(f,1,2), 'Marker', '.', 'Color', 'r', 'MarkerSize', 10)
%     plot(pca(s).snakeReorient(f,10,1), pca(s).snakeReorient(f,10,2), 'Marker', '.', 'Color', 'r', 'MarkerSize', 10)
%     axis equal
%     axis image
% end


