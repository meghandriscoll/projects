%%%%%%%%%%%%%%%% PLOT MEASURES ON IMAGES %%%%%%%%%%%%%%%%

% Plots the extracted shapes, colored by a measure, on images and saves the 
% images in the plotMeasure directory in 'savePath'.

% Inputs:
%  plotMeasure      - sets the measure
%                       options: 'curvature' - the curvature at each boundary point
%                                'shape'  - the distance from each boundary point to the centroid 
%                                'motion' - the cut local motion measure
%                                'roi' - blue if in the ROI, red if outside, and green if on boundary
%                                'centroid' - plots the centroid
%                                'frontBack' - shows the extracted front (red) and back (blue) of the shape
%  background       - sets the background
%                       options: 0 - white background
%                                1 - image background
%                                2 - accumulating image, no background
%  N                - the number of images
%  shape            - contains boundary point and shape measure information
%  picture          - contains frame information
%  inDirectory      - directory the original images are stored in 
%  savePath         - directory the outputed images are saved in

% Outputs: Saves images overlaid by colored boundaries in the plotMeasure directory of 'savePath'

function plotMeasuresOnImage(plotMeasure, background, N, M, frameDelta, downSampleOutline, inDirectory, savePath)

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)
load([savePath 'shape']); % tracked  shapes (loads shape and frame2shape)

% determine the measure
if ~( strcmp(plotMeasure, 'curvature') || strcmp(plotMeasure, 'shape') || strcmp(plotMeasure, 'motion') || ...
      strcmp(plotMeasure, 'roi') || strcmp(plotMeasure, 'centroid') || strcmp(plotMeasure, 'frontBack'))
    display(['Error: ' plotMeasure ' is not a valid measure']);
end

% make a directory to save the images in
mkdir([savePath plotMeasure])

