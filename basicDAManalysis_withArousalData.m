%In addition to teh basic data, will also plot:
% 1) the distribution of flies
%that wake up (that were not already awake) following arousal.
% 2) The time it takes flies to fall back asleep following arousal.

%Takes in day, arousalTimeZT pairs.

function basicDAManalysis_withArousalData()
close all; clear all;
rawdir = 'C:\Users\Cynthia\Dropbox\Sehgal Lab\Arousal\161106\CTH format data';
rootdir = 'C:\Users\Cynthia\Dropbox\Sehgal Lab\Arousal\161106'; %\161124_summary';
%"group" typically refers to different genotypes.
groupNames = {'all ctrl'};
groupColors = [0 0 0]; %[1 0 0; 1 0 1; 0 0 1; 0 0 0];

maxDays = 8;
maxNumChannels = 32;

%Column 1: day
%Column 2: hrs (ZT time).
day_arousalTime_mat = [3 13;
    5 15;
    7 17];

%Column 1= # of flies that woke up
%Column 2= # of flies that were asleep.
%Column 3 = Time it takes flies to go back to sleep 

cd(rootdir);
backslashIndices = strfind(rootdir,'\');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList'];
[n,t,r] = xlsread([flyIDname '.xlsx']);

output = flyIDname;
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);
if(~exist([output '.mat'],'file')),
allChannelDatByDay = processChannels(rawdir,groupNameByChannel);
cd(rootdir);
save([output '.mat'],'allChannelDatByDay');
else,
    allChannelDatByDay = load([output '.mat']);
    allChannelDatByDay = allChannelDatByDay.allChannelDatByDay;
end;

for(gi = 1:numel(groupNames)),
    thisGroupActivity = cell(maxDays,2); %col1 = activity, col2 = sleep.
    
