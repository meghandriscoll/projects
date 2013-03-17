%%%%%%%%%%%%%%%% MEASURE SHAPE %%%%%%%%%%%%%%%%

% Measure shape properties.

% Inputs:
%  N                - the number of images
%  snake            - the output of findSnake.m
%  boundaryPoint

% Outputs:
%  shape(i).nuclei(r)
%   .number
%   .area
%   .perimeter
%   .centroid
%   .distance
%   .maxDist
%   .meanDistance
%   .ratio
%   .curvatureNum
%   .uncutCurvatureNum
%   .curvatureDist
%   .uncutCurvatureDist
%   .sumNegCurvatureDist
%   .tort
%   .eccentricity
%   .equivDiameter
%   .majorAxisLength
%   .minorAxisLength
%   .intensityValues
%   .meanIntensity
%   .stdIntensity
%   .numTroughs
%   .troughLocs

function [shape, snakeShift] = measureShape(N, picture, snake, boundaryPoint, inDirectory)

% define useful varables
M = length(snake(1).nuclei(1).posNum);

% iterate through the images
for i=1:N
    display(['   image ' num2str(i)]);
    
    shape(i).number = length(snake(i).nuclei);
    
    % iterate through the nuclei
    for r=1:length(snake(i).nuclei)
        
        % calculate the area
        shape(i).nuclei(r).area = polyarea(snake(i).nuclei(r).posDist(1,:), snake(i).nuclei(r).posDist(2,:));
    
        % calculate the perimeter
        sumP=0;
        for j=1:(length(snake(i).nuclei(r).posDist)-1)
            sumP=sumP+sqrt((snake(i).nuclei(r).posDist(1,j)-snake(i).nuclei(r).posDist(1,j+1))^2+(snake(i).nuclei(r).posDist(2,j)-snake(i).nuclei(r).posDist(2,j+1))^2);
        end
        jMax = length(snake(i).nuclei(r).posDist);
        sumP=sumP+sqrt((snake(i).nuclei(r).posDist(1,jMax)-snake(i).nuclei(r).posDist(1,1))^2+(snake(i).nuclei(r).posDist(2,jMax)-snake(i).nuclei(r).posDist(2,1))^2);
        shape(i).nuclei(r).perimeter=sumP;

        % calculate the centroid location
        sum_x=0;
        sum_y=0;
        for j=1:(length(snake(i).nuclei(r).posDist)-1)
            sum_x=sum_x+(snake(i).nuclei(r).posDist(1,j)+snake(i).nuclei(r).posDist(1,j+1))*(snake(i).nuclei(r).posDist(1,j)*snake(i).nuclei(r).posDist(2,j+1)-snake(i).nuclei(r).posDist(1,j+1)*snake(i).nuclei(r).posDist(2,j));
            sum_y=sum_y+(snake(i).nuclei(r).posDist(2,j)+snake(i).nuclei(r).posDist(2,j+1))*(snake(i).nuclei(r).posDist(1,j)*snake(i).nuclei(r).posDist(2,j+1)-snake(i).nuclei(r).posDist(1,j+1)*snake(i).nuclei(r).posDist(2,j));
        end
        jMax = length(snake(i).nuclei(r).posDist);
        sum_x=sum_x+(snake(i).nuclei(r).posDist(1,jMax)+snake(i).nuclei(r).posDist(1,1))*(snake(i).nuclei(r).posDist(1,jMax)*snake(i).nuclei(r).posDist(2,1)-snake(i).nuclei(r).posDist(1,1)*snake(i).nuclei(r).posDist(2,jMax));
        sum_y=sum_y+(snake(i).nuclei(r).posDist(2,jMax)+snake(i).nuclei(r).posDist(2,1))*(snake(i).nuclei(r).posDist(1,jMax)*snake(i).nuclei(r).posDist(2,1)-snake(i).nuclei(r).posDist(1,1)*snake(i).nuclei(r).posDist(2,jMax));
        shape(i).nuclei(r).centroid=[abs(sum_x) abs(sum_y)]/(6*shape(i).nuclei(r).area);
        
        % calculate the distance from the centroid to each boundary point
        shape(i).nuclei(r).distance = sqrt((snake(i).nuclei(r).posNum(1,:)-shape(i).nuclei(r).centroid(1,1)).^2+(snake(i).nuclei(r).posNum(2,:)-shape(i).nuclei(r).centroid(1,2)).^2);
        [shape(i).nuclei(r).maxDistance, shape(i).nuclei(r).maxDistanceLoc] = max(shape(i).nuclei(r).distance);
        shape(i).nuclei(r).meanDistance = mean(shape(i).nuclei(r).distance);
        shape(i).nuclei(r).distanceDist = sqrt((snake(i).nuclei(r).posDist(1,:)-shape(i).nuclei(r).centroid(1,1)).^2+(snake(i).nuclei(r).posDist(2,:)-shape(i).nuclei(r).centroid(1,2)).^2);
        [shape(i).nuclei(r).maxDistanceDist, shape(i).nuclei(r).maxDistanceLocDist] = max(shape(i).nuclei(r).distanceDist);
        
        % calculate the ratio of perimeter to area, normalized so that a circle would have ratio 1
        shape(i).nuclei(r).ratio=(shape(i).nuclei(r).perimeter*shape(i).nuclei(r).meanDistance)/(2*shape(i).nuclei(r).area);
        
        % calculate the curvature of posNum (by finding the radius of the osculating circle using three adjacent points)
        bp_positions=[snake(i).nuclei(r).posNum(:,(M-1-boundaryPoint):M),snake(i).nuclei(r).posNum, snake(i).nuclei(r).posNum(:,1:boundaryPoint)];
        for j=1:M
            point1=squeeze(bp_positions(:,j))';
            point2=squeeze(bp_positions(:,j+boundaryPoint))';
            point3=squeeze(bp_positions(:,j+2*boundaryPoint))'; 
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
                shape(i).nuclei(r).curvatureNum(1,j)=0;
            else
                x_center=(slope12*slope23*(point1(1,2)-point3(1,2))+slope23*(point1(1,1)+point2(1,1))-slope12*(point2(1,1)+point3(1,1)))/(2*(slope23-slope12));
                midpoint12=(point1+point2)/2;
                midpoint13=(point1+point3)/2;
                y_center=(-1/slope12)*(x_center-midpoint12(1,1))+midpoint12(1,2);
                shape(i).nuclei(r).curvatureNum(1,j)=1/sqrt((point1(1,1)-x_center)^2+(point1(1,2)-y_center)^2);

                shape(i).nuclei(r).uncutCurvatureNum(1,j) = shape(i).nuclei(r).curvatureNum(1,j);
                if shape(i).nuclei(r).curvatureNum(1,j)>(1.2/boundaryPoint)
                    shape(i).nuclei(r).curvatureNum(1,j)=(1.2/boundaryPoint);
                end

                [In On] = inpolygon(midpoint13(1,1),midpoint13(1,2),snake(i).nuclei(r).posNum(1,:),snake(i).nuclei(r).posNum(2,:)); 

                if ~In              
                    shape(i).nuclei(r).curvatureNum(1,j)=-1*shape(i).nuclei(r).curvatureNum(1,j);
                    shape(i).nuclei(r).uncutCurvatureNum(1,j)=-1*shape(i).nuclei(r).uncutCurvatureNum(1,j);
                end

                if On
                    shape(i).nuclei(r).curvatureNum(1,j)=0;
                    shape(i).nuclei(r).uncutCurvatureNum(1,j)=0;
                end

            end
        end
        
        % calculate the curvature of posDist (by finding the radius of the osculating circle using three adjacent points)
