function multiExpDAManalysis()
close all;
primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\TrpA1\GH146_TrpA1_ZT0_12hr31 summary';
xl2read = 'GH146_TrpA1_ZT0to12_31C_mat2read.xlsx';
% primedir = 'Z:\Sehgal Lab Shared Folder\Joe\Activity Monitor Results\2018_03_16- Autophagy Screen\DAGS Week7 DiNGS Week3';
% xl2read = '2019_06_07_RNAi Week 48_mat2read.xlsx';
zt_binsize = 12; %If 12, will look at day, night separately.
%Change zt_binsize to 24 if you want to look at full day.
maxDays = 5; %ABSOLUTELY CAN NOT HAVE MAXDAYS BE GREATER THAN THE NUMBER OF ACTUAL DAYS IN THE EXPERIMENT.
%DO NOT EDIT ANYTHING BELOW THIS LINE.
%=====================================
durationMinuteBins = 10:10:600;
ztBinBounds = [0:zt_binsize:24];
numZTbins = numel(ztBinBounds)-1;
tic;
for(zti = 1:numZTbins),
    labels2write_fullSet = {};
    expNumPerGroup_fullSet = {};
    completeDurations_fullSet = {};
    allDurations_fullSet = {};
%                 prevRowNum = 0;
    if(numel(ztBinBounds)==1),
        output = strrep(xl2read,'mat2read.xlsx',['_24hrs_durationHist.xlsx']);
    else,
        output = strrep(xl2read,'mat2read.xlsx',['_ZT' num2str(ztBinBounds(zti)) 'to' num2str(ztBinBounds(zti+1)) '_durationHist.xlsx']);
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
                    cd(rootdir);
                    %                 catch,
                    %                     display('eep.');
                    %                 end;
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
%                                     try,
                                    minsAwake = ones(size(sleepBinary_thisZT,1),1)*size(sleepBinary_thisZT,2) - nansum(sleepBinary_thisZT,2);
%                                     catch,
%                                         if(sum(isnan(sleepBinary_thisZT,2)==)
% 
%                                     end;
                                else,
                                    sleepBinary_thisZT = [];
                                end;
                                %                                 catch,
                                %                                     display('why?');
                                %                                 end;
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
                        else,
                            display(['gi2match=' num2str(gi2match) ', was not less than size(groupDatForExp,1) =' num2str(size(groupDatForExp,1))]);
                        end;
                    end;
                    display(['Finished reading rootdir = ' rootdir]);
                else,
                    display(['Could not find rootdir information in row ' num2str(ri)]);
                end;
            end; %Finished iterating through all the experiments.
            
            totalSleep = nansum(sleepBinaryPerGroup,2);
            totalActivity = nansum(activityPerMinutePerGroup,2)./minsAwakePerGroup; %nansum(minsAwakePerGroup,2); %./totalsForGroup{di,3};
            activityDebugParams = [nansum(activityPerMinutePerGroup,2) minsAwakePerGroup];
            
            cd(primedir);
            
            labels2write = cell(size(totalSleep,1),2);
            labels2write(1:end,1) = {groupName2Match};
            labels2write(1:end,2) = {di};
            
            latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
            numSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);

            for(xi = 1:size(sleepBinaryPerGroup,1)),
                thisFlyBinary = sleepBinaryPerGroup(xi,:);
