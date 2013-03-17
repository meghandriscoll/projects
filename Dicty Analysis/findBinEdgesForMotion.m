%%%%%%%% FIND BIN EDGES FOR MOTION %%%%%%%%  

function motionA = findBinEdgesForMotion(motionA, accumParams)

goodEccsSort=sort(motionA.goodEccs); % sort the eccentricities
binIndices = 1:floor(length(goodEccsSort)/accumParams.numBinsEcc-1):length(goodEccsSort);
motionA.binEdges = goodEccsSort(binIndices);