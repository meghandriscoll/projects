%%%%%%%%%%%%%%%% FIND SNAKE %%%%%%%%%%%%%%%%

% Finds the blob boundaries using a snake algorithm. This program requires 
% code found in sdemo (Prince and Xu). The snake algorithm is initialized with 
% the convex hulls outputted by findBoundaries.m 
%
% Inputs:
%  inDirectory      - the directory in which the images are stored
%  There are many parameters used in these m-file. They're listed in shapes.m.
%
% Saves:
%  blob(ID)
%   .snakeRaw       - snaked boundary point positions (the raw output of the snake algorithm)
%   .snakeNum       - snaked boundary point positions (a constant number of boundary points, EquidistantNum, per frame)
%   .snakeDist      - snaked boundary point positions (equidistant boundary points throughout the entire movie)
%  M                - the number of boundary points in snakeNum plus one

function findSnake(inDirectory, savePath)

% load saved variables
load([savePath 'parameters']); % parameters (loads N and params)
load([savePath 'boundaries']); % frame info (loads picture)
load([savePath 'blob']); % tracked approximate boundaries (loads blob and frame2blob)

% %%%%% Xu and Prince Snaking Parameters %%%%%
global XSnake YSnake;		% contour of the snake
global cellPrim;            % cell perimeter
% 
% mu=0.1;
% alpha=0.00002;              % alpha and beta are the tension and rigidity
% beta=0.00005;
% gamma=1;
% kappa=0.6;			
% dmin=0.5;                   % the minimum number of pixels seperating boundary points after interpolation
% dmax=1.5;                   % the maximum number of pixels seperating boundary points after interpolation
% 
% NoGVFIterations = 80;       % the number of iterations used to calculate the gradient vector field of the image
% EquidistantNum = 100;       % the number of boundary points per blob outputted by the 'posNum' variable (usually 400)
% widthImageB = 6;            % the width, in pixels, of the border added to each frame (must be larger than widthCellB)
% widthCellB = 5;             % the effective width, in pixels, of the border added to each blob's image
% 
% %%%% Other Snaking Parameters %%%%
% binLowerThresh = 0.7;       % the lower threshold when nearly binarizing the image (multiplied by the automatically calculated binarization threshold)
% binUpperThresh = 1.1;       % the upper threshold when nearly binarizing the image (multiplied by the automatically calculated binarization threshold)
% blobGamma = 0.6;            % the adjusted gamma of the nearly binarized image
% numIterFirst = 40;          % the number of initial snake iterations
% numIterEvery = 25;          % the number of subsequent snake iterations performed in every loop before checking convergence
% convergeThresh = 4;         % the maximum area, in pixels, per loop that is considered converged
% runLimit = 16;              % the maximum number of iteration loops run
% % numIterFirst, numIterEvery, convergeThresh, and runLimit greatly affect the code speed

%%%%% Why does the error message sometimes repeat itself????? %%%%%%%%

% Add the snake tools to the current path
p = path;
path(p,'./snakeTools');

