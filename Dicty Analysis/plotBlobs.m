%%%%%%%%%%%%%%%% PLOT BLOBS %%%%%%%%%%%%%%%%

% Plot the convex hulls of the tracked blobs on images and saves the images 
% in a directory in 'savePath'.  Plots all blobs, even those that have been
% removed.

% Inputs:            
%  N                - the number of images
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images overlaid by the tracked convex hulls in the
% 'trackedBlobs' directory of 'savePath'

function plotBlobs(N, inDirectory, savePath)

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)
load([savePath 'blob']); % tracked approximate boundaries (loads blob and frame2blob)

% make a directory to save the images in 
mkdir([savePath 'trackedBlobs'])

% define a colormap for the blob colors
colors = colormap(hsv(256));

%%%%% plot an image sequence of tracked blobs %%%%%
% iterate through the frames
figure;
for i=1:N

    % plot the background image
    imshow(im2double(imread([inDirectory picture{i}.name])))

    % plot the blobs
    for r = 1:length(frame2blob{1,i})
        
        % get blob info
        ID = frame2blob{1,i}(r);
        label = blob{ID}.labels(i-blob{ID}.startFrame+1);
        
        % set the blob color
        blobColor = colors(mod(ID^2+100,255)+1,:);
        
        % plot the blob's convex hull
        hold on
        %plot(picture{i}.CHSstats(label).ConvexHull(:,1), picture{i}.CHSstats(label).ConvexHull(:,2), 'LineWidth', 1, 'Color', blobColor)
        plot(picture{i}.boundary{label}(:,2), picture{i}.boundary{label}(:,1), 'LineWidth', 2, 'Color', blobColor)
 
    end
    hold off
    axis image
    axis off
    
    % titles the figure
    toTitle = ['Image Number ' num2str(i)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % pause to allow the user to adjust the figure size
    if i==1
        pause(10); 
    end
    
    % saves the figure
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/trackedBlobs/Tracked_' num2str(i) '.tif'],'tif','Compression','none');
end

%%%%% plot a single tracked blobs plot %%%%%
% % iterate through all of the blobs
% figure;
% for b=1:length(blob)
%     
%     % check to see if the blob has been removed
%     if ~blob(b).removed
%         
%         % set the blob color
%         blobColor=colors(mod(b^2+100,255)+1,:);
% 
%         % iterate through all the frames that the blob is in
%         for i=blob(b).startFrame:1:blob(b).endFrame
%            plot(picture{i}.boundary{blob(b).labels(i-blob(b).startFrame+1)}(:,2), picture{i}.boundary{blob(b).labels(i-blob(b).startFrame+1)}(:,1), 'LineWidth', 1, 'Color', blobColor);
%            hold on
%         end
%         
%     end
% end
% hold off
% axis image
% axis equal
% axis off
% 
% % titles the figure
% toTitle = ['Blobs Numbered ' num2str(length(blob))];
% title(toTitle, 'Color', 'k', 'FontName', 'Arial');
% 
% % saves the figure
% pause(0.1)
% imw=getframe(gcf);
% imwrite(imw.cdata(:,:,:),[savePath '/blobs/blob_' num2str(length(blob)) '.tif'],'tif','Compression','none');
