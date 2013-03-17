%%%%%%%%%%%%%%%% MAKE BORDER %%%%%%%%%%%%%%%%

% Adds a black border of width 'width' to an image

function imageB = makeBorder(image, width)

[imageRows, imageCols] = size(image);
imageB = zeros(imageRows+2*width, imageCols+2*width);
imageB((width+1):(imageRows+width), (width+1):(imageCols+width)) = image;