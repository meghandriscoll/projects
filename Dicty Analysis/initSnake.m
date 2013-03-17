%%%%%%%%%%%%%%%% FIND SNAKE %%%%%%%%%%%%%%%%

% Finds the nuclei boundaries using a snake algorithm. This program requires 
% code found in sdemo (Prince and Xu). The snake algorithm is initialized with 
% the convex hulls outputted by findConvexHull.m 

function snake = findSnake(N, picture, minRegionSize, imageAdjustSize, inDirectory, savePath)

%%%% image processing variables %%%%
global Image1;						% original image
global Image2;                      % gradient of image
global sigma;
global mu alpha beta gamma kappa;   % parameters for the snake
global dmin dmax;                   % parameters for the snake
global NoGVFIterations;				% number of GVF iterations
global NoSnakeIterations;           % number of Snake iterations
global SchangeInFieldType;
global VectorFieldButt;				% define the type of vector filed
global SnakeON;						% indicate if snake is visible
global IncSnakeRadius;				% inicializaton snake radius
global CircleOn;					% inicalization snake will be circle
global SnakeDotsON;                 % 1 if snake dots should be displeyed
global GradientOn;					% 1 if gradient is applayed with blur
global px py;                       % gvf force field
global XSnake YSnake;				% contour of the snake
global cellPrim;                    % cell perimeter

sigma=0;
mu=0.1;
alpha=0.05;
beta=0.01;
gamma=1;
kappa=0.6;			
dmin=0.5;
dmax=2;
SchangeInFieldType=1;

NoGVFIterations=80;
NoSnakeIterations=500;

VectorFieldButt(1)=0;				% standard field
VectorFieldButt(2)=1;				% GVF filed
VectorFieldButt(3)=0;				% normalized GVF
SnakeON=0;							% snake is not drown on the picture at the begining
IncSnakeRadius=0.5;

CircleOn=1;
SnakeDotsON=1;
GradientOn=1;

EquidistantNum = 400;
width = 5; 

% Add the tools to the current path
p = path;
%path(p,'/Users/meghandriscoll/Desktop/Snake/Nucleus Analysis/snakeTools');
path(p,'./snakeTools');

% iterate through each image
for i=1:1
    display(['  processing image ' num2str(i)])

    % read image and nearly binarize it
    Image1 = makeNBW(inDirectory, picture(i).name, imageAdjustSize);
    
    % add a border to the image
    Image1 = makeBorder(Image1, width);
    
    % find image gradient
    Image2 = abs(gradient2(Image1));

    % calculate the gradient vector field
    [px,py] = GVF(Image2, mu, NoGVFIterations);

    % iterate through each nuclei
    for r = 1:length(picture(i).CHstats)
        % display(['    nuclei ' num2str(r)])
        
        % set snake initialization
        XSnake = picture(i).CHstats(r).ConvexHull(:,1);
        YSnake = picture(i).CHstats(r).ConvexHull(:,2);
        
        % deform the snake
        [x,y] = snakeinterp(XSnake,YSnake,dmax,dmin);
        for j=1:ceil(NoSnakeIterations/5)
           if j<=floor(NoSnakeIterations/5)
              [x,y] = snakedeform(x,y,alpha,beta,gamma,kappa,px,py,5);
           else 
              [x,y] = snakedeform(x,y,alpha,beta,gamma,kappa,px,py,NoSnakeIterations-floor(NoSnakeIterations/5)*5);
           end;
           [x,y] = snakeinterp(x,y,dmax,dmin);
        end
        XSnake = x; YSnake = y;
        
        % save raw snake data
        snake(i).nuclei(r).posRaw = [XSnake';YSnake']-width;
        
        % save equidistant boundary points snake data
        [snake(i).nuclei(r).posDist(1,:), snake(i).nuclei(r).posDist(2,:)] = snakeinterp1(XSnake,YSnake,dmin);
        snake(i).nuclei(r).posDist = snake(i).nuclei(r).posDist-width;
        
        % save same number of boundary points snake data
        PrimTest();
        SameDistRes = cellPrim/EquidistantNum; 
        [snake(i).nuclei(r).posNum(1,:), snake(i).nuclei(r).posNum(2,:)] = snakeinterp1(XSnake,YSnake,SameDistRes);
        snake(i).nuclei(r).posNum = snake(i).nuclei(r).posNum-width;
        
        % remove any snake that tries to cross into the border, or that
        % colapses to zero.
        
    end
end

size(snake(1).nuclei(2).posRaw)
snake(i).nuclei(r).posRaw
figure;
plot(snake(i).nuclei(r).posRaw(1,:), snake(i).nuclei(r).posRaw(2,:), 'Color','r')
hold on

size(snake(1).nuclei(2).posDist)
snake(i).nuclei(r).posDist
plot(snake(i).nuclei(r).posDist(1,:), snake(i).nuclei(r).posDist(2,:), 'Color','g')
hold on

size(snake(1).nuclei(2).posNum)
snake(i).nuclei(r).posNum
plot(snake(i).nuclei(r).posNum(1,:), snake(i).nuclei(r).posNum(2,:), 'Color','b')


% list of things to do
%  seperate out the called files by renaming them with an N suffix.  The
%  rewrite Ilya's.  Rename some variables