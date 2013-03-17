%%%%%%%%%%%%%%%% SELECT SNAKES %%%%%%%%%%%%%%%%

% Allow the user to select blobs to remove from further analysis.

% Inputs:             
%  N                    - the number of images
%  remove               - options: 'begin', 'continue', 'startAt' 
%  startAt              - if remove is set to continue will start at the frame specified by startAt
%  endAt                - the maximum frame to check (will only actually be checked if it, plus one, is a multiple of checkEveryNth)
%  checkEveryNth        - only select snakes in frames checkEveryNth apart (measured in frames)
%  removeRange          - frame range over which selected snakes are removed (centered at the clicked on frame and so must be an odd integer)
%  saveEvery            - saves every saveEvery time that a frame is checked (so, overall, every checkEveryNth*saveEvery frame)
%  inDirectory          - directory the original images are stored in 
%  savePath             - directory the binarized, labeld images are stored in
%
% Saves:
%  params
%   .selectSnakeFrame   - set to the number of the last frame checked
%  blob                 - .removed is set to 1 for snakes that are pinched, new snakes are initiated
%  frame2blob           - a cell array of size {1,number of frames}, each cell lists the IDs of the non-removed blobs in that frame
%  blobManRemove        - the same structures as blob and frame2blob, but this variable will not be overwritten by other programs

function selectSnakes(N, remove, startAt, endAt, checkEveryNth, removeRange, saveEvery, inDirectory, savePath)

% load saved variables
load([savePath 'parameters']); % load parameters (including params.selectSnakeFrame)
load([savePath 'boundaries']); % frame info (loads picture)

% check the variable 'remove' to find the start frame
if strcmp('begin', remove) % begin manually removing snakes at the beginning of the movie
    params.selectSnakeFrame = 1;
    load([savePath 'blobAutoRemove']); % load tracked  boundaries (loads blob and frame2blob)

elseif strcmp('continue', remove) % continue manually removing snakes
    if isfield(params, 'selectSnakeFrame') % if frames have been previously checked
        params.selectSnakeFrame = params.selectSnakeFrame + checkEveryNth;
        load([savePath 'blob']); % load tracked  boundaries (loads blob and frame2blob)
    else
       params.selectSnakeFrame = 1; % if frames have not been previously checked
       load([savePath 'blobAutoRemove']);
    end
    
elseif strcmp('continueAt', remove) % start removing snakes at a specific frame
    if startAt >= 1 && startAt <= N % check to ensure startAt is a valid frame
        params.selectSnakeFrame = round(startAt);
        load([savePath 'blob']); % load tracked  boundaries (loads blob and frame2blob)
    else
        disp(['   Error: ' num2str(startAt) ' is not a valid start frame.']);
    end
    
else % the user has entered an invalid option for remove
    disp('   Error:  that is not a valid option for the variable remove.')
end

% define a colormap for the snake colors
colors = colormap(hsv(256));

% find the smallest freeID
freeID = length(blob)+1;

% iterate through the frames
fig=figure;
axis image
axis off
checkCounter=0;
for i=params.selectSnakeFrame:checkEveryNth:min([N, endAt])

    % plot the background image
    imshow(im2double(imread([inDirectory picture{i}.name])))
    
    % load the binary, labeled image (called 'labeled')
    load([savePath 'labeledImages/image' picture{i}.number]);
    
    % plot the boundaries
    region2ID = zeros(1,max(max(labeled))); % will give the ID of the blob at the label corresponding to the index
   
    for r = 1:length(frame2blob{1,i})
        
        % get blob ID, and set region2ID
        ID = frame2blob{1,i}(r);
        region2ID(1,blob{ID}.labels(i-blob{ID}.startFrame+1)) = ID;
        
        % set the blob color
        blobColor=colors(mod(ID^2+100,255)+1,:);
        
        % plot the blob
        if blob{ID}.removed ~= 1
            hold on
            plot(blob{ID}.snakeNum(i-blob{ID}.startFrame+1,:,1),blob{ID}.snakeNum(i-blob{ID}.startFrame+1,:,2), 'LineWidth', 1.5, 'Color', blobColor)
        end
    end
    hold off
                 
    % titles the figure
    toTitle = ['Click to select regions for removal.  Enter to go to the next image. ' '(Image Number ' num2str(picture{i}.number) ')'];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % gets points for region removal
    [toRemove(i).y, toRemove(i).x] = getpts(fig);

    % remove regions
    for m=1:length(toRemove(i).x)
        badRegion = labeled(round(toRemove(i).x(m)), round(toRemove(i).y(m)));
        [blob, frame2blob, freeID] = cutBlob(blob, frame2blob, removeRange, region2ID(1,badRegion), freeID, i);        
        blob{region2ID(1,badRegion)}.removed = 1;
    end
    
    % update the current frame
    params.selectSnakeFrame = i;
    
    % save the variables  (only save every saveEvery selections)
    checkCounter=checkCounter+1;
    if mod(checkCounter,saveEvery)==0
        save([savePath 'parameters'], 'params'); 
        save([savePath 'blob'],'blob', 'frame2blob');
    end
  
