function multiExpDAManalysis()
close all;
primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Dop1R mutants with cohort';
xl2read = 'Dop1R2 mat2read.xlsx';
zt_binsize = 24; %If 12, will look at day, night separately.
%Change zt_binsize to 24 if you want to look at full day.
maxDays = 5; %ABSOLUTELY CAN NOT HAVE MAXDAYS BE GREATER THAN THE NUMBER OF ACTUAL DAYS IN THE EXPERIMENT.
%DO NOT EDIT ANYTHING BELOW THIS LINE.
days2avg = [1 2];
%=====================================
subp_cols = ceil(sqrt(maxDays));
subp_rows = ceil(maxDays/subp_cols);
durationMinuteBins = 10:10:600;
ztBinBounds = [0:zt_binsize:24];
numZTbins = numel(ztBinBounds)-1;

dayAvgString = ['_avgDays' strrep(num2str([1 2]),'  ','_')];

for(zti = 1:numZTbins),
    if(numel(ztBinBounds)==1),
        output = strrep(xl2read,'mat2read.xlsx',['_24hrs' dayAvgString '.xlsx']);
    else,
        output = strrep(xl2read,'mat2read.xlsx',['_ZT' num2str(ztBinBounds(zti)) 'to' num2str(ztBinBounds(zti+1)) dayAvgString '.xlsx']);
    end;
    prevRow = 2;
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
        activityPerMinutePerGroup_multiDay = cell(numel(days2avg),1);
        sleepPerMinutePerGroup_multiDay = cell(numel(days2avg),1);
        %                                     minsAwakePerGroup = minsAwake;
        sleepBinaryPerGroup_multiDay = cell(numel(days2avg),1);
        minsAwakePerGroup_multiDay = cell(numel(days2avg),1); %size(sleepBinary_thisZT,2) - nansum(sleepBinary_thisZT);
        expNumPerGroup_multiDay = cell(numel(days2avg),1);
        
        for(dindex = 1:numel(days2avg)),
            di = days2avg(dindex);
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
                    cd(rootdir);
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
                                    %ri represents the row in the mat2read
                                    %file.
                                    %
                                    %The five variables above
                                    %(activityPerMinutePerGroup,
                                    %sleepPerMinutePerGroup,
                                    %sleepBinaryPerGroup,
                                    %minsAwakePerGroup, and expNumPerGroup
                                    %are accumulated over each experiment
                                    %before moving onto the next group.
                                    %Writing does not happen until after
                                    %the group is done.
                                end;
                            end;
                        else,
                            display(['gi2match=' num2str(gi2match) ', was not less than size(groupDatForExp,1) =' num2str(size(groupDatForExp,1))]);
                        end;
                    end;
                    display(['Finished reading rootdir = ' rootdir]);
                else,
                    display(['Could not find rootdir information in row ' num2str(ri)]);
                end;
            end; %Finished iterating through all the experiments.
            activityPerMinutePerGroup_multiDay{dindex,1} = activityPerMinutePerGroup;
            sleepPerMinutePerGroup_multiDay{dindex,1} = sleepPerMinutePerGroup;
            sleepBinaryPerGroup_multiDay{dindex,1} = sleepBinaryPerGroup;
            minsAwakePerGroup_multiDay{dindex,1} = minsAwakePerGroup; %size(sleepBinary_thisZT,2) - nansum(sleepBinary_thisZT);
            expNumPerGroup_multiDay{dindex,1} = expNumPerGroup;
        end;%Close the "day" for loop.
        
        %Before moving onto the next group, want to sum up the day
        %information and write.
        for(dindex = 1:numel(days2avg)),
            
            totalSleep = nansum(sleepBinaryPerGroup_multiDay{dindex,1},2);            
            totalActivity = nansum(activityPerMinutePerGroup_multiDay{dindex,1},2)./minsAwakePerGroup; %nansum(minsAwakePerGroup,2); %./totalsForGroup{di,3};
            if(dindex ==1),
                activityPerMin_sum = activityPerMinutePerGroup_multiDay{dindex,1};
                sleepPerMinute_sum = sleepPerMinutePerGroup_multiDay{dindex,1};
                sleepBinary_sum = totalSleep;
                minsAwake_sum = minsAwakePerGroup_multiDay{dindex,1};
            else,
                activityPerMin_sum = activityPerMin_sum +activityPerMinutePerGroup_multiDay{dindex,1};
                sleepPerMinute_sum = sleepPerMinute_sum+sleepPerMinutePerGroup_multiDay{dindex,1};
                sleepBinary_sum = sleepBinary_sum+totalSleep;
                minsAwake_sum = minsAwake_sum+totalActivity;
            end;
        end;

        activityDebugParams = [nansum(activityPerMinutePerGroup,2) minsAwakePerGroup];
        
        cd(primedir);
        labels2write = cell(size(sleepBinary_sum,1),2);
        labels2write(1:end,1) = {groupName2Match};
        labels2write(1:end,2) = {di};
        %             labels2write(1:end,1) = {groupName2Match};
        %             labels2write{1:end,3} = expNumPerGroup;
        
        xlswrite(output,sleepBinary_sum/numel(days2avg),'Sleep (mins)',['A' num2str(prevRow)]);
        xlswrite(output,labels2write,'Sleep (mins)',['B' num2str(prevRow)]);
        xlswrite(output,expNumPerGroup,'Sleep (mins)',['D' num2str(prevRow)]);
        if(prevRow==2)
            xlswrite(output,{'Sleep (mins)', 'Genotype','Day','Exp Row#'},'Sleep (mins)',['A1:D1']);
        end;
        
        xlswrite(output,minsAwake_sum/numel(days2avg),'Activity Counts Per min',['A' num2str(prevRow)]);
        xlswrite(output,labels2write,'Activity Counts Per min',['B' num2str(prevRow)]);
        xlswrite(output,expNumPerGroup,'Activity Counts Per min',['D' num2str(prevRow)]);
        xlswrite(output,activityDebugParams,'Activity Counts Per min',['E' num2str(prevRow)]);
        if(prevRow==2)
            xlswrite(output,{'Counts/min', 'Genotype','Day','Exp Row#','Total Activity','Mins Awake'},'Activity Counts Per min',['A1:F1']);
        end;
        
        latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        numSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        for(xi = 1:size(sleepBinaryPerGroup,1)),
            thisFlyBinary = sleepBinaryPerGroup(xi,:);
            [durationHist, allDurations] = durationHistogram(thisFlyBinary, durationMinuteBins);
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
        
        xlswrite(output,meanSleep_dayGroup,'Mean sleep bout (mins)',['A' num2str(prevRow)]);
        xlswrite(output,labels2write,'Mean sleep bout (mins)',['B' num2str(prevRow)]);
        xlswrite(output,expNumPerGroup,'Mean sleep bout (mins)',['D' num2str(prevRow)]);
        if(prevRow==2)
            xlswrite(output,{'Mean sleep bout (mins)', 'Genotype','Day','Exp Row#'},'Mean sleep bout (mins)',['A1:D1']);
        end;
        
        xlswrite(output,numSleep_dayGroup,'Num sleep bouts',['A' num2str(prevRow)]);
        xlswrite(output,labels2write,'Num sleep bouts',['B' num2str(prevRow)]);
        xlswrite(output,expNumPerGroup,'Num sleep bouts',['D' num2str(prevRow)]);
        if(prevRow==2)
            xlswrite(output,{'Num sleep bouts', 'Genotype','Day','Exp Row#'},'Num sleep bouts',['A1:D1']);
        end;
        
        
        prevRow = prevRow+size(labels2write,1);
        
    end;  %Close the "group" for loop.
    %Note that this loop is the one where we created the new Excel
    %spreadsheet.
end; %Close for ZTtimebins.