%%%%%%%%%%%%%%%% ENTER SHAPE SPACE %%%%%%%%%%%%%%%%
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
%   .snakeReorient    - mean subtracted, reoriented (to zero degrees) and realigned so that boundary point 1 is at zero degrees
%   .snakeShape       - the snake in shape space (mean subtracted, reoriented (to zero degrees), realigned so that boundary point 1 is at zero degrees, and given an average radius of 20


function enterShapeSpace(N, M, frameDelta, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

for s=1:length(shape)
    
    % display progress
    if mod(s, 100) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % subtract the mean position in a frame from that frame's positions
    shape(s).snakeReorient = shape(s).snake-repmat(mean(shape(s).snake, 2), 1, M); 

    % iterate through the frames
    for f=1:shape(s).duration-frameDelta
        
        frontAngle = atan2(-1*shape(s).snakeReorient(f,shape(s).front(f),2), shape(s).snakeReorient(f,shape(s).front(f),1)); % the angle of the front
        % compare the angle of the front to the orientation angle
        if abs(frontAngle-shape(s).orientation(f)*(2*pi)/360) < pi/2 
            orientation = shape(s).orientation(f)*(2*pi)/360;
        else 
            orientation = shape(s).orientation(f)*(2*pi)/360 + pi;
        end
        
        % align the boundary points so that the front occurs at boundary point 1
        shape(s).snakeReorient(f,:,:) = circshift(shape(s).snakeReorient(f,:,:),[0 -1*shape(s).front(f)+1 0]); 
        
        % reorient the snake
        [snake_theta,snake_rho] = cart2pol(shape(s).snakeReorient(f,:,1),shape(s).snakeReorient(f,:,2));
        snake_theta = snake_theta+orientation; 
        %snake_rhoAdjust = (20/mean(snake_rho))*snake_rho;  % make the mean radius 20 pixels
        snake_rhoAdjust = snake_rho;
        [shape(s).snakeReorient(f,:,1),shape(s).snakeReorient(f,:,2)] = pol2cart(snake_theta,snake_rho);
        [shape(s).snakeShape(f,:,1),shape(s).snakeShape(f,:,2)] = pol2cart(snake_theta,snake_rhoAdjust);
        
    end
    
end

shape(s).snakeReorient(:,M,:) = shape(s).snakeReorient(:,1,:);
shape(s).snakeShape(:,M,:) = shape(s).snakeShape(:,1,:);

% % plot sample reorientations
% figure
% for f=90:110
%     plot(shape(s).snakeReorient(f,1:M-1,1), shape(s).snakeReorient(f,1:M-1,2))
%     hold on
%     plot(shape(s).snakeReorient(f,shape(s).front(f),1), shape(s).snakeReorient(f,shape(s).front(f),2), 'Marker', '.', 'Color', 'g', 'MarkerSize', 15)
%     plot(shape(s).snakeReorient(f,1,1), shape(s).snakeReorient(f,1,2), 'Marker', '.', 'Color', 'r', 'MarkerSize', 10)
%     plot(shape(s).snakeReorient(f,10,1), shape(s).snakeReorient(f,10,2), 'Marker', '.', 'Color', 'r', 'MarkerSize', 10)
%     axis equal
%     axis image
% end

% save variables
save([savePath 'shape'], 'shape', 'frame2shape');