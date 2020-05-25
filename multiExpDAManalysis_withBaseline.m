function multiExpDAManalysis()

primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\KIR Ax';
xl2read = 'R94B10 KIR mat2read.xlsx';
maxDays = 7;
baselineDays = 1;
groupColors = [0 0 0; 0.5 0.5 0;
    0 0 1; 1 0 1;
    0 1 0; 1 0 0];

subp_cols = ceil(sqrt(maxDays));
subp_rows = ceil(maxDays/subp_cols);
durationMinuteBins = 10:10:600;

output = strrep(xl2read,'mat2read.xlsx','normalizedPlots');

cd(primedir);
if(exist([output '.ps'],'file'));
    delete([output '.ps']);
end;
if(exist([output '.xlsx'],'file')),
    delete([output '.xlsx']);
end;

[num,txt,raw] = xlsread(xl2read);

numGroups = size(raw,2)-2;
%First two columns are dedicated to describing rootdir and matname.
%Subsequent columns describe the experimental groups. The first one is
%always the control group.
% groupColors = [0 0 0; 0 0 1; 1 0 0];
actPerMin_allGroups = cell(maxDays,numGroups);
totalSleep_allGroups = cell(maxDays,numGroups);
latency_allGroups = cell(maxDays,numGroups);
longestSleepBout_allGroups = cell(maxDays,numGroups);
meanSleepBout_allGroups = cell(maxDays,numGroups);
for(gi = 1:numGroups),
    totalActivity_dayByFly = NaN(maxDays,2);
    totalSleep_dayByFly = NaN(maxDays,2);
    for(di = 1:maxDays),
        activityPerMinutePerGroup = [];
        sleepPerMinutePerGroup = [];
        minsAwakePerGroup = [];
        sleepBinaryPerGroup = [];
        for(ri = 1:size(raw,1)),
            groupName2Match = raw{ri,gi+2};
            rootdir = raw{ri,1};
            matname = raw{ri,2};
            
            cd(rootdir);
            M = load(matname);
            groupDatForExp = M.allDatByGroup;
            clear gi2match;
            for(gii=1:size(groupDatForExp,1)),
                if(strcmp(groupDatForExp{gii,1},groupName2Match)),
                    gi2match=gii;
                    display(['groupName2Match=' groupName2Match ', Setting gi2match=' groupDatForExp{gii,1} ' when gii=' num2str(gii)]);
                else,
                    display(['groupName2Match=' groupName2Match ', gii=' num2str(gii) ', ' groupDatForExp{gii,1}]);
                end;
            end;
            
            %Now we know which group we want to pull out.
            thisGroupDat = groupDatForExp{gi2match,2};
            %Data for this group and this experiment is stored in a cell
            %mat, where each row represents a day. There are three columns:
            %
            %             thisGroupActivity{di,1} = activityCounts30min_bin;
            %             thisGroupActivity{di,2} = sleep30min_bin;
            %             thisGroupActivity{di,3} = minsAwake;
            if(di<=size(thisGroupDat,1)),
                activityCounts30min_bin = thisGroupDat{di,1};
                sleep30min_bin = thisGroupDat{di,2};
                minsAwake = thisGroupDat{di,3};
                sleepBinary = thisGroupDat{di,4};
                
                if(isempty(activityPerMinutePerGroup)),
                    activityPerMinutePerGroup = activityCounts30min_bin;
                    sleepPerMinutePerGroup = sleep30min_bin;
                    minsAwakePerGroup = minsAwake;
                    sleepBinaryPerGroup = sleepBinary;
                else,
                    activityPerMinutePerGroup = [activityPerMinutePerGroup;
                        activityCounts30min_bin];
                    sleepPerMinutePerGroup = [sleepPerMinutePerGroup;
                        sleep30min_bin];
                    minsAwakePerGroup = [minsAwakePerGroup;
                        minsAwake];
                    sleepBinaryPerGroup = [sleepBinaryPerGroup; sleepBinary];
                end;
                if(di>=max(baselineDays)),
                    
                end;
            end;
        end; %Close the loop iterating through each experiment.
        %Have accumulated all information (from all experiments) for this group on this day now.
        %     totalActivity_dayByFly = NaN(maxDays,2);
        %     totalSleep_dayByFly = NaN(maxDays,2);
        totalActivity_thisDay = sum(activityPerMinutePerGroup,2)';
        totalSleep_thisDay = sum(sleepPerMinutePerGroup,2)';
        if(numel(totalActivity_thisDay)>size(totalActivity_dayByFly,2)),
            tempActMat = totalActivity_dayByFly;
            tempSleepMat = totalSleep_dayByFly;
            
            totalActivity_dayByFly = NaN(size(totalActivity_dayByFly,1),numel(totalActivity_thisDay));
            totalSleep_dayByFly = NaN(size(totalActivity_dayByFly));
            
            totalActivity_dayByFly(1:size(tempActMat,1),1:size(tempActMat,2)) = tempActMat;
            totalSleep_dayByFly(1:size(tempSleepMat,1),1:size(tempSleepMat,2)) = tempSleepMat;
        end;
            totalActivity_dayByFly(di,1:size(totalActivity_thisDay,2)) = totalActivity_thisDay;
            totalSleep_dayByFly(di,1:size(totalSleep_thisDay,2)) = totalSleep_thisDay;
