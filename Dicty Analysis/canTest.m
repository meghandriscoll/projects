% subtract absolute value test for Can

%%%%% this m-file should be added to the 'Dicty Analysis' directory %%%%

inDirectory = '/Users/meghandriscoll/Desktop/mov01/';
savePath = '/Users/meghandriscoll/Desktop/mov01out/';

readDirectory(0, inDirectory, savePath);

% load saved variables
load([savePath 'boundaries']); % frame info (loads picture)

% make directory for images
mkdir(savePath, 'testImages')

% load background image
backgroundImage = im2double(imread([inDirectory params.imageROIname]));

% iterates through every frame
for i=1:length(picture)
    
    % load image
    image = im2double(imread([inDirectory picture{i}.name]));
    
    % subtract background from image
    imageSubtract = abs(image-backgroundImage);
    
    % fill image
    imageSubtract = imfill(imageSubtract);
    
    % adjust brightness and contrast
    imageSubtract = imadjust(imageSubtract);
    
%     % plot image
%     figure
%     imagesc(imageSubtract)
%     colormap(gray)
%     axis equal
%     pause(1)
    
    % save image
    imwrite(imageSubtract,[savePath 'testImages/' 'test' num2str(i) '.tif'],'tif');
end