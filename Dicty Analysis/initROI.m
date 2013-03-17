%%%%%%%%%%%%%%%% INITIALIZE ROI %%%%%%%%%%%%%%%%
%
% Determine which tracks are inside or outside the ROI and when they are. 
%
% Inputs:
%  N                - the number of images
%  useROI           - 1 if an ROI is being used, 0 otherwise
%  savePath         - the directory where data is saved
%
% Saves:
%  shape            
%   .inROI             - 1 if the snake is inside the ROI, 0 if on the ROI polygon, and -1 if outside the ROI
%   .startFrameInROI
%   .endFrameInROI
%   .startFrameOutROI
%   .endFrameOutROI
%   .durationInROI
%   .durationOUtROI
%  frame2inROI        - a cell array of size {1,number of frames}, each cell lists the IDs of the shapes that are inside the ROI in that frame
%  frame2outROI       - a cell array of size {1,number of frames}, each cell lists the IDs of the shapes that are outside the ROI in that frame


function initROI(N, useROI, savePath)

% if an ROI is in use
if useROI 

    % load saved variables
    load([savePath 'parameters']); % parameters (loads the roi, params.roiMask)
    load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)
    
    % initialize variables
    frame2inROI = cell(1, N); 
    frame2outROI = cell(1, N); 
    
    % iterate through the frames
    for i=1:N
        
        % display progress update
        if mod(i, 10) == 0
            disp(['   frame ' num2str(i)]);
        end
        
        % make a mask (labeled by ID) of all the shapes in a frame
        [m,n] = size(params.roiMask); % m an n could be confused here
        imageMask = zeros(m,n);
        for r=1:length(frame2shape{1,i})
            ID = frame2shape{1,i}(r);
            f = i-shape(ID).startFrame+1;
            shapeMask = poly2mask(shape(ID).snake(f,:,1), shape(ID).snake(f,:,2), m, n);
            imageMask = imageMask + ID*shapeMask;
        end
        
        % determine which shapes are in or out of the ROI
        partInROI = unique(params.roiMask.*imageMask); % shapes that are at least partially in the ROI
        partOutROI = unique((~params.roiMask).*imageMask); 
        inROI = setdiff(partInROI, partOutROI); % shapes that are entirely in the ROI
        outROI = setdiff(partOutROI, partInROI);
        inROI = intersect(inROI, frame2shape{1,i}); % in case shapes overlap and sum to false IDs
        outROI = intersect(outROI, frame2shape{1,i});
        
        % iterate through snakes that are inside the ROI
        for r = 1:length(inROI)
            shape(inROI(r)).inROI(i-shape(inROI(r)).startFrame+1) = 1;
            frame2inROI{1,f} = [frame2inROI{1,f}, inROI(r)];
        end
    
        % iterate through snakes that are outside the ROI
        for r = 1:length(outROI)
            shape(outROI(r)).inROI(i-shape(outROI(r)).startFrame+1) = -1;
            frame2outROI{1,f} = [frame2outROI{1,f}, outROI(r)];
        end
     
    end
    
    % iterate through the shapes to determine when shapes enter and exit the ROI
    for s=1:length(shape)

        % display progress update
        if mod(s, 10) == 0
            disp(['   ' num2str(s) ' of ' num2str(length(shape)) ' shapes']);
        end
        
        % initialize variables
        shape(s).startFrameInROI=[]; shape(s).endFrameInROI=[];
        shape(s).startFrameOutROI=[]; shape(s).endFrameOutROI=[];
        
        % walk through inROI to find enters and exits from the ROI
        lastInROI = 0; % the previous value of inROI
        for f=1:length(shape(s).inROI)
            
            % start an inside ROI track
            if lastInROI~=1  && shape(s).inROI(f)==1
                shape(s).startFrameInROI = [shape(s).startFrameInROI, f+shape(s).startFrame-1];
                shape(s).endFrameInROI = [shape(s).endFrameInROI, f+shape(s).startFrame-1];   
            
            % continue an inside ROI track
            elseif lastInROI==1  && shape(s).inROI(f)==1
                shape(s).endFrameInROI(end) = f+shape(s).startFrame-1;
            
            % start an outside ROI track
            elseif lastInROI~=-1  && shape(s).inROI(f)==-1
                shape(s).startFrameOutROI = [shape(s).startFrameOutROI, f+shape(s).startFrame-1];
                shape(s).endFrameOutROI = [shape(s).endFrameOutROI, f+shape(s).startFrame-1];
            
            % continue an outside ROI track
            elseif lastInROI==-1  && shape(s).inROI(f)==-1
                shape(s).endFrameOutROI(end) = f+shape(s).startFrame-1;
            end
            
            % update lastInROI
            lastInROI = shape(s).inROI(f);
        end
        
        % find the inROI and outROI durations
        shape(s).durationInROI = shape(s).endFrameInROI-shape(s).startFrameInROI+1;
        shape(s).durationOutROI = shape(s).endFrameOutROI-shape(s).startFrameOutROI+1;
    end
    
    % save the variables
    save([savePath 'shape'],'shape', 'frame2shape');
    save([savePath 'roi'],'frame2inROI', 'frame2outROI');

end

