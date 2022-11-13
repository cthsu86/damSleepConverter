%% function posWhileAwakeToExcel()
% September 3, 2022
% 
% Assumes that the following scripts have been run previously. 
% - MultibeamPositionAnalysis_minutesPerDay.m
% - basicDAManalysis_withMBv2.m
% Also requires a *_channelList.xlsx file. 

function posWhileAwakeToExcel()

rootdir = 'C:\Users\User\Dropbox\Sehgal Lab\INX6 Sexual dimorphism\2022.06.10 repoGal4 RNAi male';
positionMatName = '2022.06.10 repoGal4 RNAi male_channelList_positionsPerDay.mat';
sleepMatName = '2022.06.10 repoGal4 RNAi male_channelList.mat';
maxPositions = 15;
maxDays = 4;
% Joe should not need to edit anything below this line.
%-----
channelListName = strrep(sleepMatName,'.mat','.xlsx'); %'2022.06.10 repoGal4 RNAi male_channelList.xlsx';
mat2load = positionMatName;

cd(rootdir);
[n,t,r] = xlsread(channelListName);
% Uses the channelList to pull out an ordered list of which cell in
% positionMat's allChannelDatByDay field corresponds to the group numbers
% in question.

output = strrep(mat2load,'_positionsPerDay.mat','_posWhileAwake.xlsx');
if(exist([output],'file'));
    delete([output]);
end;
%Also want to take note of what kind of data this is:
underscoreIndex = strfind(mat2load,'_');
periodIndex = strfind(mat2load,'.');
datatypeSuffix = output((underscoreIndex(end)+1):(periodIndex-1));

A = load(mat2load);
channelDatByDay = A.allChannelDatByDay; %A.channelDatByDay contains minutesPerDay for each channel. 
allDatByGroup = A.allDatByGroup;
clear A;
A = load(sleepMatName);
sleepChannelDatByDay = A.allChannelDatByDay;

prevRow = 1;
allPositionVector = 1:maxPositions;
for(di = 1:maxDays), %size(thisGroupData,1)),
    mat2write = NaN(size(r,1)+1,maxPositions+2);
    mat2write(1,1:maxPositions) = allPositionVector;
    labels2write = cell(size(mat2write,1),1);
    startIndex = 2;
    for(gi = 1:size(A.allDatByGroup,1)),
        numFlies = 0;
        thisGroupName = allDatByGroup{gi,1}
%         thisGroupData = allDatByGroup{gi,2};
        for(ri = 1:size(r,1)),
            if(strcmp(thisGroupName,r(ri,2))),
                numFlies = numFlies+1;
                thisFlyData = channelDatByDay{ri,1};
                thisFlyPositionData = thisFlyData{di,2};
                thisFlyActivityData = sleepChannelDatByDay{ri,1};
                thisFlyActivityData = thisFlyActivityData{di,2};
                isSleep = computeSleep(thisFlyActivityData);
                isWake = ~isSleep;
                mat2write(startIndex+numFlies-1,maxPositions+1) = sum(isWake);
                mat2write(startIndex+numFlies-1,maxPositions+2) = sum(isSleep);

                %                 positionWhileAwake = thisFlyPositionData(find(isWake));
                for(pi = 1:maxPositions),
                    mat2write(startIndex+numFlies-1,pi) = sum(isWake & thisFlyPositionData==pi);
                end;
            end;
        end;
        endIndex = startIndex+numFlies-1;
        labels2write(startIndex:endIndex,1) = {thisGroupName};
        startIndex = endIndex+1;
    end;
    
    sheetName = ['Day ' num2str(di) ' ' datatypeSuffix];
    xlswrite(output,labels2write,sheetName,['A1']); % num2str(prevRow+1)]);
    xlswrite(output,mat2write,sheetName,['B1']); % num2str(prevRow+1)]);
%     display(['Writing day ' num2str(di) ' to row ' num2str(prevRow+1)]);
    
    %
    %         thisDayActivity = thisGroupData{di,1};
    %         if(size(thisDayActivity,1)>0)
    %             isNumIndices = find(~isnan(thisDayActivity(:,1)));
    %             thisDayActivity = thisDayActivity(isNumIndices,:);
    %             labels2write = cell(size(thisDayActivity,1),1);
    %             labels2write(1:end,1) = {thisGroupName};
    %             sheetName = ['Day ' num2str(di) ' ' datatypeSuffix];
    %             xlswrite(output,labels2write,sheetName,['A' num2str(prevRow+1)]);
    %             xlswrite(output,thisDayActivity,sheetName,['B' num2str(prevRow+1)]);
    %             display(['Writing day ' num2str(di) ' to row ' num2str(prevRow+1)]);
    %             if(size(thisDayActivity,1)>numFlies),
    %                 numFlies = size(thisDayActivity,1);
    %             end;
    %         end;
    %     end;
    %     display(['For ' thisGroupName ', prevRow = ' num2str(prevRow)]);
    %     prevRow = prevRow+numFlies;
    %     display(['Now prevRow = ' num2str(prevRow)]);
end;

function isSleep = computeSleep(activityCountsForDay)
isStopped = activityCountsForDay==0;
stoppedStarts = find(diff(isStopped)==1)+1;
stoppedEnds = find(diff(isStopped)==-1);
if(isStopped(1)),
    stoppedStarts = [1; stoppedStarts];
end;
if(isStopped(end)),
    stoppedEnds = [stoppedEnds; numel(isStopped)];
end;

stopLengths = stoppedEnds-stoppedStarts+1;
trueSleepStopBoutIndices = find(stopLengths>=5);
isSleep = zeros(size(activityCountsForDay));
for(si = 1:numel(trueSleepStopBoutIndices))
    
    %                             isSleep((stoppedStarts(trueSleepStopBoutIndices(si))+5):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
    %else,
    isSleep(stoppedStarts(trueSleepStopBoutIndices(si)):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
    %end;
end;
