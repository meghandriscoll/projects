%%%%%%%%%%%%%%%% INITIALIZE SHAPE %%%%%%%%%%%%%%%%
%
% Tracks boundary points from frame to frame.
%
% Inputs:
%  M                - the number of boundary points in each snake
%  savePath         - the directory where data is saved
%
% Saves:
%  shape            
%  .snake           - snakeNum alligned from frame to frame with a least squares mapping
%  .bounds          - the minimum and maximum x and y positions of the all the shape's boundary points (.minx, .maxx, .miny, maxy)

function initShape(M, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% iterate through the shapes
for s=1:length(shape)
    
	if mod(s, 10) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % assign boundary point labels that are consistent from frame to frame
    shape(s).snake=do_least_squares(shape(s).snake, shape(s).duration, M);

    % create a complete polygon by setting the last boundary point position equal to the first boundary point position
    shape(s).snake(:,M,:)=shape(s).snake(:,1,:);

    % find the minimum and maximum boundary point positions for the duration of the shape
    shape(s).bounds.minx=min(min(shape(s).snake(:,:,1)));
    shape(s).bounds.maxx=max(max(shape(s).snake(:,:,1)));
    shape(s).bounds.miny=min(min(shape(s).snake(:,:,2)));
    shape(s).bounds.maxy=max(max(shape(s).snake(:,:,2)));
    
end

shape(1).snake

% save the variables
save([savePath 'shape'],'shape', 'frame2shape');


%%%%%%%%%% DO LEAST SQUARES %%%%%%%%%%

% assign boundary point labels that are consistent from frame to frame
function positionsOut = do_least_squares(positions, N, M)

positionsOut(1,:,:) = positions(1,:,:);

for i = 2:N
    sum_square_distance = zeros(1,M-1);
    for shift = 1:M-1
        sum_square_distance(1,shift) = sum(sum(( positions(i-1,:,:) - circshift(positions(i,:,:),[0 shift 0])).^2, 3),2);
    end
    [min_square_dist, min_shift] = min(sum_square_distance);
    positionsOut(i,:,:)=circshift(positions(i,:,:),[0 min_shift 0]);
end
