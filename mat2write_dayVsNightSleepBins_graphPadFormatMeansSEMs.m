function multiExpDAManalysis()
close all;
tic;

primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\LHON';
xl2read = 'LH1554_mat2read.xlsx';% zt_binsize = 12; 
%.xlsx';% zt_binsize = 12; 
zt_binsize = 24; %If 12, will look at day, night separately.
%Change zt_binsize to 24 if you want to look at full day.
maxDays = 5; %ABSOLUTELY CAN NOT HAVE MAXDAYS BE GREATER THAN THE NUMBER OF ACTUAL DAYS IN THE EXPERIMENT.
%DO NOT EDIT ANYTHING BELOW THIS LINE.
%=====================================
days2avg = [1 2];
subp_cols = ceil(sqrt(maxDays));
subp_rows = ceil(maxDays/subp_cols);
durationMinuteBins = 10:10:600;
ztBinBounds = [0:zt_binsize:24];
numZTbins = numel(ztBinBounds)-1;

for(zti = 1:numZTbins),
    if(zt_binsize==24),
        output = strrep(xl2read,'mat2read.xlsx',['_24hrs_multiColumnMeansSEMs.xlsx']);
    else,
        output = strrep(xl2read,'mat2read.xlsx',['_ZT' num2str(ztBinBounds(zti)) 'to' num2str(ztBinBounds(zti+1)) '_multiColumnMeansSEMs.xlsx']);
    end;
    prevRow = 2;
    groupColCharNum = 66;
    cd(primedir);
    if(exist([output],'file'));
        delete([output]);
    end;
    
    [num,txt,raw] = xlsread(xl2read);
    
    numGroups = size(raw,2)-2;
    %First two columns are dedicated to describing rootdir and matname.
    %Subsequent columns describe the experimental groups. The first one is
    %always the control group.
    % groupColors = [0 0 0; 0 1 0; 0 0 1]; %0 0 1; 1 0 0];
    
    actPerMin_CtrlVsExp = cell(maxDays,2);
    totalSleep_CtrlVsExp = cell(maxDays,2);
    latency_CtrlVsExp = cell(maxDays,2);
    longestSleepBout_CtrlVsExp = cell(maxDays,2);
    numSleepBout_CtrlVsExp = cell(maxDays,2);
    meanSleepBout_CtrlVsExp = cell(maxDays,2);
    for(gi = 1:numGroups),
        for(di = 1:maxDays),
            activityPerMinutePerGroup = [];
            sleepPerMinutePerGroup = [];
            %             sleepPerBinPerGroup = [];
            minsAwakePerGroup = [];
            sleepBinaryPerGroup = [];
            
            expNumPerGroup = {};
            for(ri = 1:size(raw,1)),
                
                groupName2Match = raw{ri,gi+2};
                rootdir = raw{ri,1};
                matname = raw{ri,2};
                %                 try,
                if(~isnan(rootdir)),
%                     display(rootdir);
% try,
                    cd(rootdir);
