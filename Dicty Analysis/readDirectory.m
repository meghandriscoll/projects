%%%%%%%%%%%%%%%% readDirectory %%%%%%%%%%%%%%%%

%  Parses the file names in the provided directory.  Assumes that all
%  numbered images are in the image sequence to be analysed, and that an
%  unnumbered image, if present, shows the ROI for later processing.
%
% Inputs:
%  inDirectory      - the directory the images are stored in 
%  savePath         - the directory where data is saved
%
% Saves:
%  N                - the number of images
%  params
%   .N              - the number of images
%   .baseFileName   - the alphabetic text in the name of the numbered images
%   .num_digitsName - the number of digts at the end of the name of the numbered images
%   .startFile      - the number of the lowest numbered image
%   .endFile        - the number of the highest numbered image
%   .imageROIname   - the name of the unnumbered image, if present
%  picture(frame number)
%   .name           - the full name, including the extension, of the image
%   .number         - the image number


function N = readDirectory(useROI, inDirectory, savePath)

% find the index of the first image
files = dir(inDirectory);
start=1;
while strcmp(files(start).name(1) , '.')
    start=start+1; 
end

% find directory parameters
picture=[];
params.baseExtension = '.tif';  % assumes the images are tiffs
params.startFile = Inf; params.endFile = 0;
for f=start:length(files)
    
    % iterate through the numbered images
    if ~isempty(strfind(files(f).name, '.tif')) && max(isstrprop(files(f).name, 'digit'))   
        
        % parse the image title
        numberAndTif = char(regexp(files(f).name, '[\d]*.tif', 'match'));
        number = regexprep(numberAndTif, '.tif', '');
        
        % set parems
        params.baseFileName = regexprep(files(f).name, numberAndTif, '');
        params.num_digitsName = length(number);
        params.startFile = min([params.startFile, str2num(number)]);
        params.endFile = max([params.endFile, str2num(number)]);   
    
    % process the  unnumbered image
    elseif ~isempty(strfind(files(f).name, '.tif')) && ~max(isstrprop(files(f).name, 'digit'))
        params.imageROIname = files(f).name;
    end
    
end

% assign parameters to each picture
for f=start:length(files)    
    if ~isempty(strfind(files(f).name, '.tif')) && max(isstrprop(files(f).name, 'digit'))  
        
        % parse the image title
        numberAndTif = char(regexp(files(f).name, '[\d]*.tif', 'match'));
        number = regexprep(numberAndTif, '.tif', '');
        picture{str2num(number)-params.startFile+1}.number = number;
        picture{str2num(number)-params.startFile+1}.name = files(f).name;
    end    
end

% set N, the number of images
N = params.endFile-params.startFile;
params.N = N;

% ask the user for the roi
if useROI
    if isfield(params, 'imageROIname') % there is an ROI image
        figure;
        roiImage = imread([inDirectory params.imageROIname]);
        disp('Set a polygonal region of interest by right clicking. Then double click within the polygon to exit')
        disp('Zoom using the magnifying lenses')
        [params.roiMask, xMask, yMask] = roipoly(roiImage);
    else % there is not an ROI image
        disp('There is no image to select an ROI from.');
    end   
end

% save variables
save([savePath 'N'], 'N');
save([savePath 'parameters'], 'params');
save([savePath 'boundaries'], 'picture');
