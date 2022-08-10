function saveCompositeDataToMat()
tic;
rootdir = 'C:\Users\User\Dropbox\Sehgal Lab\DAM analysis code\Jess Outliers\5DayAnalysis_compositeData';
suffix = '.txt';
binSize = 5;
maxDays = 5;
outname = '5day_allOutliers.mat';

close all;
maxNumBins = maxDays*1440/binSize;
outmat = NaN(maxNumBins,1);
diffmat = NaN(maxNumBins,1);

cd(rootdir);
allFiles = dir(['*' suffix]);

offset = 1;
for(fi = 1:size(allFiles)),
    thisFile = allFiles(fi);
    channelDat = loadChannelFile(thisFile.name, binSize);
    diffOfChannel = diff(channelDat);
    outmat(offset:(offset+numel(channelDat)-1)) = channelDat;
    diffmat(offset:(offset+numel(diffOfChannel)-1)) = diffOfChannel;
    offset = offset+numel(channelDat);
end;

movingIndices = find(outmat~=0 & ~isnan(outmat));
movingBinValues = outmat(movingIndices);
sortedValues = sort(movingBinValues,'ascend');
stdev = std(movingBinValues);
quartileBounds = quantile(sortedValues,3);
quartile_cutoff = quartileBounds(2) + 3*(quartileBounds(3)-quartileBounds(1));


figure(1);
plot(sortedValues); hold on;
stdev_cutoff = mean(sortedValues)+3*stdev;
plot([0 numel(sortedValues)],[stdev_cutoff stdev_cutoff],'r','LineWidth',2);
numAboveCutoff = sum(sortedValues>stdev_cutoff);
title(['Mean = ' num2str(mean(sortedValues)) ', SD=' num2str(stdev) ', mean+3*stdev =' num2str(stdev_cutoff) ', fraction above cutoff = ' num2str(numAboveCutoff/numel(movingIndices))]);

% title(['Mean = ' num2str(mean(sortedValues)) ', mean+3*stdev =' num2str(stdev_cutoff) ', fraction above cutoff = ' num2str(numAboveCutoff/numel(movingIndices))]);
plot([0 numel(sortedValues)],[quartile_cutoff quartile_cutoff],'m','LineWidth',2);

% 
movingDiffIndices = find(diffmat~=0 & ~isnan(diffmat));
movingDiffValues = abs(diffmat(movingDiffIndices));
sortedDiffValues = sort(movingDiffValues,'ascend');
stdev = std(movingDiffValues);
figure(2);
plot(sortedDiffValues); hold on;
stdev_cutoff = mean(sortedDiffValues)+3*stdev;
plot([0 numel(sortedValues)],[stdev_cutoff stdev_cutoff],'r','LineWidth',2);


figure(3);
plot(log(sortedValues)); hold on;
stdev = std(log(movingDiffValues));
stdev_cutoff = mean(log(sortedValues))+3*stdev;
plot([0 numel(sortedValues)],[stdev_cutoff stdev_cutoff],'r','LineWidth',2);
numAboveCutoff = sum(log(sortedValues)>stdev_cutoff);
title(['Mean = ' num2str(mean(log(sortedValues))) ', SD=' num2str(stdev) ', mean+3*stdev =' num2str(stdev_cutoff) ', fraction above cutoff = ' num2str(numAboveCutoff/numel(movingIndices))]);
% plot([0 numel(sortedValues)],[quartile_cutoff quartile_cutoff],'m','LineWidth',2);
xlabel(['ln(counts/bin)']);


% 
% 

toc
display(['Elapsed time does not include saving step.']);
save(outname,'outmat');

function freadOutput = loadChannelFile(filename, binSize)

fID = fopen(filename);
lineFileDat = fgets(fID);
numSamplePts = str2double(fgets(fID));
binSizeInFile = str2double(fgets(fID));

if(binSizeInFile~=binSize),
    err([filename ' had binSize=' num2str(binSizeInFile) ', user input binSize=' num2str(binSize)]);
end;
line4 = fgets(fID); %discarded.
currentPosition = ftell(fID);
freadOutput = fscanf(fID,'%f');
fclose(fID);