%                 display(sum(thisFlyBinary));
                [durationHist, allDurations,~,numBouts,allDurationsIncludingEnds] = durationHistogram(thisFlyBinary, durationMinuteBins);
                
                if(~isempty(allDurationsIncludingEnds)),
                    cellMatWidth = numel(allDurationsIncludingEnds);
                else,
                    cellMatWidth = 2;
                end;
                if(isempty(allDurations_fullSet)),
                    %We have not really initialized the cell matrix
                    %yet.
                    allDurations_fullSet = cell(size(sleepBinaryPerGroup,1),cellMatWidth);
                    completeDurations_fullSet = cell(size(allDurations_fullSet));
                end;
                if(xi==1 && numel(allDurationsIncludingEnds)>0), %We need to expand it so that it will fit the new group.
                        %To expand it, make a temporary empty cell array
                        %where the size is equivalent to all of the bouts
                        %that will be encountered here.
                        if(size(allDurations_fullSet,2)<cellMatWidth),
                            %Make sure that the cell array is wide
                            %enough. If not, save each cell array into
                            %a temp array, preallocate a sufficiently
                            %wide array, then coyp it over.
                            temp = allDurations_fullSet;
                            allDurations_fullSet = cell(size(sleepBinaryPerGroup,1),cellMatWidth);
                            allDurations_fullSet(1:size(temp,1),1:size(temp,2)) = temp;
                            display(['Size of temp: ' num2str(size(temp))]);
                            display(['Size of allDurations_fullSet: ' num2str(size(allDurations_fullSet))]);
                            
                            temp = completeDurations_fullSet;
                            completeDurations_fullSet = cell(size(sleepBinaryPerGroup,1),cellMatWidth);
                            completeDurations_fullSet(1:size(temp,1),1:size(temp,2)) = temp;
                            display(['Size of temp: ' num2str(size(temp))]);
                            display(['Size of completeDurations_fullSet: ' num2str(size(completeDurations_fullSet))]);
                        else,
                            display(['Did not need to resize allDurations and completeDurations because numel(allDurationsIncludingEnds) = ' ...
                                num2str(numel(allDurationsIncludingEnds)) ', size of allDurations_fullSet =' num2str(size(allDurations_fullSet))...
                                ', size of completeDurations_fullset=' ...
                                num2str(size(completeDurations_fullSet))]);
                        end;
                        
                        %We want to concatenate an empty array here.
                        temp = cell(size(sleepBinaryPerGroup,1),size(allDurations_fullSet,2)); %max(numel(allDurationsIncludingEnds),cellMatWidth));
                        allDurations_fullSet = [allDurations_fullSet; temp];
                        temp = cell(size(sleepBinaryPerGroup,1),size(completeDurations_fullSet,2)); %cellMatWidth));
                        completeDurations_fullSet = [completeDurations_fullSet; temp];
                elseif(xi==1),
                    display(['Did not save any data from ' primedir ' for day ' num2str(di) ' and groupname = ' groupName2Match ...
                        ' because numel(allDurationsIncludingEnds)=' num2str(numel(allDurationsIncludingEnds))']);
                end;
                
                    %Now need to save the new data in the cell matrix?
%                                                 if(size(allDurations_fullSet,2)<numel(allDurationsIncludingEnds)),
%                                 %Make sure that the cell array is wide
%                                 %enough. If not, save each cell array into
%                                 %a temp array, preallocate a sufficiently
%                                 %wide array, then coyp it over.
%                                 temp = allDurations_fullSet;
%                                 allDurations_fullSet = cell(size(sleepBinaryPerGroup,1),numel(allDurationsIncludingEnds));
%                                 allDurations_fullSet(1:size(temp,1),1:size(temp,2)) = temp;
%                                 display(['Size of temp: ' num2str(size(temp))]);
%                                 display(['Size of allDurations_fullSet: ' num2str(size(allDurations_fullSet))]);
%                                 
%                                 temp = completeDurations_fullSet;
%                                 completeDurations_fullSet = cell(size(sleepBinaryPerGroup,1),numel(allDurationsIncludingEnds));
%                                 completeDurations_fullSet(1:size(temp,1),1:size(temp,2)) = temp;
%                                 display(['Size of temp: ' num2str(size(temp))]);
%                                 display(['Size of completeDurations_fullSet: ' num2str(size(completeDurations_fullSet))]);
%                             else,
%                                 display(['Did not need to resize allDurations and completeDurations because numel(allDurationsIncludingEnds) = ' ...
%                                     num2str(numel(allDurationsIncludingEnds)) ', size of allDurations_fullSet =' num2str(size(allDurations_fullSet))...
%                                     ', size of completeDurations_fullset=' ...
%                                     num2str(size(completeDurations_fullSet))]);
%                             end;
                    allDurations_fullSet(prevRow+xi-1,1:numel(allDurationsIncludingEnds)) = num2cell(allDurationsIncludingEnds);
                    completeDurations_fullSet(prevRow+xi-1,1:numel(allDurations)) = num2cell(allDurations);
                    display(['xi=' num2str(xi) '. After saving numel(allDurationsIncludingEnds) = ' ...
                        num2str(numel(allDurationsIncludingEnds)) ', size of allDurations_fullSet =' num2str(size(allDurations_fullSet))...
                        ', size of completeDurations_fullset=' ...
                        num2str(size(completeDurations_fullSet))]);
%                 end;
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
                    numSleep_dayGroup(xi) = numBouts;
                end;
            end;
            if(isempty(labels2write_fullSet)),
                textLabel = {'Genotype','Day'};
                labels2write_fullSet = [textLabel;labels2write];
                textLabel = {'Exp#'};
                expNumPerGroup_fullSet = [textLabel; num2cell(expNumPerGroup)];
            else,
                labels2write_fullSet = [labels2write_fullSet;labels2write];
                expNumPerGroup_fullSet = [expNumPerGroup_fullSet; num2cell(expNumPerGroup)];
            end;
%             if(size(labels2write_fullSet,1) ~= size(allDurations_fullSet)),
%                 display(['Pause error A']);
%             elseif(size(labels2write_fullSet,1) ~= size(completeDurations_fullSet)),,
%                 display(['Pause error B']);
%             end;
%             xlswrite(output,labels2write,'Mean sleep bout (mins)',['A' num2str(prevRow)]);
%             %Column B contains the day.
%             xlswrite(output,expNumPerGroup,'Mean sleep bout (mins)',['C' num2str(prevRow)]);
%             if(prevRow==2)
%                 xlswrite(output,{'Genotype','Day','Exp Row#'},'Mean sleep bout (mins)',['A1:C1']);
%             end;
                        
            prevRow = prevRow+size(labels2write,1);
            
        end;%Close the "day" for loop.
    end;  %Close the "group" for loop.
    %Note that this loop is the one where we created the new Excel
    %spreadsheet.
    display(size(labels2write_fullSet));
    display(size(expNumPerGroup_fullSet));
    display(size(allDurations_fullSet));
%     try,
            mat2write_allDurations = [labels2write_fullSet expNumPerGroup_fullSet allDurations_fullSet(1:size(labels2write_fullSet,1),:)];
            mat2write_completeDurations = [labels2write_fullSet expNumPerGroup_fullSet completeDurations_fullSet(1:size(labels2write_fullSet,1),:)];
%     catch,
%         display('help?');
%     end;
            if(size(mat2write_allDurations,2)>26),
                firstLetterChar = char(65+floor(size(mat2write_allDurations,2)/26));
                lastColOvershoot = mod(size(mat2write_allDurations,2),26);
                if(lastColOvershoot~=0),
                    lastColChar = char(65+lastColOvershoot-1);
                else,
                    lastColChar = 'Z';
                end;
                columnChar2write = [firstLetterChar lastColChar];
            else,
                columnChar2write = char(65+size(mat2write_allDurations,2)-1);
            end;
            cellRange2write = ['A1:' columnChar2write num2str(size(mat2write_allDurations,1))]
            xlswrite(output,mat2write_completeDurations,'Durations no end cases (min)',cellRange2write);
            xlswrite(output,mat2write_allDurations,'Durations incl end cases (min)',cellRange2write);
%             %Column B contains the day.
%             xlswrite(output,expNumPerGroup,'Mean sleep bout (mins)',['C' num2str(prevRow)]);
%             if(prevRow==2)
%                 xlswrite(output,{'Genotype','Day','Exp Row#'},'Mean sleep bout (mins)',['A1:C1']);
%             end;
                        
    
end; %Close for ZTtimebins.
toc