% catch,
%     display('what?');
% end;
                    M = load(matname);
                    groupDatForExp = M.allDatByGroup;
                    %The first column of groupDatForExp contains information
                    %regarding the
                    for(gii=1:size(groupDatForExp,1)),
                        if(strcmp(groupDatForExp{gii,1},groupName2Match)),
                            gi2match=gii;
                        else,
                            display(['gii=' num2str(gii) ', ' groupDatForExp{gii,1} ': did not match ' groupName2Match]);
                        end;
                    end;
                    
                    %Now we know which group we want to pull out.
                    display(rootdir);
                    display(groupName2Match);
                    if(exist('gi2match','var')),
                        if(gi2match<=size(groupDatForExp,1)),
                            thisGroupDat = groupDatForExp{gi2match,2};
                            %Data for this group and this experiment is stored in a cell
                            %mat, where each row represents a day. There are three columns:
                            %             thisGroupActivity{di,1} = activityCounts30min_bin;
                            %             thisGroupActivity{di,2} = sleep30min_bin;
                            %             thisGroupActivity{di,3} = minsAwake;
                            if(di<=size(thisGroupDat,1)),
                                activityCounts30min_bin = thisGroupDat{di,1};
                                sleep30min_bin = thisGroupDat{di,2};
                                minsAwake = thisGroupDat{di,3};
                                sleepBinary = thisGroupDat{di,4};
                                %                             display(size(sleepBinary));
                                %                             display(ztBinBounds(zti));
                                %Have now added a sleepPerBinPerGroup matrix.
                                %This is essentially the same as
                                %activityPerMinutePerGroup, only reshaped to
                                %fit into the redefined ZT bins:
                                
                                if(~isempty(sleepBinary)),
                                    sleepBinary_thisZT = sleepBinary(:,(ztBinBounds(zti)*60+1):(ztBinBounds(zti+1)*60));
                                    minsAwake = ones(size(sleepBinary_thisZT,1),1)*size(sleepBinary_thisZT,2) - nansum(sleepBinary_thisZT,2);
                                else,
                                    sleepBinary_thisZT = [];
                                end;
                                if(isempty(activityPerMinutePerGroup) && ~isempty(sleepBinary_thisZT)),
                                    activityPerMinutePerGroup = activityCounts30min_bin(:,(ztBinBounds(zti)*2+1):(ztBinBounds(zti+1)*2));
                                    sleepPerMinutePerGroup = sleep30min_bin;
                                    %                                     minsAwakePerGroup = minsAwake;
                                    sleepBinaryPerGroup = sleepBinary_thisZT;
                                    minsAwakePerGroup = minsAwake; %size(sleepBinary_thisZT,2) - nansum(sleepBinary_thisZT);
                                    expNumPerGroup = ones(size(minsAwake))*ri;
                                    %                                 sleepPerBinPerGroup = sleep_ztbin;
                                elseif(~isempty(sleepBinary_thisZT)),
                                    try,
                                        activityPerMinutePerGroup = [activityPerMinutePerGroup;
                                            activityCounts30min_bin(:,(ztBinBounds(zti)*2+1):(ztBinBounds(zti+1)*2))];
                                    catch,
                                        display('Why?');
                                    end;
                                    sleepPerMinutePerGroup = [sleepPerMinutePerGroup;
                                        sleep30min_bin];
                                    minsAwakePerGroup = [minsAwakePerGroup;
                                        minsAwake];
                                    if(~isempty(sleepBinary)),
                                        sleepBinaryPerGroup = [sleepBinaryPerGroup; sleepBinary(:,(ztBinBounds(zti)*60+1):(ztBinBounds(zti+1)*60))];
                                    end;
                                    expNumPerGroup = [expNumPerGroup; ones(size(minsAwake))*ri];
                                end;
                            end;
                        else
                            display(['gi2match=' num2str(gi2match) ', was not less than size(groupDatForExp,1) =' num2str(size(groupDatForExp,1))]);
                        end;
                    end;
                    display(['Finished reading rootdir = ' rootdir]);
                else,
                    display(['Could not find rootdir information in row ' num2str(ri)]);
                end;
            end; %Finished iterating through all the experiments.
            
            totalSleep = nansum(sleepBinaryPerGroup,2);
            try,
            totalActivity = nansum(activityPerMinutePerGroup,2)./minsAwakePerGroup; %nansum(minsAwakePerGroup,2); %./totalsForGroup{di,3};
            catch,
                display('debug.');
            end;
            activityDebugParams = [nansum(activityPerMinutePerGroup,2) minsAwakePerGroup];
            
            cd(primedir);
            %             labels2write = cell(size(totalSleep,1),1);
            %             labels2write(1:end,1) = {groupName2Match};
            %First, start by writing the 30 min bin profile
            sheetName = ['Day ' num2str(di) ' 30 min binned sleep' num2str(di)];
            if(gi==1),
                xlswrite(output,[0.5:0.5:24]',sheetName,['A3']);
            end;
            groupLabel = cell(2,3);
            groupLabel{1,1} = groupName2Match;
            groupLabel{2,1} = 'Mean';
            groupLabel{2,2} = 'SEM';
            groupLabel{2,3} = 'n';
            xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']); %Writing the labels in the second row.
            fliesInGroup = size(sleepPerMinutePerGroup,1);
            sleepBins2write = [nanmean(sleepPerMinutePerGroup)' std(sleepPerMinutePerGroup)'/sqrt(fliesInGroup) ones(size(sleepPerMinutePerGroup,2),1)*fliesInGroup];
            xlswrite(output,sleepBins2write,['Day ' num2str(di) ' 30 min binned sleep' num2str(di)],[char(groupColCharNum) '3']);
            
            sheetName = ['Sleep (mins)'];
            if(gi==1),
                xlswrite(output,[1:maxDays]',sheetName,['A3']);
            end;
            if(di==1),
                %Writing the labels in the second row.
                xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']);
                
                %If this is the first day, we need to enerate the matrices to
                %write. Otherwise, we need to accumulate the matrices to
                %write.
                sleep2write = [nanmean(totalSleep) std(totalSleep)/sqrt(fliesInGroup) fliesInGroup];
                
            else,
                sleep2write = [sleep2write; nanmean(totalSleep) std(totalSleep)/sqrt(fliesInGroup) fliesInGroup];
                if(di==maxDays),
                    xlswrite(output,sleep2write,sheetName,[char(groupColCharNum) '3']);
                end;
            end;
            
            sheetName = ['Activity Counts Per Min'];
            if(gi==1),
                xlswrite(output,[1:maxDays]',sheetName,['A3']);
            end;
            if(di==1),
                %Writing the labels in the second row.
                xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']);
                
                %If this is the first day, we need to enerate the matrices to
                %write. Otherwise, we need to accumulate the matrices to
                %write.
                activity2write = [nanmean(totalActivity) std(totalActivity)/sqrt(fliesInGroup) fliesInGroup];
                
            else,
                activity2write = [activity2write; nanmean(totalActivity)/sqrt(fliesInGroup) std(totalActivity) fliesInGroup];
                if(di==maxDays),
                    xlswrite(output,activity2write,sheetName,[char(groupColCharNum) '3']);
                end;
            end;
            
            latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            numSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            for(xi = 1:size(sleepBinaryPerGroup,1)),
                thisFlyBinary = sleepBinaryPerGroup(xi,:);
                display(sum(thisFlyBinary));
                [durationHist, allDurations_noEnds,~,numBouts,allDurations] = durationHistogram(thisFlyBinary, durationMinuteBins);
                %While we're iterating through all the files, may as well grab
                %the other sleep data we need:
                
                if(numel(allDurations)==0),
                    longestSleep_dayGroup(xi) = 0; %max(allDurations);
                    meanSleep_dayGroup(xi) = 0; %mean(allDurations);
                    numSleep_dayGroup(xi) = 0; %numel(allDurations);
                else,
                    try,
                        latency_dayGroup(xi) = find(thisFlyBinary==1,1);
                    catch,
                        display('what?');
                    end;
                    longestSleep_dayGroup(xi) = max(allDurations);
                    meanSleep_dayGroup(xi) = mean(allDurations);
                    numSleep_dayGroup(xi) = numel(allDurations);
                end;
            end;
            sheetName = ['Mean sleep bout (mins)'];
            %             writeDayMeanSEM2sheet(output,maxDays,sheetName,groupLabel,groupColCharNum,fliesInGroup,meanSleep_dayGroup,gi,di);
            if(gi==1),
                xlswrite(output,[1:maxDays]',sheetName,['A3']);
            end;
            if(di==1),
                %Writing the labels in the second row.
                xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']);
                
                %If this is the first day, we need to enerate the matrices to
                %write. Otherwise, we need to accumulate the matrices to
                %write.
                meanSleep2write = [nanmean(meanSleep_dayGroup) std(meanSleep_dayGroup)/sqrt(fliesInGroup) fliesInGroup];
                
            else,
                meanSleep2write = [meanSleep2write; nanmean(meanSleep_dayGroup) std(meanSleep_dayGroup)/sqrt(fliesInGroup) fliesInGroup];
                if(di==maxDays),
                    xlswrite(output,meanSleep2write,sheetName,[char(groupColCharNum) '3']);
                end;
            end;
            
            sheetName = ['Num sleep bouts'];
            if(gi==1),
                xlswrite(output,[1:maxDays]',sheetName,['A3']);
            end;
            if(di==1),
                %Writing the labels in the second row.
                xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']);
                
                %If this is the first day, we need to enerate the matrices to
                %write. Otherwise, we need to accumulate the matrices to
                %write.
                numSleep2write = [nanmean(numSleep_dayGroup) std(numSleep_dayGroup)/sqrt(fliesInGroup) fliesInGroup];
                
            else,
                numSleep2write = [numSleep2write; nanmean(numSleep_dayGroup) std(numSleep_dayGroup)/sqrt(fliesInGroup) fliesInGroup];
                if(di==maxDays),
                    xlswrite(output,numSleep2write,sheetName,[char(groupColCharNum) '3']);
                end;
            end;
            
        end;%Close the "day" for loop.
        %             prevRow = prevRow+size(labels2write,1);
        groupColCharNum = groupColCharNum+3;
    end;  %Close the "group" for loop.
    %Note that this loop is the one where we created the new Excel
    %spreadsheet.
end; %Close for ZTtimebins
toc