end
close(fig)

% save a backup copy of blob
save([savePath 'blobManRemove'],'blob', 'frame2blob');

%%%%%%% Cut Blob %%%%%%%
function [blob, frame2blob, freeID] = cutBlob(blob, frame2blob, removeRange, oldID, freeID, frameNum)

% initiate the first section of the cut track (if the cut doesn't occur at the beginning)
if frameNum > blob{oldID}.startFrame+(removeRange-1)/2
    blob{freeID}.startFrame = blob{oldID}.startFrame;
    blob{freeID}.endFrame = frameNum-(removeRange-1)/2-1;
    blob{freeID}.clump = blob{oldID}.clump;
    blob{freeID}.labels = blob{oldID}.labels(1:frameNum-(removeRange-1)/2-1-blob{oldID}.startFrame+1);
    blob{freeID}.area = blob{oldID}.area(1:frameNum-(removeRange-1)/2-1-blob{oldID}.startFrame+1);
    blob{freeID}.solidity = blob{oldID}.solidity(1:frameNum-(removeRange-1)/2-1-blob{oldID}.startFrame+1);
    blob{freeID}.removed = blob{oldID}.removed;
    blob{freeID}.snakeNum = blob{oldID}.snakeNum(1:frameNum-(removeRange-1)/2-1-blob{oldID}.startFrame+1,:,:);
    
    % initialize and update snakeDist
    blob{freeID}.snakeDist = cell(1,blob{freeID}.endFrame-blob{oldID}.startFrame+1);
    for f=1:(frameNum-(removeRange-1)/2-1-blob{oldID}.startFrame+1)
        blob{freeID}.snakeDist{1,f} = blob{oldID}.snakeDist{1,f};
    end
    
    % update frame2blob
    for f = blob{freeID}.startFrame:blob{freeID}.endFrame
        frame2blob{1,f} = [frame2blob{1,f}, freeID];
    end
    
    freeID = freeID+1;
end

% initiate the second section of the cut track (if the cut doesn't occur at the end)
if frameNum < blob{oldID}.endFrame-(removeRange-1)/2
    blob{freeID}.startFrame = frameNum+(removeRange-1)/2+1; % time is in i (frameNum) space
    blob{freeID}.endFrame = blob{oldID}.endFrame;
    blob{freeID}.clump = blob{oldID}.clump;
    blob{freeID}.labels = blob{oldID}.labels(frameNum+(removeRange-1)/2+1-blob{oldID}.startFrame+1:end); 
    blob{freeID}.area = blob{oldID}.area(frameNum+(removeRange-1)/2+1-blob{oldID}.startFrame+1:end);
    blob{freeID}.solidity = blob{oldID}.solidity(frameNum+(removeRange-1)/2+1-blob{oldID}.startFrame+1:end);
    blob{freeID}.removed = blob{oldID}.removed;
    blob{freeID}.snakeNum = blob{oldID}.snakeNum(frameNum+(removeRange-1)/2+1-blob{oldID}.startFrame+1:end,:,:);
    
    % initialize and update snakeDist
    blob{freeID}.snakeDist = cell(1,length(blob{oldID}.snakeDist)-(blob{freeID}.startFrame-blob{oldID}.startFrame+1));
    for f=1:(length(blob{oldID}.snakeDist)-(blob{freeID}.startFrame-blob{oldID}.startFrame+1)+1)
        blob{freeID}.snakeDist{1,f} = blob{oldID}.snakeDist{1,f-1+blob{freeID}.startFrame-blob{oldID}.startFrame+1};
    end
    
    % update frame2blob
    for f = blob{freeID}.startFrame:blob{freeID}.endFrame
        frame2blob{1,f} = [frame2blob{1,f}, freeID];
    end
    
    freeID = freeID+1;
end
