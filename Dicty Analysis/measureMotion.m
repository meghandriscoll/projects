%%%%%%%%%%%%%%%% MEASURE MOTION %%%%%%%%%%%%%%%%
%
% Measure motion properties, including boundary point motion.
%
% Local Motion Measure:
% For each boundary point, finds the closest boundary point in the next frame, subject to the conditions 
% that boundary points inside the next frame's boundary can only be connected to boundary points in the 
% next frame that are outside the current boundary and that boundary points outside the next frame's 
% boundary can only be connected to boundary points in the next frame that are inside the current boundary.
% Later smoothes the boundary point connections to force connections into protrusions.
%
% Inputs:
%  N                  - the number of images
%  M                  - the number of boundary points in each snake
%  shape              - tracked shape information
%  frameDelta         - the number of frames over which motion is measured
%  motionThresh       - the maximum allowed value for the local motion measure
%  smoothMotion       - the number of boundary points over which motion is first smoothed
%  smoothMotionAgain  - the number of boundary points over which motion is next smoothed
%  smoothCentroid     - the number of frames the centroid is smoothed over before calculating the centroid velocity
%  frameVelocity      - the number of frames the centroid is smoothed over before calculating the centroid velocity
%  savePath           - the directory that data is saved in
%
% Saves:
%  shape 
%   .centroidSmoothed   - the smoothed location of the centroid
%   .speed              - the centroid speed, measured in pixels/frame
%   .velocityDirection  - the velocity direction in radians
%   .motion             - the uncut local motion measure
%   .cutMotion          - the cut local motion measure
%   .closestBP          - the boundary point mapped to by the local motion mapping
%   .front              - the boundary point closest to the front of the shape (the front was determined by the orientation and average motion)
%   .back               - the boundary point closest to the back of the shape
%   .motionFront        - the local motion measure aligned so that the front is at (M-1)/2
%   .motionBack         - the local motion measure aligned so that the back is at (M-1)/2
%   .leastSquares       - the magnitude and sign of the tracking mapping


%%%%%%%% This code is way too slow! %%%%%%%%%

