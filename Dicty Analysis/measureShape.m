%%%%%%%%%%%%%%%% MEASURE SHAPE %%%%%%%%%%%%%%%%
%
% Measure shape properties.
%
% Inputs:
%  M                    - the number of boundary points in each snake
%  boundaryPoint        - number of boundary points over which curvature is found 
%  curvatureThresh      - the largest curvature magnitude allowed in the cutoff curvature
%  savePath             - the directory where data is saved
%
% Saves:
%  shape                
%   .area               - the area of the shape in every frame (uses snakeDist and polyarea) 
%   .perimeter          - the perimeter of the shape in every frame (uses snakeDist) 
%   .circularity        - the ratio of area to square perimeter
%   .centroid           - the centroid of the shape in every frame (uses snakeDist) 
%   .distance           - the distance, in pixels, from each boundary point to the centroid (uses snakeNum)
%   .angle              - the angle of each boundary point with respect to the centroid
%   .curvature          - the boundary curvature at each boundary point (uses snakeNum) Curvatures above or below a cutoff are given the magnitude of the cutoff
%   .uncutCurvature     - the uncut boundary curvature at each boundary point (uses snakeNum) 
%   .meanNegCurvature   - the mean negative curvature
%   .numIndents         - the number of boundary regions over which the curvature is negative
%   .tort               - the boundary tortuousity (a measure of how bendy the boundary is)
%   .eccentricity       - the eccentricity of the best fit ellipse (uses regionprops)
%   .majorAxisLength    - the major axis length of the best fit ellipse (uses regionprops) 
%   .minorAxisLength    - the minor axis length of the best fit ellipse (uses regionprops)
%   .orientation        - the orientation of the best fit ellipse (uses regionprops)
%   .solidity           - the percentage of the shape inside its own convex hull (uses regionprops)
%   .frontBack          - the boundary points closest to the front and the back of the shape, as measured by orientation (the back and front are not distinguished here)
%  shapeMeasure         - save a backup copy of shape that will not be overwriten by other programs


%%%%%%%% This code is way too slow! (curvature should not be in a for loop) %%%%%%%%%


function measureShape(M, boundaryPoint, curvatureThresh, savePath)

