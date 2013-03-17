%%%%%%%%%% PLOT MEASURES ON SHAPE %%%%%%%%%%

% Inputs: 
%    outline
%       Should be 0 for no outline, 1, for an outline of uniform color, or,
%       for a space-time plot like color, a matrix corresponding to some
%       boundary point measure.
%    arrow
%       Should be 0 for no arrow.  For an arrow, should be in the form
%       [arrowConnect, arrowColor, arrowNthBP, arrowStep], where arrowConnect is a 
%       matrix with that gives the boundary point that each arrow connects 
%       to, arrowColor is either 1, for a uniform arrow color, 2, for two 
%       arrow colors, or, for a space-time plot like color, a matrx 
%       corresponding to a boundary point measure, arrowNthBP displays an 
%       arrow for every arrowNthBP boundary point, and arrowStep is the 
%       time differance, in frames, between the frames connected by
%       arrowStep.
%    future
%       Should be 0 for no future outline.  For a future outline should be 
%       in the form [futureColor, futureStep], where futureColor is either 
%       1 for a uniform color or, for a space-time plot like color, a 
%       matrix corresponding to a boundary point measure, and futureStep is 
%       the time differance, in frames, between future and outline. 
%    background
%       Can be one of three possible backgrounds. 0 for white, 1 for the
%       original image, -1 for the inverted original image.
%    zoomed
%       Should be either 0 for unzoomed, or 1 for zoomed in on the cell.
%    marker
%       Should be either 0 for no markers, or 1 for markers that show the 
%       location of every 50th boundary point. The red marker indicates the
%       0th boundary point, and, as the boundary point labels increase, the
%       markers progress in ROYGBIV order.
%    scale
%       plots a scale bar 5 microns long
%    name
%       The name stamped on the top of each frame, the file names, and the
%       directory the files are stored in.



% at some point need shape(ID).motionSign

function plotMeasuresOnShape(N, M, outline, arrow, future, background, zoomed, marker, scale, name, shape, ID, picture, inDirectory, savePath)

% creates a directory for the soon to be created images
mkdir(savePath, name);

% assigns user inputted variables
arrowColor = 0; % parse the arrow inputs
arrowStep = 0;
if length(arrow) > 1
    arrowConnect = arrow{1,1};
    arrowColor = arrow{1,2};
    arrowNthBP = arrow{1,3};
    arrowStep = arrow{1,4};
end

futureColor = 0; % parse the future inputs
futureStep = 0;
if length(future) > 1
    futureColor = future{1,1};
    futureStep = future{1,2};
end