%         end;
    end; %Now, close off the day loop. Still inside the group loop.
    
    baselineActivity = nanmean(totalActivity_dayByFly(baselineDays,:),1);
    baselineSleep = nanmean(totalSleep_dayByFly(baselineDays,:),1);
    
    figure(2);
    %totalActivity and totalSleep now contain the baseline normalized days.
    totalActivity = totalActivity_dayByFly./repmat(baselineActivity,size(totalActivity_dayByFly,1),1);
    totalSleep = totalSleep_dayByFly./repmat(baselineSleep,size(totalSleep_dayByFly,1),1);
    
    
    letterEnd = size(totalActivity,2)+65;
    columnEnd = size(totalActivity,1)+1;
    cd(primedir);
    xlswrite([output '.xlsx'], totalSleep,gi,['B2:' char(letterEnd) num2str(columnEnd)]);
    xlswrite([output '.xlsx'],{'Sleep, ' groupName2Match},gi,'A1');
    xlswrite([output '.xlsx'], totalActivity,gi*2,['B2:' char(letterEnd) num2str(columnEnd)]);
    xlswrite([output '.xlsx'],{'Activity, ' groupName2Match},gi*2,'A1');

    
    
    for(xi = 1:size(totalActivity,2)),
        thisFlyActivity = totalActivity(:,xi);
        thisFlySleep = totalSleep(:,xi);
        subplot(2,2,1);
        plot(1:numel(thisFlyActivity),thisFlyActivity,'Color',groupColors(gi,:)); hold on;
        
        subplot(2,2,2);
        plot(1:numel(thisFlySleep),thisFlySleep,'Color',groupColors(gi,:)); hold on;
        %         plot(ones(size(totalActivity))*di+0.2*(gi-1)-0.5,totalActivity,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
    end;
    
    subplot(2,2,3);
    meanActivity = median(totalActivity');
%     plot(1:numel,meanActivity,'Color',groupColors(gi,:));
    stdArea = [quantile(totalActivity',0.25); quantile(totalActivity',0.75)-quantile(totalActivity',0.25)];    
    hArea = area(1:numel(meanActivity),stdArea');
    set(hArea(1),'Visible','off');
    set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
    alpha(0.2);
    plot(1:numel(meanActivity),meanActivity,'Color',groupColors(gi,:));
    ylim([0 2]);
    
        subplot(2,2,4);
    meanActivity = median(totalSleep',1);
%     plot(1:numel,meanActivity,'Color',groupColors(gi,:));
    stdArea = [quantile(totalSleep',0.25); quantile(totalSleep',0.75)-quantile(totalSleep',0.25)];    
    hArea = area(1:numel(meanActivity),stdArea');
    set(hArea(1),'Visible','off');
    set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
    alpha(0.2);
    plot(1:numel(meanActivity),meanActivity,'Color',groupColors(gi,:));
    ylim([0 2]);
%     ylim([0 150]);
% %     text(0,9,'Normality (kstest)');
% %     [h,p] = kstest(totalActivity)
% %     text(di+0.2*(gi-1)-0.5,max(totalActivity)+1,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
% %     ylim([0 10]); xlim([0 maxDays+1]);
%     
%     subplot(2,2,2);
%     totalSleep = nansum(sleepPerMinutePerGroup,2);
%     plot(ones(size(totalSleep))*di+0.2*(gi-1)-0.5,totalSleep,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
%     [h,p] = kstest(totalSleep);
%     text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
%     ylim([0 1440]); xlim([0 maxDays+1]);
%     
%     
%     subplot(2,2,3);
%     plotMedianQuartiles(totalActivity,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
%     ylim([0 10]); xlim([0 maxDays+1]);
%     
%     subplot(2,2,4);
%     plotMedianQuartiles(totalSleep,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
%     ylim([0 1440]); xlim([0 maxDays+1]);
%     
%     %         actPerMin_allGroups = cell{maxDays,2};
%     %         totalSleep_allGroups = cell{maxDays,2};
%     actPerMin_allGroups{di,gi} = totalActivity;
%     totalSleep_allGroups{di,gi} = totalSleep;
%     
%     %-------------PLOT BOUT DURATION CUMULATIVE HIST-----------------
%     figure(3);
%     subplot(subp_rows,subp_cols,di);
%     %Here, iterate through all the flies in the group and plot.
%     
%     latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
%     longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
%     meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
%     for(xi = 1:size(sleepBinaryPerGroup,1)),
%         thisFlyBinary = sleepBinaryPerGroup(xi,:);
%         [durationHist, allDurations] = durationHistogram(thisFlyBinary, durationMinuteBins);
%         plot(durationMinuteBins,durationHist,'Color',groupColors(gi,:)); hold on;
%         
%         %While we're iterating through all the files, may as well grab
%         %the other sleep data we need:
%         %         latency_allGroups = cell(maxDays,2);
%         %         longestSleepBout_allGroups = cell(maxDays,2);
%         %         meanSleepBout_allGroups = cell(maxDays,2);
%         latency_dayGroup(xi) = find(thisFlyBinary(12*60+1:end)==1,1);
%         longestSleep_dayGroup(xi) = max(allDurations);
%         meanSleep_dayGroup(xi) = mean(allDurations);
%     end;
%     
%     latency_allGroups{di,gi} = latency_dayGroup;
%     longestSleepBout_allGroups{di,gi} = longestSleep_dayGroup;
%     meanSleepBout_allGroups{di,gi} = meanSleep_dayGroup;
%     
%     %Plot mean and longest bout duration----------------------------
%     figure(4);
%     subplot(2,2,1);
%     plot(ones(size(meanSleep_dayGroup))*di+0.2*(gi-1)-0.5,meanSleep_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3);
%     hold on;
%     %         text(0,9,'Normality (kstest)');
%     %         [h,p] = kstest(totalActivity)
%     %         text(di+0.2*(gi-1)-0.5,max(totalActivity)+1,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
%     ylim([0 400]); xlim([0 maxDays+1]);
%     %
%     subplot(2,2,2);
%     plot(ones(size(longestSleep_dayGroup))*di+0.2*(gi-1)-0.5,longestSleep_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
%     %         [h,p] = kstest(totalSleep);
%     %         text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
%     ylim([0 800]); xlim([0 maxDays+1]);
%     %
%     %
%     subplot(2,2,3);
%     plotMedianQuartiles(meanSleep_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
%     ylim([0 400]); xlim([0 maxDays+1]);
%     %
%     subplot(2,2,4);
%     plotMedianQuartiles(longestSleep_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
%     ylim([0 800]); xlim([0 maxDays+1]);
%     
%     %--------------PLOT LATENCY TO FALL ASLEEP-----------------------
%     figure(5);
%     subplot(2,2,1);
%     plot(ones(size(latency_dayGroup))*di+0.2*(gi-1)-0.5,latency_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
%     %         [h,p] = kstest(totalSleep);
%     %         text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
%     ylim([0 400]); xlim([0 maxDays+1]);
%     %
%     %
%     subplot(2,2,2);
%     plotMedianQuartiles(latency_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
%     ylim([0 400]); xlim([0 maxDays+1]);
    %
    %     end; %Close the "day" for loop. %Have moved the "day" loop closure
    %     earlier in the script.
end; %Close the "group" for loop.
% 
% % end;
% figure(1);
% subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
% subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
% 
figure(2);
subplot(2,2,1); ylabel(['Activity/Waking min']);
ylim([0 2]);

% % text(0,9,'Normality (kstest)');
% title([output]);
% % text(0,100,'Normality (kstest)');
% 
subplot(2,2,2); ylabel(['Sleep/Day (mins)']);
ylim([0 2]);
% 
% subplot(2,2,3); xlabel(['Day']); %Activity/min vs day, IQRs
% subplot(2,2,4); xlabel(['Day']); %Total sleep time vs day, IQRs
% 
% for(di = 1:maxDays), %Need to iterate through all the days and put stats on subplots 3 and 4.
%     subplot(2,2,3); xlabel(['Day']); %Activity/min vs day, IQRs
%     text(di-0.2,1.1*max([actPerMin_allGroups{di,1}; actPerMin_allGroups{di,2}]),...
%         num2str(round(ranksum(actPerMin_allGroups{di,1},actPerMin_allGroups{di,2})*10000)/10000));
%     subplot(2,2,4); xlabel(['Day']); %Total sleep time vs day, IQRs
%     text(di-0.2,1.1*max([totalSleep_allGroups{di,1}; totalSleep_allGroups{di,2}]),...
%         num2str(round(ranksum(totalSleep_allGroups{di,1},totalSleep_allGroups{di,2})*10000)/10000));
% end;


cd(primedir);
for(fignum = 2),
    orient(figure(fignum),'landscape');
    print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
    close(figure(fignum));
end;


ps2pdf('psfile', [output '.ps'], 'pdffile', [output '.pdf'], ...
    'gspapersize', 'letter',...
    'verbose', 1, ...
    'gscommand', 'C:\Program Files\gs\gs9.21\bin\gswin64.exe');