% establish a colormap and reshape the measure and positions
outlineCmin = Inf; outlineCmax = -1*Inf; 
outline = [];
for s=1:length(shape)

    % the measure is curvature
    if strcmp(plotMeasure, 'curvature') 
        
        % iterate through each frame in which the snake appears
        for f = 1:shape(s).duration
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).snake(label).measure = [shape(s).curvature(f,:), shape(s).curvature(f,1)]; % complete the polygon by appending an extra measure value
            outline(frame).snake(label).positions = shape(s).snake(f,:,:);
            
            % update the min and max for the colormap
            outlineCmin = min([outlineCmin', outline(frame).snake(label).measure]);
            outlineCmax = max([outlineCmax', outline(frame).snake(label).measure]);
        end
        
        % establish colormap
        outlineCmap=colormap(jet(256)); 
        outlineCrange=outlineCmax-outlineCmin;
        
    % the measure is shape
    elseif strcmp(plotMeasure, 'shape') 
        
        % iterate through each frame in which the snake appears
        for f = 1:shape(s).duration
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).snake(label).measure = [shape(s).distance(f,:), shape(s).distance(f,1)]; % complete the polygon by appending an extra measure value
            outline(frame).snake(label).positions = shape(s).snake(f,:,:);
            
            % update the min and max for the colormap
            outlineCmin = min([outlineCmin', outline(frame).snake(label).measure]);
            outlineCmax = max([outlineCmax', outline(frame).snake(label).measure]);
        end
        
        % establish colormap
        outlineCmap=colormap(jet(256)); 
        outlineCrange=outlineCmax-outlineCmin;
        
    % the measure is motion
    elseif strcmp(plotMeasure, 'motion') 
        
        % iterate through each frame in which the snake appears
        
        for f = 1:(shape(s).duration-frameDelta)
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).snake(label).measure = [shape(s).cutMotion(f,:), shape(s).cutMotion(f,1)]; % complete the polygon by appending an extra measure value
            outline(frame).snake(label).positions = shape(s).snake(f,:,:);
            
            % update the min and max for the colormap
            outlineCmin = min([outlineCmin', outline(frame).snake(label).measure]);
            outlineCmax = max([outlineCmax', outline(frame).snake(label).measure]);
        end
        
        % establish colormap
        outlineCmap=colormap(jet(256)); 
        outlineCrange=outlineCmax-outlineCmin;
    
    % the measure is roi
    elseif strcmp(plotMeasure, 'roi') 
        for f = 1:shape(s).duration
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).measure(label) = shape(s).inROI(f); 
            outline(frame).snake(label).positions = shape(s).snake(f,:,:);
        end
        
        % establish colormap
        outlineCmap=colormap(hsv(3)); 
        
    % the measure is centroid
    elseif strcmp(plotMeasure, 'centroid') 
        for f = 1:shape(s).duration
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).measure(label) = mod(s^2+100,255)+1; % sets the centroid color
            outline(frame).snake(label).positions = shape(s).centroid(f,:);
        end
        
        % establish colormap
        outlineCmap=colormap(hsv(256)); 
        
    % the measure is frontBack
    elseif strcmp(plotMeasure, 'frontBack') 
        for f = 1:shape(s).duration-frameDelta
            frame = f+shape(s).startFrame-1;
            label = shape(s).regions(f);
            outline(frame).measure(label).front = shape(s).front(f); 
            outline(frame).measure(label).back = shape(s).back(f); 
            outline(frame).snake(label).positions = shape(s).snake(f,:,:);
        end
    
    end
        
end

% only display images up through N-deltaFrame for motion related measures
if strcmp(plotMeasure, 'motion') || strcmp(plotMeasure, 'frontBack')
    N=N-frameDelta; 
end

% sets the figure background color
figure;
axis image
axis off
scrsz = get(0,'ScreenSize');
f=figure('Position',[5*scrsz(4)/12 2*scrsz(4)/3 scrsz(3)/2 2*scrsz(4)/3]);
set(f, 'Color', 'w');

% make the image still if there is no background
[imageRows, imageCols] = size(imread([inDirectory picture{1}.name]));
imageWhite = ones(imageRows+5, imageCols+5);
if background == 2
    imshow(imageWhite);
    hold on
end

% plots the frames

for i=1:N

    % plot the background image
    if background == 0
        imshow(imageWhite)
        hold on
    elseif background == 1
        imshow(im2double(imread([inDirectory picture{i}.name])))
        hold on
    end

    % plot the snake boundaries
    for r = 1:length(outline(i).snake)
        
        if (strcmp(plotMeasure, 'curvature')  || strcmp(plotMeasure, 'shape') || strcmp(plotMeasure, 'motion')) && ~isempty(outline(i).snake(r).positions)
            % plot colored lines between boundary points
            for j=randperm(floor((M-1)/downSampleOutline)-1)
                index=round(mean(outline(i).snake(r).measure(j*downSampleOutline:(j+1)*downSampleOutline)-outlineCmin)*255/outlineCrange)+1;
                hold on
                line([outline(i).snake(r).positions(1,j*downSampleOutline,1) outline(i).snake(r).positions(1,(j+1)*downSampleOutline,1)],[outline(i).snake(r).positions(1,j*downSampleOutline,2) outline(i).snake(r).positions(1,(j+1)*downSampleOutline,2)],'Color',outlineCmap(index,:),'LineWidth',1);
            end

            % draw a complete polygon
            index=round(mean([outline(i).snake(r).measure(1:downSampleOutline), outline(i).snake(r).measure(floor(((M-1)/downSampleOutline))-1:end)]-outlineCmin)*255/outlineCrange)+1;
            line([outline(i).snake(r).positions(1,floor(((M-1)/downSampleOutline))*downSampleOutline,1) outline(i).snake(r).positions(1,downSampleOutline,1)],[outline(i).snake(r).positions(1,floor(((M-1)/downSampleOutline))*downSampleOutline,2) outline(i).snake(r).positions(1,downSampleOutline,2)],'Color',outlineCmap(index,:),'LineWidth',1);
        
        elseif strcmp(plotMeasure, 'roi') 
            index = outline(i).measure(r)+2;
            hold on
            plot(outline(i).snake(r).positions(1,1:downSampleOutline:end,1), outline(i).snake(r).positions(1,1:downSampleOutline:end,2), 'LineWidth', 2, 'Color', outlineCmap(index,:));
            
        elseif strcmp(plotMeasure, 'centroid') 
            hold on
            plot(outline(i).snake(r).positions(1), outline(i).snake(r).positions(2), 'Marker', '.', 'MarkerSize', 14, 'Color', outlineCmap(outline(i).measure(r),:));
            
        elseif strcmp(plotMeasure, 'frontBack') 
            hold on
            if ~isempty(outline(i).snake(r).positions)
                plot(outline(i).snake(r).positions(1,1:downSampleOutline:end,1), outline(i).snake(r).positions(1,1:downSampleOutline:end,2), 'LineWidth', 1, 'Color', 'g');
                plot(outline(i).snake(r).positions(1,outline(i).measure(r).front,1), outline(i).snake(r).positions(1,outline(i).measure(r).front,2), 'Marker', '.', 'MarkerSize', 12, 'Color', 'r');
                plot(outline(i).snake(r).positions(1,outline(i).measure(r).back,1), outline(i).snake(r).positions(1,outline(i).measure(r).back,2), 'Marker', '.', 'MarkerSize', 12, 'Color', 'b');
            end
        end
        
    end
    hold off
    
    % titles the figure
    toTitle = [plotMeasure ': Image Number ' num2str(picture{i}.number)];
    title(toTitle, 'Color', 'k', 'FontName', 'Arial');
    
    % pause to allow the user to adjust the figure size
    if i==1
        pause(10); 
    end
    
    % saves the figure
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/' plotMeasure '/' plotMeasure '_' num2str(i) '.tif'],'tif','Compression','none');
end