% load saved variables
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% iterate over the shapes
for s = 1:length(shape)
    
	if mod(s, 1) == 0
        disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
    end
    
    % initialize variables
    shape(s).area = NaN(1,shape(s).duration);
    shape(s).perimeter = NaN(1,shape(s).duration);
    shape(s).circularity = NaN(1,shape(s).duration);
    shape(s).centroid = NaN(shape(s).duration,2);
    shape(s).distance = NaN(shape(s).duration,M);
    shape(s).radius = NaN(1,shape(s).duration);
    shape(s).angle = NaN(shape(s).duration,M);
    
    shape(s).curvature = NaN(shape(s).duration,M);
    shape(s).uncutCurvature = NaN(shape(s).duration,M);
    shape(s).meanNegCurvature = NaN(1,shape(s).duration);
    shape(s).numIndents = NaN(1,shape(s).duration);
    shape(s).tort = NaN(1,shape(s).duration);
    
    shape(s).eccentricity = NaN(1,shape(s).duration);
    shape(s).majorAxisLength = NaN(1,shape(s).duration);
    shape(s).minorAxisLength = NaN(1,shape(s).duration); 
    shape(s).orientation = NaN(1,shape(s).duration); 
    shape(s).solidity = NaN(1,shape(s).duration);
    
    shape(s).frontBack = NaN(shape(s).duration,2);
    
    % iterate over the frames
    for f=1:shape(s).duration

        % calculate the area (uses snakeDist rather than snake)
        shape(s).area(f) = polyarea(shape(s).snakeDist{f}(1,:), shape(s).snakeDist{f}(2,:));
          
        % calculate the perimeter (uses snakeDist rather than snake) 
        shape(s).perimeter(f) = sum(sqrt(sum((shape(s).snakeDist{f}-circshift(shape(s).snakeDist{f},[0 1])).^2))); % sum up the distances between adjacent boundary points  
        
        % calculate the circularity
        shape(s).circularity(f)=4*pi*shape(s).area(f)/shape(s).perimeter(f)^2;
        
        % calculate the centroid location (uses snakeDist rather than snake), %%%%%% make sure to check this %%%%%%
        sumX=sum((shape(s).snakeDist{f}(1,:)+circshift(shape(s).snakeDist{f}(1,:),[0 1])).*(shape(s).snakeDist{f}(1,:).*circshift(shape(s).snakeDist{f}(2,:),[0 1])-circshift(shape(s).snakeDist{f}(1,:),[0 1]).*shape(s).snakeDist{f}(2,:)));
        sumY=sum((shape(s).snakeDist{f}(2,:)+circshift(shape(s).snakeDist{f}(2,:),[0 1])).*(shape(s).snakeDist{f}(1,:).*circshift(shape(s).snakeDist{f}(2,:),[0 1])-circshift(shape(s).snakeDist{f}(1,:),[0 1]).*shape(s).snakeDist{f}(2,:)));
        shape(s).centroid(f,:)=[abs(sumX) abs(sumY)]/(6*shape(s).area(f));
        
        % calculate the distance from the centroid to each boundary point
        distX = squeeze(shape(s).snake(f,:,1))-shape(s).centroid(f,1);
        distY = squeeze(shape(s).snake(f,:,2))-shape(s).centroid(f,2);
        shape(s).distance(f,:) = sqrt(distX.^2+distY.^2);
        shape(s).angle(f,:)=mod( atan2(-1*distY,distX), 2*pi);
          
        % calculate the curvature (by finding the radius of the osculating circle using three adjacent points)
        bp_positions=[shape(s).snake(f,M-1-boundaryPoint:M-1,:), shape(s).snake(f,1:M-1,:), shape(s).snake(f,1:boundaryPoint+1,:)];
        for j=1:M
            point1=squeeze(bp_positions(1,j,:))';
            point2=squeeze(bp_positions(1,j+boundaryPoint,:))';
            point3=squeeze(bp_positions(1,j+2*boundaryPoint,:))'; 
            slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
            slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));

            if slope12==Inf || slope12==-Inf || slope12 == 0
                point0=point2; point2=point3; point3=point0;
                slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
                slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));    
            end

            if slope23==Inf || slope23==-Inf
                point0=point1; point1=point2; point2=point0;
                slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
                slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));    
            end

            if slope12==slope23
                shape(s).curvature(f,j)=0;
            else
                x_center=(slope12*slope23*(point1(1,2)-point3(1,2))+slope23*(point1(1,1)+point2(1,1))-slope12*(point2(1,1)+point3(1,1)))/(2*(slope23-slope12));
                midpoint12=(point1+point2)/2;
                midpoint13=(point1+point3)/2;
                y_center=(-1/slope12)*(x_center-midpoint12(1,1))+midpoint12(1,2);
                shape(s).curvature(f,j)=1/sqrt((point1(1,1)-x_center)^2+(point1(1,2)-y_center)^2);

                shape(s).uncutCurvature(f,j) = shape(s).curvature(f,j);
                if shape(s).curvature(f,j) > curvatureThresh
                    shape(s).curvature(f,j) = curvatureThresh;
                end

                [In On] = inpolygon(midpoint13(1,1),midpoint13(1,2),shape(s).snake(f,:,1),shape(s).snake(f,:,2)); 

                if ~In              
                    shape(s).curvature(f,j)=-1*shape(s).curvature(f,j);
                    shape(s).uncutCurvature(f,j)=-1*shape(s).uncutCurvature(f,j);
                end

                if On || ~isfinite(shape(s).uncutCurvature(f,j))
                    shape(s).curvature(f,j)=0;
                    shape(s).uncutCurvature(f,j)=0;
                end
                
            end 
        end
        
        % find the mean negative curvature (really this should use a constant dist snake)
        listCurve = shape(s).uncutCurvature(f,1:M-1);
        listNegCurve = abs(listCurve(listCurve < 0));
        if ~isempty(listNegCurve) 
            shape(s).meanNegCurvature(1,f) = sum(listNegCurve)/(M-1);
        else
            shape(s).meanNegCurvature(1,f) = 0;
        end
        
        % find the number of negative boundary curvature regions
        curveMask = (listCurve < 0);
        curveMaskLabeled = bwlabel(curveMask);
        numIndents = max(curveMaskLabeled);
        if curveMask(1) && curveMask(end)
            numIndents  = numIndents-1;
        end
        shape(s).numIndents(1,f) = numIndents;
        
        % find the tortuosity (should correct units)
        shape(s).tort(1,f) = sum(gradient(shape(s).uncutCurvature(f,1:M-1)).^2)/shape(s).perimeter(1,f);
    
        % find properties of the pixelated shape
        shapeMask = poly2mask(shape(s).snake(f,:,1)-shape(s).bounds.minx+2, shape(s).snake(f,:,2)-shape(s).bounds.miny+2, ceil(shape(s).bounds.maxy-shape(s).bounds.miny)+4, ceil(shape(s).bounds.maxx-shape(s).bounds.minx)+4);
        stats = regionprops(bwlabel(shapeMask), 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Solidity');

        if ~isempty(stats)
            % restructure these property variables    
            shape(s).eccentricity(f) = stats(1).Eccentricity;
            shape(s).majorAxisLength(f) = stats(1).MajorAxisLength;
            shape(s).minorAxisLength(f) = stats(1).MinorAxisLength;
            shape(s).orientation(f) = stats(1).Orientation;
            shape(s).solidity(f) = stats(1).Solidity;
            
            % find the boundary points closest to the front and back of the shape (as defined by orientation)
            [minDist, frontBack] = min( mod( shape(s).angle(f,:)-mod(shape(s).orientation(f)*(2*pi)/360, 2*pi), 2*pi) );
            [minDistRev, frontBackRev] = min( mod( shape(s).angle(f,:)-mod((shape(s).orientation(f)+180)*(2*pi)/360, 2*pi), 2*pi) );
            shape(s).frontBack(f,:) = [frontBack(1), frontBackRev(1)];
            
        else
            display(['    shape ' num2str(s) ' frame ' num2str(i) ' is empty'])
            
            % restructure these property variables    
            shape(s).eccentricity(f) = NaN;
            shape(s).majorAxisLength(f) = NaN;
            shape(s).minorAxisLength(f) = NaN;
            shape(s).orientation(f) = NaN;
            shape(s).solidity(f) = NaN;

            % find the boundary points closest to the front and back of the shape (as defined by orientation)
            shape(s).frontBack(f,:) = NaN;
        end
    end
end

% save the variables
save([savePath 'shape'],'shape', 'frame2shape');
save([savePath 'shapeMeasure'],'shape', 'frame2shape');