%         numPoints = length(snake(i).nuclei(r).posDist);
%         bp_positions=[snake(i).nuclei(r).posDist(:,(numPoints-1-boundaryPoint):numPoints),snake(i).nuclei(r).posDist, snake(i).nuclei(r).posDist(:,1:boundaryPoint)];
%         for j=1:numPoints
%             point1=squeeze(bp_positions(:,j))';
%             point2=squeeze(bp_positions(:,j+boundaryPoint))';
%             point3=squeeze(bp_positions(:,j+2*boundaryPoint))'; 
%             slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
%             slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));
% 
%             if slope12==Inf || slope12==-Inf || slope12 == 0
%                 point0=point2; point2=point3; point3=point0;
%                 slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
%                 slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));    
%             end
% 
%             if slope23==Inf || slope23==-Inf
%                 point0=point1; point1=point2; point2=point0;
%                 slope12=(point1(1,2)-point2(1,2))/(point1(1,1)-point2(1,1));
%                 slope23=(point2(1,2)-point3(1,2))/(point2(1,1)-point3(1,1));    
%             end
% 
%             if slope12==slope23
%                 shape(i).nuclei(r).curvatureDist(1,j)=0;
%             else
%                 x_center=(slope12*slope23*(point1(1,2)-point3(1,2))+slope23*(point1(1,1)+point2(1,1))-slope12*(point2(1,1)+point3(1,1)))/(2*(slope23-slope12));
%                 midpoint12=(point1+point2)/2;
%                 midpoint13=(point1+point3)/2;
%                 y_center=(-1/slope12)*(x_center-midpoint12(1,1))+midpoint12(1,2);
%                 shape(i).nuclei(r).curvatureDist(1,j)=1/sqrt((point1(1,1)-x_center)^2+(point1(1,2)-y_center)^2);
%                 
%                 shape(i).nuclei(r).uncutCurvatureDist(1,j) = shape(i).nuclei(r).curvatureDist(1,j);
%                 if shape(i).nuclei(r).curvatureDist(1,j)>(1.9/boundaryPoint)
%                     shape(i).nuclei(r).curvatureDist(1,j)=(1.9/boundaryPoint);
%                 end
% 
%                 [In On] = inpolygon(midpoint13(1,1),midpoint13(1,2),snake(i).nuclei(r).posDist(1,:),snake(i).nuclei(r).posDist(2,:)); 
% 
%                 if ~In              
%                     shape(i).nuclei(r).curvatureDist(1,j)=-1*shape(i).nuclei(r).curvatureDist(1,j);
%                     shape(i).nuclei(r).uncutCurvatureDist(1,j)=-1*shape(i).nuclei(r).uncutCurvatureDist(1,j);
%                 end
% 
%                 if On
%                     shape(i).nuclei(r).curvatureDist(1,j)=0;
%                     shape(i).nuclei(r).uncutCurvatureDist(1,j)=0;
%                 end
% 
%             end
%         end 
%         
%         % find the net negative curvature
%         listCurve = shape(i).nuclei(r).uncutCurvatureDist;
%         listNegCurve = abs(listCurve(listCurve < 0));
%         if ~isempty(listNegCurve) 
%             shape(i).nuclei(r).sumNegCurvatureDist = sum(listNegCurve);
%         else
%             shape(i).nuclei(r).sumNegCurvatureDist = 0;
%         end
%         
%         % find the number of negative boundary curvature regions
%         curveMask = (shape(i).nuclei(r).uncutCurvatureDist < 0);
%         curveMaskLabeled = bwlabel(curveMask);
%         numTroughs = max(curveMaskLabeled);
%         if curveMask(1) && curveMask(end)
%             numTroughs = numTroughs-1;
%         end
%         shape(i).nuclei(r).numTroughs = numTroughs;
%         
%         % find the negative boundary curvature region locations
%         shape(i).nuclei(r).troughLocs=[];
%         for n = 1:shape(i).nuclei(r).numTroughs
%             curveRegionMask = (curveMaskLabeled == n);
%             [val, regLoc] = min(shape(i).nuclei(r).uncutCurvatureDist.*curveRegionMask);
%             shape(i).nuclei(r).troughLocs = [shape(i).nuclei(r).troughLocs, regLoc];
%         end
%         
%         % find the tortuosity (should correct units)
%         shape(i).nuclei(r).tort = sum(gradient(shape(i).nuclei(r).uncutCurvatureDist).^2)/shape(i).nuclei(r).perimeter;

        % shift the data so that boundary point 0 is farthest from the center
        shift = mod(shape(i).nuclei(r).maxDistanceLoc,M);
        snakeShift(i).nuclei(r).posRaw=circshift(snake(i).nuclei(r).posRaw,[0 -shift]);
        snakeShift(i).nuclei(r).posNum=circshift(snake(i).nuclei(r).posNum,[0 -shift]);
        shape(i).nuclei(r).distance=circshift(shape(i).nuclei(r).distance,[0 -shift]);
        shape(i).nuclei(r).curvatureNum=circshift(shape(i).nuclei(r).curvatureNum,[0 -shift]);
        shape(i).nuclei(r).uncutCurvatureNum=circshift(shape(i).nuclei(r).uncutCurvatureNum,[0 -shift]);
        