function measureMotion(N, M, frameDelta, motionThresh, smoothMotion, smoothMotionAgain, smoothCentroid, frameVelocity, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

colors = colormap(hsv(12)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% iterate through the shapes
for s=1:length(shape)
    
    if mod(s, 1) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    %%%%%%% FIND CENTROID VELOCITY %%%%%%%
    % smooth the centroid locations
    shape(s).centroidSmoothed=NaN(shape(s).duration,2);
    shape(s).centroidSmoothed(:,1) = smooth(shape(s).centroid(:,1), smoothCentroid);
    shape(s).centroidSmoothed(:,2) = smooth(shape(s).centroid(:,2), smoothCentroid);
    
    % calculate the velocity
    shape(s).speed = NaN(1,shape(s).duration); 
    for f = (frameVelocity-1)/2+1:shape(s).duration-(frameVelocity-1)/2
        distX = shape(s).centroidSmoothed(f+(frameVelocity-1)/2,1)-shape(s).centroidSmoothed(f-(frameVelocity-1)/2,1);
        distY = shape(s).centroidSmoothed(f+(frameVelocity-1)/2,2)-shape(s).centroidSmoothed(f-(frameVelocity-1)/2,2);
        shape(s).speed(f) = (sqrt(distX.^2 + distY.^2))/frameVelocity;
        shape(s).velocityDirection(f) = mod( atan2(-1*distY,distX), 2*pi);
    end

    %%%%%%% FIND LOCAL BOUNDARY MOTION %%%%%%%
    % initialize variables
    motion.distance=zeros(shape(s).duration-frameDelta,M-1,4);
    motion.cut_distance=zeros(shape(s).duration-frameDelta,M-1,2);
    motion.cut_distanceUnSmoothed=zeros(shape(s).duration-frameDelta,M-1);
    motion.closest_n=zeros(shape(s).duration-frameDelta,M-1,3); 
    forward_distance=zeros(M-1,M-1);

    % iterate through frames
    for f=1:shape(s).duration-frameDelta
        
        % answers the question: which points in the next polygon are inside the current polygon?
        next_in = inpolygon(shape(s).snake(f+frameDelta,1:M-1,1),shape(s).snake(f+frameDelta,1:M-1,2),shape(s).snake(f,:,1),shape(s).snake(f,:,2));
        
        % which points in the next polygon are outside the current polygon?
        next_out = ~next_in;
        
        % penalize incorrect in-next_in and out-next_out connections
        next_in=next_in+1000*next_out;
        %next_out=next_out+1000.*next_in;
        next_out=next_out+-1000.*(next_out-1);
        
        % for each boundary point, find the distance to every boundary point in the next frame
        for shift=1:M-1
            forward_distance(:,shift)=sum( ( circshift(shape(s).snake(f+frameDelta,1:M-1,:),[0 -shift 0]) - shape(s).snake(f,1:M-1,:)).^2, 3 );      
        end
        
        % for each boundary point, find the closest boundary point in the next frame subject 
        % to the in-next_out and out_next-in conditions
        for j=1:M-1
            in=inpolygon(shape(s).snake(f,j,1),shape(s).snake(f,j,2),shape(s).snake(f+frameDelta,:,1),shape(s).snake(f+frameDelta,:,2));
            forward_distance(j,:)=circshift(forward_distance(j,:),[0 j]);
            if in==1
                [motion.distance(f,j,1), motion.closest_n(f,j,1)]=min(next_out.*forward_distance(j,:));
            else
                [motion.distance(f,j,1), motion.closest_n(f,j,1)]=min(next_in.*forward_distance(j,:));
            end
        end
    end
        
    % smooths the connections to force connections into protrusions
    close1=[]; close1S=[];
    close1=mod(circshift(motion.closest_n(:,:,:),[0 (M-1)/4 0])+(M-1)/4, M-1);
    for f=1:shape(s).duration-frameDelta
        close1S(f,:)=round(smooth(close1(f,:,1),smoothMotion));
    end
    close1S=mod(circshift(close1S,[0 -(M-1)/4 0])-(M-1)/4,M-1);

    close2=[]; close2S=[];
    close2=mod(circshift(motion.closest_n(:,:,:),[0 -(M-1)/4 0])-(M-1)/4, M-1);
    for f=1:shape(s).duration-frameDelta
        close2S(f,:)=round(smooth(close2(f,:,1),smoothMotion));
    end
    close2S=mod(circshift(close2S,[0 (M-1)/4 0])+(M-1)/4,M-1);
    motion.closest_n(:,1:(M-1)/2,2)=close1S(:,1:(M-1)/2);
    motion.closest_n(:,(M-1)/2+1:M-1,2)=close2S(:,(M-1)/2+1:M-1);

    for f=1:shape(s).duration-frameDelta
        for j=1:M-1
            if motion.closest_n(f,j,2)==0
                motion.closest_n(f,j,2)=M-1;
            end
        end
    end
    
    % smooth the connections again, so that there isn't a jarring difference between smoothed and unsmoothed
    close1=mod(circshift(motion.closest_n(:,:,2),[0 (M-1)/4 0])+(M-1)/4,M-1);
    for f=1:shape(s).duration-frameDelta
        close1S(f,:)=round(smooth(close1(f,:,1),smoothMotionAgain));
    end
    close1S=mod(circshift(close1S,[0 -(M-1)/4 0])-(M-1)/4,M-1);

    close2=mod(circshift(motion.closest_n(:,:,2),[0 -(M-1)/4 0])-(M-1)/4,M-1);
    for f=1:shape(s).duration-frameDelta
        close2S(f,:)=round(smooth(close2(f,:,1),smoothMotionAgain));
    end
    close2S=mod(circshift(close2S,[0 (M-1)/4 0])+(M-1)/4,M-1);

    motion.closest_n(:,1:(M-1)/2,3)=close1S(:,1:(M-1)/2);
    motion.closest_n(:,(M-1)/2+1:M-1,3)=close2S(:,(M-1)/2+1:M-1);

    for f=1:shape(s).duration-frameDelta
        for j=1:M-1
            if motion.closest_n(f,j,3)==0
                motion.closest_n(f,j,3)=M-1;
            end
        end
    end

    % find the distance of the smoothed connections and assign the correct sign to the motion vector
    motion.sign=zeros(shape(s).duration-frameDelta,M-1);
    for f=1:shape(s).duration-frameDelta
        for j=1:M-1
            motion.distance(f,j,2) = sqrt(sum( ( shape(s).snake(f+frameDelta,motion.closest_n(f,j,3),:) - shape(s).snake(f,j,:)).^2, 3 ));
            motion.cut_distance(f,j,1) = motion.distance(f,j,2);
            if abs(motion.distance(f,j,2))>motionThresh
                motion.cut_distance(f,j,1)=motionThresh;
            end
        end
        motion.sign(f,:)=inpolygon(shape(s).snake(f+frameDelta,motion.closest_n(f,:,3),1),shape(s).snake(f+frameDelta,motion.closest_n(f,:,3),2),shape(s).snake(f,:,1),shape(s).snake(f,:,2));
    end
    dir=ones(shape(s).duration-frameDelta,M-1)-2*motion.sign;
    motion.distance(:,:,3)=dir.*motion.distance(:,:,2);
    motion.distance(:,:,4)=dir.*motion.distance(:,:,1);
    motion.cut_distance(:,:,2)=dir.*motion.cut_distance(:,:,1);
    
    % define motion variables
    shape(s).motion = squeeze(motion.distance(:,:,3));
    shape(s).cutMotion = squeeze(motion.cut_distance(:,:,2)); 
    shape(s).closestBP = squeeze(motion.closest_n(:,:,3));
    
    %%%%%%% FIND MOTION SCALED BY AREA %%%%%%%
    % for each boundary point, find the area corresponding to its motion vector by finding the area of the polygon corresponding to each vector
    motionArea = NaN(shape(s).duration-frameDelta, M-1);
    for f=1:shape(s).duration-frameDelta
        
        % debugging figure
%         if s==62 && f>34  && f<38  
%             figure
%         end
        
        % iterate through the vertices
        for j=1:M-1
            
            % counstruct a list of the current frame's vertices
            % find the index, in the current shape, of the boundary points to the right and left of the boundary point of interest
            smallerBP = mod(j-1,M-1);
            if smallerBP==0, smallerBP=M-1; end 
            largerBP = mod(j+1,M-1);  
            if largerBP==0, largerBP=M-1; end 
            % find the positions of the vertices
            currentVertices = [(shape(s).snake(f,largerBP,:)+shape(s).snake(f,j,:))/2, shape(s).snake(f,j,:), (shape(s).snake(f,j,:)+shape(s).snake(f,smallerBP,:))/2]; 
        
            % counstruct a list of the next frame's vertices
            % first look at smaller boundary point indices
            futureVertices =[];
            smallerBP = mod(j-1,M-1);
            if smallerBP==0, smallerBP=M-1; end 
            if shape(s).closestBP(f,smallerBP) ~= shape(s).closestBP(f,j)
                
                % the distance, in boundary points, between connected to points in the future frame
                smallerDistance = mod(shape(s).closestBP(f,j)-shape(s).closestBP(f,smallerBP), M-1);
                
                % append any needed vertices that are midway between boundary points
                if mod(smallerDistance, 2) == 1
                    midBPfirst = mod(floor(shape(s).closestBP(f,smallerBP)+smallerDistance/2), M-1);
                    if midBPfirst==0, midBPfirst=M-1; end 
                    midBPsecond = mod(ceil(shape(s).closestBP(f,smallerBP)+smallerDistance/2), M-1);
                    if midBPsecond==0, midBPsecond=M-1; end 
                    futureVertices = [futureVertices, (shape(s).snake(f+frameDelta,midBPfirst,:)+shape(s).snake(f+frameDelta,midBPsecond,:))/2];
                end

                % append any needed boundary points from the next frame
                if smallerDistance > 1 
                    nextfutureBP = mod(shape(s).closestBP(f,j)-floor(smallerDistance/2), M-1); % find the next possible boundary point in the future frame to append
                    if nextfutureBP==0, nextfutureBP=M-1; end 
                    while shape(s).closestBP(f,j) ~= nextfutureBP % keep appending boundary points if the next boundary point is not past the connected to boundary point
                        futureVertices = [futureVertices, shape(s).snake(f+frameDelta,nextfutureBP,:)];
                        nextfutureBP = mod(nextfutureBP+1, M-1);
                        if nextfutureBP==0, nextfutureBP=M-1; end 
                    end
                end

            end

            % next append the connected to boundary point in the next frame
            futureVertices = [futureVertices,  shape(s).snake(f+frameDelta,shape(s).closestBP(f,j),:)]; 

            % finally look at larger boundary point indices
            largerBP = mod(j+1,M-1);  
            if largerBP==0, largerBP=M-1; end 
            if shape(s).closestBP(f,largerBP) ~= shape(s).closestBP(f,j)

                % the distance, in boundary points, between connected to points in the future frame
                largerDistance = mod(shape(s).closestBP(f,largerBP)-shape(s).closestBP(f,j), M-1);
                
                % append any needed boundary points from the next frame
                if largerDistance > 1 

                    nextfutureBP = mod(shape(s).closestBP(f,j)+1, M-1); % find the next possible boundary point in the future frame to append
                    if nextfutureBP==0, nextfutureBP=M-1; end 
                    while mod(nextfutureBP-shape(s).closestBP(f,j), M-1) <= largerDistance/2 % keep appending boundary points if the next boundary point is not past the midpoint
                        futureVertices = [futureVertices, shape(s).snake(f+frameDelta,nextfutureBP,:)];
                        nextfutureBP = nextfutureBP+1;
                        nextfutureBP = mod(nextfutureBP+1, M-1);
                        if nextfutureBP==0, nextfutureBP=M-1; end 
                    end
                end

                % append any needed vertices that are midway between boundary points
                if mod(largerDistance, 2) == 1
                    midBPfirst = mod(floor(shape(s).closestBP(f,j)+largerDistance/2), M-1);
                    if midBPfirst==0, midBPfirst=M-1; end 
                    midBPsecond = mod(ceil(shape(s).closestBP(f,j)+largerDistance/2), M-1);
                    if midBPsecond==0, midBPsecond=M-1; end 
                    futureVertices = [futureVertices, (shape(s).snake(f+frameDelta,midBPfirst,:)+shape(s).snake(f+frameDelta,midBPsecond,:))/2];
                end
            end
 
            toPolyArea = [currentVertices, futureVertices, currentVertices(1,1,:)];
            motionArea(f,j) = polyarea(toPolyArea(:,:,1), toPolyArea(:,:,2));
            
            % debugging figure
%             if s==62 && f>34  && f<38  
%                 %fill(toPolyArea(:,:,1), toPolyArea(:,:,2), colors(mod(j,12)+1,:));
%                 hold on
%                 toX = [shape(s).snake(f,j,1), shape(s).snake(f+frameDelta,shape(s).closestBP(f,j),1)];
%                 toY = [shape(s).snake(f,j,2), shape(s).snake(f+frameDelta,shape(s).closestBP(f,j),2)];
%                 plot(toX, toY, 'Color', 'k', 'Marker', 'none','LineStyle', '--', 'LineWidth', 2);
%             end
        end
        
        % debugging figure
%         if s==62 && f>34  && f<38  
%             f
%             plot(shape(s).snake(f,:,1), shape(s).snake(f,:,2), 'Color','k', 'Marker', '.', 'MarkerSize', 15, 'LineStyle', 'none')
%             hold on
%             plot(shape(s).snake(f+frameDelta,:,1), shape(s).snake(f+frameDelta,:,2), 'Color',[0.5,0.5,0.5], 'Marker', '.', 'MarkerSize', 15, 'LineStyle', 'none')
%             
%             plot(shape(s).snake(f,1,1), shape(s).snake(f,1,2), 'Color','k', 'Marker', '.', 'MarkerSize', 35, 'LineStyle', 'none')
%             axis equal
%         end
        
    end
    
    shape(s).motionArea=dir.*motionArea;
    
    %%%%%%% FIND GLOBAL BOUNDARY MOTION %%%%%%%
    % find the least squares distance from frame to frame
    motion.signLS=zeros(shape(s).duration-1,M);
    motion.least_squares_distance=zeros(shape(s).duration-1,M);
    for f=1:shape(s).duration-1
        motion.signLS(f,:)=inpolygon(shape(s).snake(f+1,:,1),shape(s).snake(f+1,:,2),shape(s).snake(f,:,1),shape(s).snake(f,:,2));
        motion.least_squares_distance(f,:) = sqrt(sum((shape(s).snake(f,:,:)-shape(s).snake(f+1,:,:)).^2, 3));
    end
    dir=ones(shape(s).duration-1,M)-2*motion.signLS;
    shape(s).leastSquares=dir.*motion.least_squares_distance;

    %%%%%%% FIND THE CELL FRONT AND BACKS %%%%%%%
    % find the average of the local motion measure near the two possible front and back boundary points in order to distinguish the front and back
    shape(s).front=NaN(1,shape(s).duration-frameDelta);
    shape(s).back=NaN(1,shape(s).duration-frameDelta);
    for f=1:shape(s).duration-frameDelta 
        motionLarge = [shape(s).motion(f,(M-1)/2+1:M-1), shape(s).motion(f,1:M-1), shape(s).motion(f,1:(M-1)/2) ]; % because of periodic boundary conditions
        motionFirst = sum(motionLarge(shape(s).frontBack(f,1)+(M-1)/2-(M-1)/4:shape(s).frontBack(f,1)+(M-1)/2+(M-1)/4));
        motionSecond = sum(motionLarge(shape(s).frontBack(f,2)+(M-1)/2-(M-1)/4:shape(s).frontBack(f,2)+(M-1)/2+(M-1)/4));
        if motionFirst > motionSecond
            shape(s).front(f) = shape(s).frontBack(f,1);
            shape(s).back(f) = shape(s).frontBack(f,2);
        else
            shape(s).front(f) = shape(s).frontBack(f,2);
            shape(s).back(f) = shape(s).frontBack(f,1);
        end
    end
    
    % align the motion variable by the front and back boundary points
    for f=1:shape(s).duration-frameDelta 
        shape(s).motionFront(f,:) = circshift(shape(s).motion(f,:),[0 -1*(shape(s).front(f)+(M-1)/2)]); 
        shape(s).motionBack(f,:) = circshift(shape(s).motion(f,:),[0 -1*(shape(s).back(f)+(M-1)/2)]); 
        
        shape(s).motionAreaFront(f,:) = circshift(shape(s).motionArea(f,:),[0 -1*(shape(s).front(f)+(M-1)/2)]); 
        shape(s).motionAreaBack(f,:) = circshift(shape(s).motionArea(f,:),[0 -1*(shape(s).back(f)+(M-1)/2)]); 
    end
    
end

% save the variables
save([savePath 'shape'],'shape', 'frame2shape');
save([savePath 'shapeMotion'],'shape', 'frame2shape');
