%%%%%%%%%%%%%%%% COUNT SHAPES %%%%%%%%%%%%%%%%
%
% Find the distribution of track lengths and the total number at each
% length
%
% Inputs:
%  motionA          - 

%
% Saves:
%  motionA          - 


function motionA = countShapes(motionA, shape, accumParams)

% create a new field if it hasn't already been created
if ~isfield(motionA, 'trackCounts') 
    motionA.trackCounts = zeros(1,1500); % the index is the duration
end

% iterate through all the shapes
for s=1:length(shape)
    motionA.trackCounts(1,shape(s).duration) = motionA.trackCounts(1,shape(s).duration) + 1;
end
    