fliesAwakenedByArousal = NaN(size(groupNameByChannel,1),maxDays,3); 
fliesAwakenedPerDay = NaN(maxDays,1);
    for(ci = 1:size(groupNameByChannel,1)),
        if(strmatch(groupNames{gi},groupNameByChannel{ci})),
            thisChannelDatByDay = allChannelDatByDay{ci};
            figure(1);
            for(di = 1:size(thisChannelDatByDay,1)),
                activityCountsForDay = thisChannelDatByDay{di,2};
                try,
                activityCounts30min_bin = sum(reshape(activityCountsForDay,30,48),1);
                catch,
                activityCounts30min_bin = sum(reshape(activityCountsForDay(1:end-1),30,48),1);
                end;
                subplot(maxDays,2,(di-1)*2+1);
                timepts = ([1:numel(activityCounts30min_bin)]-1)/2;
                plot(timepts,activityCounts30min_bin);
                xlim([0 24]);
                
                isStopped = activityCountsForDay==0;
                stoppedStarts = find(diff(isStopped)==1)+1;
                stoppedEnds = find(diff(isStopped)==-1);
                if(isStopped(1)),
                    stoppedStarts = [1; stoppedStarts];
                end;
                if(isStopped(end)),
                    stoppedEnds = [stoppedEnds; numel(isStopped)];
                end;
                
                stopLengths = stoppedEnds-stoppedStarts;
                trueSleepStopBoutIndices = find(stopLengths>5);
                isSleep = zeros(size(activityCountsForDay));
                for(si = 1:numel(trueSleepStopBoutIndices))
                    isSleep(stoppedStarts(trueSleepStopBoutIndices(si)):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
                end;
                try,
                    sleep30min_bin = sum(reshape(isSleep,30,48),1);
                catch,
                    sleep30min_bin = sum(reshape(isSleep(1:end-1),30,48),1);
                end;
                subplot(maxDays,2,di*2);
                plot(timepts,sleep30min_bin);
                xlim([0 24]); ylim([0 30]);
                
                %Want to save the information for this day into the
                %relevant cell of the thisGroupActivity array.
                thisDayGroupActivity = thisGroupActivity{di,1};
                if(isempty(thisDayGroupActivity)),
                    thisGroupActivity{di,1} = activityCounts30min_bin;
                    thisGroupActivity{di,2} = sleep30min_bin;
                else,
                    thisDayGroupActivity = [thisDayGroupActivity; activityCounts30min_bin];
                    thisDaySleepActivity = [thisGroupActivity{di,2}; sleep30min_bin];
                    
                    thisGroupActivity{di,1} = thisDayGroupActivity;
                    thisGroupActivity{di,2} = thisDaySleepActivity;
                end;
                if(ismember(di,day_arousalTime_mat(:,1))),
                    disturbanceDaySubindex = find(day_arousalTime_mat(:,1)==di);
                    disturbanceTime = day_arousalTime_mat(disturbanceDaySubindex,2);
                    subplot(maxDays,2,(di-1)*2+1);
                    hold on;
                    plot([disturbanceTime disturbanceTime],[0 30],'r');
                    subplot(maxDays,2,di*2);
                    hold on;
                    plot([disturbanceTime disturbanceTime],[0 30],'r');
                    % 1) the distribution of flies
                    %that wake up (that were not already awake) following arousal.
                    % 2) The time it takes flies to fall back asleep following arousal.
                    
                    %Data will be stored in the fliesAwakendByArousal
                    %matrix:
                    %fliesAwakenedByArousal = NaN(maxNumChannels,size(day_arousalTime_mat,1),3);
                    %Column 1= did fly wake up?
                    %Column 2= was fly asleep?
                    %Column 3 = Time it takes flies to go back to sleep
                    
                    %First, want to figure out what the index of the
                    %disturbanceTime is. Here, we rely on the hardcoded
                    %assumptiont hat the activityCountsForDay array stores
                    %information in one minute bins.
                    disturbanceTime_min = disturbanceTime*60;
                    flyWasAsleep = sum(isSleep(disturbanceTime_min-5:disturbanceTime_min-1))==5;
                    flyWasAwake = sum(activityCountsForDay(disturbanceTime_min:disturbanceTime_min+5))>0;
                    fliesAwakenedByArousal(ci,di,2) = double(flyWasAsleep);
                    fliesAwakenedByArousal(ci,di,1) = double(flyWasAwake);
                    if(flyWasAsleep && flyWasAwake), %Figure out time it takes it to go back to sleep.
                        indexOfAwakening = find(activityCountsForDay(disturbanceTime_min:end)>0,1);
                        indexOfSleepPostAwakening = find(activityCountsForDay(disturbanceTime_min+indexOfAwakening-1:end)==0,1);
                        fliesAwakenedByArousal(ci,di,3) = indexOfSleepPostAwakening; %-indexOfAwakening;
                    end;
                end;
                figure(di+1);
                subplot(2,2,1);
                plot(1:numel(activityCountsForDay),activityCountsForDay,'k'); hold on;
                subplot(2,2,2);
                plot(1:numel(activityCounts30min_bin),activityCounts30min_bin,'k'); hold on;
                subplot(2,2,3);
                plot(1:numel(isSleep),isSleep,'k'); hold on;
                subplot(2,2,4);
                plot(1:numel(sleep30min_bin),sleep30min_bin,'k'); hold on;
                
                figure(1);
            end;
            figure(1);
            subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
            title([expName ' Ch' num2str(ci) ': ' groupNameByChannel{ci}]);
            subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
            
            orient(figure(1),'landscape');
            print(figure(1),'-dpsc2',[output '.ps'],'-append');
            close(figure(1));
        end;
    end;
    for(fignum = 2:(di+1)),
            figure(fignum);
            subplot(2,2,1);
            if(ismember(fignum-1,day_arousalTime_mat(:,1))),
                disturbanceDaySubindex = find(day_arousalTime_mat(:,1)==fignum-1);
                disturbanceTime = day_arousalTime_mat(disturbanceDaySubindex,2);
                disturbanceTime_min = disturbanceTime*60;
            plot([disturbanceTime_min disturbanceTime_min],[25 25],'r');
            end;
            xlim([0 numel(activityCountsForDay)]);
            title(['Activity']);

            
            subplot(2,2,2);
            if(ismember(fignum-1,day_arousalTime_mat(:,1))),
                disturbanceDaySubindex = find(day_arousalTime_mat(:,1)==fignum-1);
                disturbanceTime = day_arousalTime_mat(disturbanceDaySubindex,2);
                disturbanceTime_min = disturbanceTime*60;
            plot([disturbanceTime disturbanceTime]*2,[25 25],'r');
            end;
            xlim([0 numel(activityCounts30min_bin)]);
            title(['Activity']);
            
            subplot(2,2,3);
            if(ismember(fignum-1,day_arousalTime_mat(:,1))),
                disturbanceDaySubindex = find(day_arousalTime_mat(:,1)==fignum-1);
                disturbanceTime = day_arousalTime_mat(disturbanceDaySubindex,2);
                disturbanceTime_min = disturbanceTime*60;
                plot([disturbanceTime_min disturbanceTime_min],[1 1],'r');
            end;
            xlim([0 numel(activityCountsForDay)]); ylim([1 1.2]);
            title(['Sleep']);
            
            subplot(2,2,4);
            if(ismember(fignum-1,day_arousalTime_mat(:,1))),
                disturbanceDaySubindex = find(day_arousalTime_mat(:,1)==fignum-1);
                disturbanceTime = day_arousalTime_mat(disturbanceDaySubindex,2);
                disturbanceTime_min = disturbanceTime*60;
            plot([disturbanceTime disturbanceTime]*2,[25 25],'r');
            end;
            xlim([0 numel(activityCounts30min_bin)]);
            title(['Sleep']);