% removes infinities from outline (which shoudn't be there to begin with)
if ~min(min(isfinite(outline)))
    [rows,cols]=size(outline);
    maxOutline=max(max(outline.*isfinite(outline)));
    for i=1:rows
        for j=1:cols
            if ~isfinite(outline(i,j))
                outline(i,j)=maxOutline;
            end
        end
    end
end

% establishes any needed color maps
if length(arrowColor)>1 % arrow's colormap
    arrowCmap=colormap(jet(256));
    arrowCrange=max(max(arrowColor))-min(min(arrowColor));
    arrowCmin=min(min(arrowColor));
end

if length(outline)>1 % outline's colormap
    if length(arrowColor)>1
        outlineCmap=colormap(autumn(256));
    else
        outlineCmap=colormap(jet(256)); 
    end
    outlineCrange=max(max(outline))-min(min(outline));
    outlineCmin=min(min(outline));
end

if length(futureColor)>1 % future's colormap
    if length(arrowColor)>1 
        futureCmap=colormap(winter(256));
    elseif length(future) > 1 && futureStep == 0
        futureCmap=colormap(1-gray(256));
    else
        futureCmap=colormap(jet(256));
    end
    futureCrange=max(max(futureColor))-min(min(futureColor));
    futureCmin=min(min(futureColor));
end

% finds the colors of the boundary point indicator dots
color=colormap(hsv(10));

% color changes as time changes colormap
colors = colormap(jet(N));

% finds n, the number of frames that will be iterated over
sizes = [N, size(outline,1), size(arrowColor,1), size(futureColor,1), N-futureStep, N-arrowStep];
n = min(sizes(sizes>1));

% sets the width of figures
if zoomed
    viewSize=zeros(1,n);
    for i=1:n
        viewSize(1,i) = max(max(max(shape(ID).snake(i,:,:))-min(shape(ID).snake(i,:,:))));
    end
    width = max(viewSize)+10;
else
    width = max([shape(ID).bounds.maxx-shape(ID).bounds.minx, shape(ID).bounds.maxy-shape(ID).bounds.miny])+20;
end

% sets the figure background color
scrsz = get(0,'ScreenSize');
f=figure('Position',[5*scrsz(4)/12 2*scrsz(4)/3 scrsz(3)/2 2*scrsz(4)/3]);
if background > 0
    set(f, 'Color', 'k');
else
    set(f, 'Color', 'w');
end

% iterates over frames
for f=1:n 
    newplot
    hold on
    
    % sets the image background
    if background == 1
        image = im2double(imread([inDirectory picture(f+shape(ID).startFrame-1).name]));
        imshow(image)
        hold on
    elseif background == -1
        image = im2double(imread([inDirectory picture(f+shape(ID).startFrame-1).name]));
        imshow(1-image)
        hold on
    else
        axis ij;
    end
    
    % plots a future outline
    if length(future) > 1
        if futureColor == 1
            if background
                plot(shape(ID).snake(f+futureStep,:,1),shape(ID).snake(f+futureStep,:,2),'-.b','LineWidth',1+zoomed);
            else
                plot(shape(ID).snake(f+futureStep,:,1),shape(ID).snake(f+futureStep,:,2),'-.k','LineWidth',3+zoomed);
            end
        elseif length(future) > 1 && futureStep == 0
            indexMat=zeros(1,M-1);
            for j=1:M-1
                indexMatrix(1,j)=round((futureColor(f+futureStep,j)+futureColor(f+futureStep,j+1)-2*futureCmin)*255/(2*futureCrange))+1;
            end
            [value, order]=sort(indexMatrix);
            for j=order
                line([shape(ID).snake(f+futureStep,j,1) shape(ID).snake(f+futureStep,j+1,1)],[shape(ID).snake(f+futureStep,j,2) shape(ID).snake(f+futureStep,j+1,2)],'Color',futureCmap(indexMatrix(1,j),:),'LineWidth',2+12*indexMatrix(1,j)/256);
            end
        else
            for j=randperm(M-1)
                if mod(j,10)>4 % sets the dashedness of the outline
                    index=round((futureColor(f+futureStep,j)+futureColor(f+futureStep,j+1)-2*futureCmin)*255/(2*futureCrange))+1;
                    line([shape(ID).snake(f+futureStep,j,1) shape(ID).snake(f+futureStep,j+1,1)],[shape(ID).snake(f+futureStep,j,2) shape(ID).snake(f+futureStep,j+1,2)],'Color',futureCmap(index,:),'LineWidth',2);
                end
            end
        end
    end
    
    % plots an outline
    if outline == 1
        if background
            plot(shape(ID).snake(f,:,1),shape(ID).snake(f,:,2),'c','LineWidth',1+zoomed);
        else
            plot(shape(ID).snake(f,:,1),shape(ID).snake(f,:,2),'k','LineWidth',3+zoomed);
            %plot(shape(ID).snake(f,:,1),shape(ID).snake(f,:,2),'Color',colors(i,:),'LineWidth',3+zoomed);
        end
    elseif length(outline) > 1     
        for j=randperm(M-1)
            index=round((outline(f,j)+outline(f,j+1)-2*outlineCmin)*255/(2*outlineCrange))+1;
            line([shape(ID).snake(f,j,1) shape(ID).snake(f,j+1,1)],[shape(ID).snake(f,j,2) shape(ID).snake(f,j+1,2)],'Color',outlineCmap(index,:),'LineWidth',1.5);
        end
    end
    
    % plots arrows
    if length(arrow) > 1
        if arrowColor == 1
            for j=1:arrowNthBP:arrowNthBP*floor(M/arrowNthBP)
                line([shape(ID).snake(f,j,1) shape(ID).snake(f+arrowStep,arrowConnect(i,j),1)],[shape(ID).snake(f,j,2) shape(ID).snake(f+arrowStep,arrowConnect(i,j),2)],'Color',[0.6,0.1,0.6],'LineWidth',3.5);
            end
%         elseif arrowColor == 2
%             for j=1:arrowNthBP:arrowNthBP*floor(M/arrowNthBP)
%                 if shape(ID).motionSign(f,j) == 1
%                     line([shape(ID).snake(f,j,1) shape(ID).snake(f+arrowStep,arrowConnect(f,j),1)],[shape(ID).snake(f,j,2) shape(ID).snake(f+arrowStep,arrowConnect(f,j),2)],'Color','b','LineWidth',3.5);
%                 else
%                     line([shape(ID).snake(f,j,1) shape(ID).snake(f+arrowStep,arrowConnect(f,j),1)],[shape(ID).snake(f,j,2) shape(ID).snake(f+arrowStep,arrowConnect(f,j),2)],'Color','r','LineWidth',3.5);  
%                 end
%             end
        else
            for j=1:arrowNthBP:arrowNthBP*floor((M-1)/arrowNthBP)
                index=round((arrowColor(f,j)-arrowCmin)*255/arrowCrange)+1;
                line([shape(ID).snake(f,j,1) shape(ID).snake(f+arrowStep,arrowConnect(f,j),1)],[shape(ID).snake(f,j,2) shape(ID).snake(f+arrowStep,arrowConnect(f,j),2)],'Color',arrowCmap(index,:),'LineWidth',3.5);
            end
        end
    end
    
    % red is boundary point 0, orange is boundary point 50, etc...
    if marker==1
        plot(shape(ID).snake(f,100,1),shape(ID).snake(f,100,2),'Marker','.','Color',color(1,:));
        for k=1:9
            plot(shape(ID).snake(f,mod(100+10*k,100),1),shape(ID).snake(f,mod(100+10*k,100),2),'Marker','.','Color',color(k+1,:));
        end
    end
        
    % zooms
    box on
    if ~zoomed && ~background
        axis([shape(ID).bounds.minx-10 shape(ID).bounds.minx-10+width shape(ID).bounds.miny-10 shape(ID).bounds.miny-10+width]);
        axis square
    elseif zoomed
        v=[mean(shape(ID).snake(f,:,1))-width/2, mean(shape(ID).snake(f,:,1))+width/2, mean(shape(ID).snake(f,:,2))-width/2, mean(shape(ID).snake(f,:,2))+width/2];
        axis(v)
        axis square
    end
    
    % plots a scale bar
    if scale == 1
        if zoomed && ~background
            line([mean(shape(ID).snake(f,:,1))+width/3.5-5, mean(shape(ID).snake(f,:,1))+width/3.5-5+(pixelsmm/1000)*5],[mean(shape(ID).snake(f,:,2))+width/2-3, mean(shape(ID).snake(f,:,2))+width/2-3],'Color','k','LineWidth',5);
        elseif zoomed && background
            line([mean(shape(ID).snake(f,:,1))+width/3.5-5, mean(shape(ID).snake(f,:,1))+width/3.5-5+(pixelsmm/1000)*5],[mean(shape(ID).snake(f,:,2))+width/2-3, mean(shape(ID).snake(f,:,2))+width/2-3],'Color','y','LineWidth',5);
        elseif ~zoomed && background
            line([shape(ID).bounds.minx+width-30, shape(ID).bounds.minx+width-30+(pixelsmm/1000)*5],[shape(ID).bounds.miny+width-20, shape(ID).bounds.miny+width-20],'Color','y','LineWidth',5);
        elseif ~zoomed && ~background
            line([shape(ID).bounds.minx+width-10, shape(ID).bounds.minx+width-10+(pixelsmm/1000)*5],[shape(ID).bounds.miny+width-10, shape(ID).bounds.miny+width-10],'Color','k','LineWidth',5);
        end
    end
    
    % titles and saves the figure
    if background > 0
        axis off
        xlabel([name ':  ID ' num2str(ID) ', frame ' num2str(f)], 'Color', 'w', 'FontName', 'Arial');
    elseif background == 0
        axis off
        title([name ':  ID ' num2str(ID) ', frame ' num2str(f)], 'FontName', 'Arial');
        xlabel('x (pixel)', 'FontName', 'Arial');
        ylabel('y (pixel)', 'FontName', 'Arial');
    elseif background < 0
        axis off
        xlabel([name ':  ID ' num2str(ID) ', frame ' num2str(f)], 'Color', 'k', 'FontName', 'Arial');
    end
    hold off
    
    if f==1
        pause(10);
    end
    
    imw=getframe(gcf);
    imwrite(imw.cdata(:,:,:),[savePath '/' name '/' name num2str(ID) '_' num2str(f) '.tif'],'tif','Compression','none');
    
end
