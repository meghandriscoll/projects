%%%%%%%%%%%%%%%% MEASURE SHAPE IN SHAPE SPACE %%%%%%%%%%%%%%%%
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
%  shape 

function measureShapeInShapeSpace(N, M, frameDelta, savePath)

% load saved variables
load([savePath 'shape']); % tracked shapes (loads shape and frame2shape)

toPCAShape=[];
toPCACurvature=[];

% iterate through the shapes
for s=1:length(shape)
    
    % display progress
    if mod(s, 50) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % iterate through the frames (in order to realign and rescale the measures)
    for f=1:shape(s).duration-frameDelta
        
        % align the measures so that the front occurs at boundary point 1
%        shape(s).distanceShapeSpace(f,:) = circshift(shape(s).distance(f,:),[0 -1*shape(s).front(f)+1]); 
        shape(s).uncutCurvatureShapeSpace(f,:) = circshift(shape(s).uncutCurvature(f,:),[0 -1*shape(s).front(f)+1]); 
    
%         % scale the measures
%         shape(s).distanceShapeSpace(f,1:M-1) = shape(s).distanceShapeSpace(f,1:M-1)*(20/mean(shape(s).distanceShapeSpace(f,1:M-1))); % note that this rescaling is with respect to the shape mean rather than the shape centroid which the position is rescaled with respect to
%         shape(s).uncutCurvatureShapeSpace(f,1:M-1) = shape(s).uncutCurvatureShapeSpace(f,1:M-1)*(mean(shape(s).distanceShapeSpace(f,1:M-1))/20); 
%         
    end
    
        % accumulate the shape and curvature measures for PCA
        %toPCAShape=[toPCAShape; shape(s).distanceShapeSpace(:,1:M-1)];
        if min(min(isfinite(shape(s).uncutCurvatureShapeSpace)))  % remove infinities
           toPCACurvature=[toPCACurvature; shape(s).uncutCurvatureShapeSpace(:,1:M-1)];
        end
    
end

% do PCA on the curvature and shape measures in shape space
% figure
% imagesc(toPCAShape')
% [pcS,zscoresS,latentS] = princomp(toPCAShape', 'econ');
% cumsum(100*latentS/sum(latentS))

figure
imagesc(toPCACurvature')
[pcC,zscoresC,latentC] = princomp(toPCACurvature', 'econ');
% cumsum(100*latentC/sum(latentC))

% % plot the pca components
% figure
% imagesc(zscoresS)
% title('zscoresS')

% colors=colormap(hsv(13));

% plot the pca components
figure
imagesc(zscoresC)
title('zscoresC')

% plot the latents
figure
imagesc(latentC)
title('latentC')

% plot the first four components 
figure
plot(zscoresC(:,1), 'LineWidth', 2, 'Color', 'r');
hold on
plot(zscoresC(:,2), 'LineWidth', 2, 'Color', 'b');
plot(zscoresC(:,3), 'LineWidth', 2, 'Color', 'b', 'LineStyle', '--');
%plot(zscoresS(:,4), 'LineWidth', 2, 'Color', 'g');
title('The first three PCA components')

% % plot the next six components 
% figure
% plot(zscoresS(:,8), 'LineWidth', 2, 'Color', 'r');
% hold on
% plot(zscoresS(:,9), 'LineWidth', 2, 'Color', 'r', 'LineStyle', '--');
% plot(zscoresS(:,10), 'LineWidth', 2, 'Color', 'g');
% plot(zscoresS(:,11), 'LineWidth', 2, 'Color', 'g', 'LineStyle', '--');
% %plot(zscoresC(:,8), 'LineWidth', 2, 'Color', 'b');
% %plot(zscoresC(:,9), 'LineWidth', 2, 'Color', 'b', 'LineStyle', '--');
% title('The 8th through 11th modes')

% % plot the latent values for the first 26 modes
% figure
% plot(latentS(1:26), 'LineWidth', 2)
% title('latent')

% % plot the pseudo-phase
% figure
% plot(1, (zscoresC(1,1)-min(zscoresC(:,1)))/(max(zscoresC(:,1))-min(zscoresC(:,1))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(1,:));
% hold on
% for p=1:9
%     plot(p+1, (zscoresC(1,2*p)-min(zscoresC(:,2*p)))/(max(zscoresC(:,2*p))-min(zscoresC(:,2*p))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(p+1,:));
%     plot(p+1, (zscoresC(1,2*p+1)-min(zscoresC(:,2*p+1)))/(max(zscoresC(:,2*p+1))-min(zscoresC(:,2*p+1))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(p+1,:));
% end
% plot(1,(zscoresC(1,20)-min(zscoresC(:,20)))/(max(zscoresC(:,20))-min(zscoresC(:,20))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(1,:));
% for p=11:13
%     plot(p, (zscoresC(1,2*p-1)-min(zscoresC(:,2*p-1)))/(max(zscoresC(:,2*p-1))-min(zscoresC(:,2*p-1))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(p,:));
%     plot(p, (zscoresC(1,2*p)-min(zscoresC(:,2*p)))/(max(zscoresC(:,2*p))-min(zscoresC(:,2*p))), 'Marker', '.', 'MarkerSize', 15,'Color', colors(p,:));
% end

% 
% %%%%% do pca on binned data %%%%%
% % initialize variables
% numBins = 2;
% toPCACurvature=cell(numBins,1);
% toPCAShape=cell(numBins,1);
% 
% % iterate through the shapes
% for s=1:length(shape)
%     
% 	% iterate through the times the shape is in the ROI
%     for t=1:length(shape(s).durationInROI) 
%         startFrame = shape(s).startFrameInROI(t)-shape(s).startFrame+1; % first track in shape's time space
%         endFrame = shape(s).endFrameInROI(t)-shape(s).startFrame+1-frameDelta; % last track in shape's time space that is not larger than the length of motion
%         
%         framePointer = startFrame; % assign a pointer to iterate through the frames
%         
%         % iterate through the frames in which the shape is in the ROI
%         while framePointer <= endFrame
%                 
%             % find the bin
%             binShape = ceil(shape(s).orientationLine(framePointer)*numBins/(pi/2)+0.00000001);
%                 
%             % append data to toPCA
%             toPCAShape{binShape,1}=[toPCAShape{binShape,1}; shape(s).distanceShapeSpace(:,1:M-1)];
%             if min(min(isfinite(shape(s).uncutCurvatureShapeSpace)))  % remove infinities
%                 toPCACurvature{binShape,1}=[toPCACurvature{binShape,1}; shape(s).uncutCurvatureShapeSpace(:,1:M-1)];
%             end
% 
%             framePointer=framePointer+5;  % note that this isn't one
%                 
%         end
%         
%     end
%     
% end

% % do PCA on shape measures in shape space
% colors = colormap(jet(numBins));
% figure
% imagesc(toPCAShape')
% figure
% for b=1:numBins
%     [pcS,zscoresS,latentS] = princomp(toPCAShape{b,1}', 'econ');
%     plot(zscoresS(:,1), 'LineWidth', 2, 'Color', colors(b,:));
%     hold on
% end

% % do PCA on the curvature measures in shape space
% colors = colormap(jet(numBins));
% figure
% imagesc(toPCACurvature')
% figure
% for b=1:numBins
%     [pcC,zscoresC,latentC] = princomp(toPCACurvature{b,1}', 'econ');
%     plot(zscoresC(:,1), 'LineWidth', 2, 'Color', colors(b,:));
%     hold on
% end