% iterate through each image
for i=1:N
    display(['   image ' num2str(i)])
    
    % read image
    image = im2double(imread([inDirectory picture(i).name]));
    image = imadjust(image);  % the image must be adjusted prior to the addition of the border

    % add a border to the image
    image = makeBorder(image, params.widthImageB);
    
    % iterate through each blob
    for b = 1:length(frame2blob{1,i})
        
        % find the region label
        ID = frame2blob{1,i}(b);
        r = blob(ID).labels(i-blob(ID).startFrame+1);
        
        % construct an image of just the wanted nuclei and adjust the histogram
        bounds = picture(i).CHLstats(r).BoundingBox;
        imageRegion = image(round(bounds(2)):round(bounds(2)+bounds(4)+params.widthImageB+params.widthCellB),round(bounds(1)):round(bounds(1)+bounds(3)+params.widthImageB+params.widthCellB));
        imageRegion = imadjust(imageRegion);
        
        %%%% why does this work ?????, the r's shouldn't match!!!!!!!!!!!! %%%% 
        % using the outer convex hull, mask away unwanted nearby data
        cellMask = poly2mask(picture(i).CHLstats(r).ConvexHull(:,1)+params.widthImageB-bounds(1)+1,picture(i).CHLstats(r).ConvexHull(:,2)+params.widthImageB-bounds(2)+1,bounds(4)+params.widthImageB+params.widthCellB+1,bounds(3)+params.widthImageB+params.widthCellB+1);  
        imageBlob = imageRegion.*cellMask;
                
        % nearly binarize the image
        bwLevel = graythresh(imageBlob);
        imageBlob = imadjust(imageBlob,[params.binLowerThresh*bwLevel; params.binUpperThresh*bwLevel],[0,1],params.blobGamma);
        
        % fill holes
        imageBlob = imfill(imageBlob);
        
        % find image gradient
        Image2 = abs(gradient2(imageBlob));

        % calculate the gradient vector field
        [px,py] = GVF(Image2, params.mu, params.NoGVFIterations);
        
        % set snake position initialization
        XSnake = picture(i).CHSstats(r).ConvexHull(:,1)+params.widthImageB-bounds(1)+1;
        YSnake = picture(i).CHSstats(r).ConvexHull(:,2)+params.widthImageB-bounds(2)+1;
        [x,y] = snakeinterp(XSnake,YSnake,params.dmax,params.dmin);
        
        % deform the snake
        [x,y] = snakedeform(x,y,params.alpha,params.beta,params.gamma,params.kappa,px,py,params.numIterFirst); % the number of iterations affects the code's speed
        [x,y] = snakeinterp(x,y,params.dmax,params.dmin);
        xLast = x; yLast = y; change = Inf; runs=0;
        
        % if the snake hasn't converged, keep deforming
        while change >= params.convergeThresh % this affects the code's speed
            [x,y] = snakedeform(x,y,params.alpha,params.beta,params.gamma,params.kappa,px,py,params.numIterEvery); % the number of iterations affects the code's speed
            [x,y] = snakeinterp(x,y,params.dmax,params.dmin);
            
            % check the snakes's convergence
            old = poly2mask(xLast, yLast, bounds(4)+params.widthImageB+params.widthCellB+1, bounds(3)+params.widthImageB+params.widthCellB+1);
            new = poly2mask(x, y, bounds(4)+params.widthImageB+params.widthCellB+1, bounds(3)+params.widthImageB+params.widthCellB+1);
            change = sum(sum(xor(old, new)));
            xLast = x; yLast = y;
            runs=runs+1;
            
            % stop if the snake has been converging for too long
            if runs > params.runLimit % this affects the code's speed
                display(['      Error: the snake did not converge. (Frame ' num2str(i) ', Blob ' num2str(r) ')']);
                break
            end  
        end
        [x,y] = snakeinterp(x,y,params.dmax/2,params.dmin/2);
        [x,y] = snakedeform(x,y,params.alpha,params.beta,params.gamma,params.kappa,px,py,params.numIterEvery);
        [x,y] = snakeinterp(x,y,params.dmax/2,params.dmin/2);
        XSnake = x; YSnake = y;
        
        % initialize blob for the same number snake data
        if i == blob(ID).startFrame
            blob(ID).snakeRaw = cell(1, blob(ID).endFrame-blob(ID).startFrame+1);
            blob(ID).snakeDist = cell(1, blob(ID).endFrame-blob(ID).startFrame+1);
            blob(ID).snakeNum = zeros(blob(ID).endFrame-blob(ID).startFrame+1,params.EquidistantNum, 2);
        end
        
        % save raw snake data
        rawX = XSnake'-params.widthImageB+bounds(1);
        rawY = YSnake'-params.widthImageB+bounds(2);
        blob(ID).snakeRaw{1,i-blob(ID).startFrame+1} = [rawX; rawY];
        
        % save equidistant boundary points snake data
        [distX, distY] = snakeinterp1(XSnake,YSnake,params.dmin);
        distX = distX-params.widthImageB+bounds(1);
        distY = distY-params.widthImageB+bounds(2);
        blob(ID).snakeDist{1,i-blob(ID).startFrame+1} = [distX; distY];
        
        % save same number of boundary points snake data
        PrimTest();
        SameDistRes = cellPrim/params.EquidistantNum; 
        [numX, numY] = snakeinterp1(XSnake,YSnake,SameDistRes);
        blob(ID).snakeNum(i-blob(ID).startFrame+1,:,1) = numX-params.widthImageB+bounds(1);
        blob(ID).snakeNum(i-blob(ID).startFrame+1,:,2) = numY-params.widthImageB+bounds(2);
        
    end
end

% define M
M=params.EquidistantNum+1;

% save the variables
save([savePath 'parameters'],'N', 'M', 'params');
save([savePath 'blob'],'blob', 'frame2blob');