%        shift = mod(shape(i).nuclei(r).maxDistanceLocDist,numPoints);
%        shape(i).nuclei(r).curvatureDist=circshift(shape(i).nuclei(r).curvatureDist,[0 -shift]);
%        shape(i).nuclei(r).uncutCurvatureDist=circshift(shape(i).nuclei(r).uncutCurvatureDist,[0 -shift]);
%        snakeShift(i).nuclei(r).posDist=circshift(snake(i).nuclei(r).posDist,[0 -shift]);
        
    end
    
    % find properties of the labeled image
    imageMask = zeros(picture(i).size);
    imageGray = im2double(imread([inDirectory picture(i).name]));
    for r=1:length(shape(i).nuclei)
        regionMask = r.*poly2mask(snake(i).nuclei(r).posNum(1,:), snake(i).nuclei(r).posNum(2,:), picture(i).size(1,1), picture(i).size(1,2));
        imageMask = imageMask+regionMask;   
    end
    stats = regionprops(imageMask, imageGray, 'Eccentricity', 'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'PixelValues');
    
    % resructure those property variables
    for r=1:length(shape(i).nuclei)
        shape(i).nuclei(r).eccentricity = stats(r).Eccentricity;
        shape(i).nuclei(r).equivDiameter = stats(r).EquivDiameter;
        shape(i).nuclei(r).majorAxisLength = stats(r).MajorAxisLength;
        shape(i).nuclei(r).minorAxisLength = stats(r).MinorAxisLength;
        shape(i).nuclei(r).intensityValues = stats(r).PixelValues;
        shape(i).nuclei(r).meanIntensity = mean(stats(r).PixelValues);
        shape(i).nuclei(r).stdIntensity = std(stats(r).PixelValues);
    end
    
end
