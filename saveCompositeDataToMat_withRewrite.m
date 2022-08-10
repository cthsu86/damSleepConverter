function saveCompositeDataToMat()
tic;
rootdir = 'C:\Users\User\Dropbox\Additional young PDF for filtering';
suffix = '.txt';
binSize = 5;
maxDays = 5;
outname = '5day_allOutliers.mat';
outlierCutoff = 46.1181;
% Based on the log transform and 3 standard deviations of all the data.
inputDirectory = '0301';
outputDirectory = ['removedGreaterThan' num2str(outlierCutoff) '\'];

close all;
maxNumBins = maxDays*1440/binSize;
outmat = NaN(maxNumBins,1);
diffmat = NaN(maxNumBins,1);

cd(rootdir);
display(pwd);
display(inputDirectory);
cd(inputDirectory);
allFiles = dir(['*' suffix]);
cd('..');
offset = 1;
for(fi = 1:size(allFiles)),
    thisFile = allFiles(fi);
    cd(inputDirectory);
    [channelDat, lines1to4] = loadChannelFile(thisFile.name, binSize);
    diffOfChannel = diff(channelDat);
    outmat(offset:(offset+numel(channelDat)-1)) = channelDat;
    diffmat(offset:(offset+numel(diffOfChannel)-1)) = diffOfChannel;
    offset = offset+numel(channelDat);
    %
    % also need to write filename.
    cd(rootdir);
    if(exist(outputDirectory,'dir')),
    else,
        mkdir(outputDirectory);
    end;
    cd(outputDirectory);
    fOutID = fopen(thisFile.name,'w');
    fprintf(fOutID,lines1to4);
    %
    %     channelIndicesToSave = find(channelDat<outlierCutoff);
    %     channelValsToSave = channelDat(channelIndicesToSave
    %     editedChannelDat = interp1(channelValsToSave,channelIndicesToSave,1:numel(channelDat));
    editedChannelDat = channelDat;
    problemIndices = find(channelDat>outlierCutoff);
    for(pi = 1:numel(problemIndices)),
        beforeProblemIndex = problemIndices(pi)-1;
        afterProblemIndex = problemIndices(pi)+1;
        if(beforeProblemIndex<1),
            beforeProblemIndex = afterProblemIndex;
        end
        if(afterProblemIndex>numel(channelDat)),
            afterProblemIndex = beforeProblemIndex;
        end;
        editedChannelDat(problemIndices(pi)) = mean(channelDat(beforeProblemIndex:afterProblemIndex));
    end;
    
    fprintf(fOutID,['%d' char(10)], editedChannelDat(:));
    fclose(fOutID);
    cd('..');
end;

movingIndices = find(outmat~=0 & ~isnan(outmat));
movingBinValues = outmat(movingIndices);
sortedValues = sort(movingBinValues,'ascend');
stdev = std(movingBinValues);
quartileBounds = quantile(sortedValues,3);
quartile_cutoff = quartileBounds(2) + 3*(quartileBounds(3)-quartileBounds(1));


figure(1);
plot(sortedValues); hold on;
foldSD = 6;
stdev_cutoff = mean(sortedValues)+foldSD*stdev;
plot([0 numel(sortedValues)],[stdev_cutoff stdev_cutoff],'r','LineWidth',2);
numAboveCutoff = sum(sortedValues>stdev_cutoff);
title(['Mean = ' num2str(mean(sortedValues)) ', mean+' num2str(foldSD) '*stdev =' num2str(stdev_cutoff) ', fraction above cutoff = ' num2str(numAboveCutoff/numel(movingIndices))]);
% plot([0 numel(sortedValues)],[quartile_cutoff quartile_cutoff],'m','LineWidth',2);

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
title(['Mean = ' num2str(mean(log(sortedValues))) ', mean+3*stdev =' num2str(stdev_cutoff) ', fraction above cutoff = ' num2str(numAboveCutoff/numel(movingIndices))]);
% plot([0 numel(sortedValues)],[quartile_cutoff quartile_cutoff],'m','LineWidth',2);
xlabel(['ln(counts/bin)']);


% 
% 

toc
display(['Elapsed time does not include saving step.']);
save(outname,'outmat');

function [freadOutput,lines1to4] = loadChannelFile(filename, binSize)
display(filename)
fID = fopen(filename);
lineFileDat = fgets(fID);
numSamplePts = str2double(fgets(fID));
binSizeInFile = str2double(fgets(fID));

if(binSizeInFile~=binSize),
    err([filename ' had binSize=' num2str(binSizeInFile) ', user input binSize=' num2str(binSize)]);
end;
line4 = fgets(fID); %discarded.

lines1to4 = [lineFileDat num2str(numSamplePts) char(10) num2str(binSizeInFile) char(10) line4];
currentPosition = ftell(fID);
freadOutput = fscanf(fID,'%f');
fclose(fID);