%             subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
%             title([expName ' Ch' num2str(ci) ': ' groupNameByChannel{ci}]);
%             subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
            
            orient(figure(fignum),'landscape');
            print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
            close(figure(fignum));
    end;
    totalsForGroup = cell(maxDays,2);
    for(di = 1:size(thisGroupActivity,1)),    
        
        %(ismember(di,day_arousalTime_mat(:,1))),
        figure(2);
        activityDat = thisGroupActivity{di,1};
        sleepDat = thisGroupActivity{di,2};
        totalsForGroup{di,1} = sum(activityDat,2);
        totalsForGroup{di,2} = sum(sleepDat,2);
        
        meanAct = median(activityDat);
        stdAct = std(activityDat);
        meanSleep = median(sleepDat);
        stdSleep = std(sleepDat);
        stdArea = [quantile(activityDat,0.25); quantile(activityDat,0.75)-quantile(activityDat,0.25)];
        
        
        subplot(maxDays,2,(di-1)*2+1);
        hArea = area(timepts,stdArea');
        set(hArea(1),'Visible','off');
        set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
        alpha(0.2);
        plot(timepts,meanAct,'Color',groupColors(gi,:));
        ylim([-5 35]);
        
        stdArea = [quantile(sleepDat,0.25); quantile(sleepDat,0.75)-quantile(sleepDat,0.25)];
%         stdArea = [meanSleep-stdSleep; 2*stdSleep];
        subplot(maxDays,2,2*di);
        hArea = area(timepts,stdArea');
        set(hArea(1),'Visible','off');
        set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
        alpha(0.2);
        plot(timepts,meanSleep,'Color',groupColors(gi,:));
        ylim([-5 35]);
        %--------------------------------
        figure(3);
        subplot(2,2,1);
        totalActivity = totalsForGroup{di,1};
        plot(ones(size(totalActivity))*di+0.3*(gi-1),totalActivity,'o','LineStyle','none','Color',groupColors(gi,:)); hold on;
        ylim([0 1440]);
        
        subplot(2,2,2);
        totalSleep = totalsForGroup{di,2};
        plot(ones(size(totalSleep))*di+0.3*(gi-1),totalSleep,'o','LineStyle','none','Color',groupColors(gi,:)); hold on;
        ylim([0 1440]);
        
        subplot(2,2,3);
        plotMedianQuartiles(totalActivity,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        subplot(2,2,4);
        plotMedianQuartiles(totalSleep,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        %--------------------------------
        figure(4);
        subplot(2,2,1); %Plot the latency of individual flies.
        plot(ones(size(fliesAwakenedByArousal(:,di,3)))*di,fliesAwakenedByArousal(:,di,3),'o','LineStyle','none','Color',groupColors(gi,:));
        hold on;
        
        subplot(2,2,2); %Plot the latency of individual mean and SD.
        plotMedianQuartiles(fliesAwakenedByArousal(:,di,3),di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        
        %Save the number of flies awakened for subplot 3.
        fliesAwakenedPerDay(di) = squeeze(nansum(fliesAwakenedByArousal(:,di,1).*fliesAwakenedByArousal(:,di,2)))/nansum(fliesAwakenedByArousal(:,di,2));        
    end;
end;
figure(2);
subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
subplot(maxDays,2,2); ylabel(['Sleep (mins)']);

figure(3);
subplot(2,2,1); ylabel(['Activity/Day (mins)']);
subplot(2,2,2); ylabel(['Sleep/Day (mins)']);
subplot(2,2,3); ylabel(['Day']);
subplot(2,2,4); ylabel(['Day']);

figure(4);
subplot(2,2,1);
set(gca,'XTick',day_arousalTime_mat(:,1),'XTickLabel',day_arousalTime_mat(:,2));
subplot(2,2,2);
set(gca,'XTick',day_arousalTime_mat(:,1),'XTickLabel',day_arousalTime_mat(:,2));
subplot(2,2,3);
plot(day_arousalTime_mat(:,1),fliesAwakenedPerDay(day_arousalTime_mat(:,1),:),'ro-');
set(gca,'XTick',day_arousalTime_mat(:,1),'XTickLabel',day_arousalTime_mat(:,2));


for(fignum = 2:4),
    orient(figure(fignum),'landscape');
    print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
    close(figure(fignum));
end;

ps2pdf('psfile', [output '.ps'], 'pdffile', [output '.pdf'], ...
    'gspapersize', 'letter',...
    'verbose', 1, ...
    'gscommand', 'C:\Program Files\gs\gs9.10\bin\gswin64.exe');
%=======================================================

function allChannelDatByDay = processChannels(rawFolder,groupNameByChannel)
cd(rawFolder);
allChannelDatByDay = cell(size(groupNameByChannel));
for(ci = 1:size(groupNameByChannel,1)),
%     if(strmatch(groupNameByChannel{ci},groupName2Match)),
        channelNameFormat = sprintf('*C%02d.txt',ci)
        allFiles = dir(channelNameFormat);
        channelDatByDay = cell(size(allFiles,1),2);
        for(fi = 1:size(allFiles,1)),
            filename = allFiles(fi).name;
            fID = fopen(filename);
            lineFileDate = fgets(fID);
            dateString = lineFileDate(15:end);
            dateVec = datevec(dateString);
            
            numSamplePts = str2double(fgets(fID));
            line3 = fgets(fID);
            line4 = fgets(fID);
            
            allSamplePts_vec = NaN(numSamplePts,1);
            timeptsZT_datevec = zeros(numSamplePts,6);
            timeptsZT_datevec(:,1) = dateVec(1);
            timeptsZT_datevec(:,2) = dateVec(2);
            timeptsZT_datevec(:,3) = dateVec(3);
            timeptsZT_datenum = zeros(numSamplePts,1);
            
            for(ti = 1:numSamplePts),
                samplesPerMin = str2double(fgets(fID));
                allSamplePts_vec(ti) = samplesPerMin;
                minute_time = mod(ti,60); %This is in ZT time, not absolute time, since DAMFileScan has already converted things into ZT0.
                hr_time = round(ti/60);
                timeptsZT_datevec(ti,4:5) = [hr_time minute_time];
                %Just to make sure, want to convert the time into datenum so that I can sort later.
                timeptsZT_datenum(ti) = datenum(timeptsZT_datevec(ti,:));
            end;
            
            [sortedTimes, sortedIndices] = sort(timeptsZT_datenum);
            timeptsZT_sortedDatenum = sortedTimes;
            allSamplePts_sortedVec = allSamplePts_vec(sortedIndices);
            channelDatByDay{fi,1} = timeptsZT_sortedDatenum;
            channelDatByDay{fi,2} = allSamplePts_sortedVec;
        end; %Have read all files that match the string format for the channel number in question.
        allChannelDatByDay{ci} = channelDatByDay;
%     end;
end;