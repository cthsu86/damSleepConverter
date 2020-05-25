function indivBaselineDAManalysis()
close all; clear all;
rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Odor Delivery\OdorExp8_170526';
rawdir = [rootdir '\Raw Data'];
groupNames = {'No stimulus'; 'Air'; 'Food'; 'Fly odor'}; %; 'Ax Day 10'};
groupColors = [0 0 0; 0 0 1; 0.5 0.5 0; 1 0 0]; %0 0 0; 1 0 1];

% groupNames = {'Intact'; 'Palp'; 'Ax Day 4'; 'Ax Day 10'};
% groupColors = [0 0 0; 0 0 1; 1 0 0; 1 0 1]; %0 0 0; 1 0 1];
% groupNames = {'No stim'; 'Air'; 'ACV'; 'Fly odor'};
% groupColors = [0 0 0; 1 0 0; 0.5 0.5 0; 0 0 1];
% groupNames = {'No stimulus'; 'Fly odor'; 'Food'; 'Air'}; %'; 'Dep'};
% groupNames = {'Ctrl'; 'Compounds ocelli'; 'Ocelli'};
% groupNames = {'tubGal80ts; UAS-KIR';'GMR-Gal4'; 'tubGal80ts; GMR>UAS-KIR'};
% groupNames = {'UAS-shib'; '103y>UAS-Shib'; '103y'}; %, iso31';'Air, iso31';'Acetic Acid, iso31'}; %; 'Day 0'};
% groupColors = [0 0 0; 1 0 0; 0 0 1]; %; 0 1 0; 0 0 1]; %; 0 1 0]; %; 0 0 1]; %; 0 0 0; 1 0 1];
maxDays = 6;

cd(rootdir);
backslashIndices = strfind(rootdir,'\');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList'];
% flyIDname = '161229_channelList trueGenotype';
[n,t,r] = xlsread([flyIDname '.xlsx']);

output = [flyIDname];
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);
if(~exist([output '.mat'],'file')),
    if(size(r,2)==3),
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel,r(:,1),r(:,3));
    else,
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel);
    end;
    cd(rootdir);
    save([output '.mat'],'allChannelDatByDay');
    display(['Have saved ' output '.mat']);
else,
    allChannelDatByDay = load([output '.mat']);
    allChannelDatByDay = allChannelDatByDay.allChannelDatByDay;
end;

allDatByGroup = cell(numel(groupNames),2);
for(gi = 1:numel(groupNames)),
    allDatByGroup{gi,1} = groupNames{gi};
    display(groupNames{gi});
    thisGroupActivity = cell(maxDays,4); %col1 = activity, col2 = sleep.
    for(ci = 1:size(groupNameByChannel,1)),
        if(strcmp(groupNames{gi},groupNameByChannel{ci})),
            thisChannelDatByDay = allChannelDatByDay{ci};
            if(~isempty(thisChannelDatByDay)),
                figure(1);
                for(di = 1:size(thisChannelDatByDay,1)),
                    activityCountsForDay = thisChannelDatByDay{di,2};
                    display(di);
                    try,
                        activityCounts30min_bin = sum(reshape(activityCountsForDay,30,48),1);
                    catch,
                        display(numel(activityCountsForDay));
                    end;
                    subplot(maxDays,2,(di-1)*2+1);
                    timepts = ([1:numel(activityCounts30min_bin)]-1)/2;
                    plot(timepts,activityCounts30min_bin,'Color',groupColors(gi,:));
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
                    minsAwake = 1440-sum(isSleep);
                    sleep30min_bin = sum(reshape(isSleep,30,48),1);
                    subplot(maxDays,2,di*2);
                    plot(timepts,sleep30min_bin,'Color',groupColors(gi,:));
                    xlim([0 24]); ylim([0 30]);
                    
                    %Want to save the information for this day into the
                    %relevant cell of the thisGroupActivity array.
                    thisDayGroupActivity = thisGroupActivity{di,1};
                    if(isempty(thisDayGroupActivity)),
                        thisGroupActivity{di,1} = activityCounts30min_bin;
                        thisGroupActivity{di,2} = sleep30min_bin;
                        thisGroupActivity{di,3} = minsAwake;
                        thisGroupActivity{di,4} = isSleep';
                    else,
                        thisDayGroupActivity = [thisGroupActivity{di,1}; activityCounts30min_bin];
                        thisDaySleepActivity = [thisGroupActivity{di,2}; sleep30min_bin];
                        thisDayMinsAwake = [thisGroupActivity{di,3}; minsAwake];
                        thisDaySleepBinary = [thisGroupActivity{di,4}; isSleep'];
                        
                        thisGroupActivity{di,1} = thisDayGroupActivity;
                        thisGroupActivity{di,2} = thisDaySleepActivity;
                        thisGroupActivity{di,3} = thisDayMinsAwake;
                        thisGroupActivity{di,4} = thisDaySleepBinary;
                    end;
                end;
                
                subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
                title([expName ' M' num2str(r{ci,3}) ' Ch' num2str(r{ci,1}) ': ' groupNameByChannel{ci}]);
                subplot(maxDays,2,2); ylabel(['Sleep (mins)']);
                
                orient(figure(1),'landscape');
                print(figure(1),'-dpsc2',[output '.ps'],'-append');
                close(figure(1));
                
            end;
        else,
            display(['gi=' num2str(gi) ' did not match ' groupNames{gi}]);
        end;
    end;
    allDatByGroup{gi,2} = thisGroupActivity;
    
    totalsForGroup = cell(maxDays,2);
    for(di = 1:size(thisGroupActivity,1)),
        figure(2);
        activityDat = thisGroupActivity{di,1};
        sleepDat = thisGroupActivity{di,2};
        %         display(size(sum(activityDat,2)));
        display(size(thisGroupActivity{di,3}));
        if(max(size(thisGroupActivity{di,3}>0))),
            totalsForGroup{di,1} = sum(activityDat,2)./thisGroupActivity{di,3};
            totalsForGroup{di,2} = sum(sleepDat,2);
            
            %         meanAct = mean(activityDat);
            %         stdAct = std(activityDat);
            %         meanSleep = mean(sleepDat);
            %         stdSleep = std(sleepDat);
            %         stdArea = [meanAct-stdAct; 2*stdAct];
            meanAct = median(activityDat);
            stdAct = std(activityDat);
            meanSleep = median(sleepDat);
            stdSleep = std(sleepDat);
            stdArea = [quantile(activityDat,0.25); quantile(activityDat,0.75)-quantile(activityDat,0.25)];
            
            %         try,
            subplot(maxDays,2,(di-1)*2+1);
            %         try,
            hArea = area(timepts,stdArea');
            %         catch,
            %             display('debug.');
            %         end;
            set(hArea(1),'Visible','off');
            set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
            alpha(0.2);
            plot(timepts,meanAct,'Color',groupColors(gi,:));
            ylim([0 150]);
            
            stdArea = [quantile(sleepDat,0.25); quantile(sleepDat,0.75)-quantile(sleepDat,0.25)];
            subplot(maxDays,2,2*di);
            hArea = area(timepts,stdArea');
            set(hArea(1),'Visible','off');
            set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
            alpha(0.2);
            plot(timepts,meanSleep,'Color',groupColors(gi,:));
            ylim([0 30]);
            
            figure(3);
            subplot(2,2,1);
            totalActivity = totalsForGroup{di,1}; %./totalsForGroup{di,3};
            plot(ones(size(totalActivity))*di+0.3*(gi-1),totalActivity,'o','LineStyle','none','Color',groupColors(gi,:)); hold on;
            ylim([0 10]);
            
            subplot(2,2,2);
            totalSleep = totalsForGroup{di,2};
            plot(ones(size(totalSleep))*di+0.3*(gi-1),totalSleep,'o','LineStyle','none','Color',groupColors(gi,:)); hold on;
            ylim([0 1440]);
            
            subplot(2,2,3);
            plotMedianQuartiles(totalActivity,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
            ylim([0 10]);
            
            subplot(2,2,4);
            plotMedianQuartiles(totalSleep,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
            ylim([0 1440]);
        end;
    end;
end;

cd(rootdir);
save([output '.mat'],'allChannelDatByDay','allDatByGroup');
display(['Have saved ' output '.mat']);
% end;
figure(2);
subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
subplot(maxDays,2,2); ylabel(['Sleep (mins)']);

figure(3);
subplot(2,2,1); ylabel(['Activity/Waking min']);
title([output]);
subplot(2,2,2); ylabel(['Sleep/Day (mins)']);
subplot(2,2,3); xlabel(['Day']);
subplot(2,2,4); xlabel(['Day']);

for(fignum = 2:3),
    orient(figure(fignum),'landscape');
    print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
    close(figure(fignum));
end;

ps2pdf('psfile', [output '.ps'], 'pdffile', [output '.pdf'], ...
    'gspapersize', 'letter',...
    'verbose', 1, ...
    'gscommand', 'C:\Program Files\gs\gs9.21\bin\gswin64.exe');
%=======================================================

function allChannelDatByDay = processChannels(rawFolder,groupNameByChannel,varargin)
cd(rawFolder);
allChannelDatByDay = cell(size(groupNameByChannel));
if(nargin>2),
    channelList = varargin{1};
    monitorDat = varargin{2};
end;
for(csubi = 1:size(groupNameByChannel,1)),
    ci = double(channelList{csubi});
    %     if(strmatch(groupNameByChannel{ci},groupName2Match)),
    if(exist('monitorDat','var')),
        mnum = double(monitorDat{csubi});
        channelNameFormat = sprintf('*M%03dC%02d.txt',mnum,ci);
    else,
        channelNameFormat = sprintf('*C%02d.txt',ci);
    end;
    allFiles = dir(channelNameFormat);
    channelDatByDay = cell(size(allFiles,1),2);
    for(fi = 1:size(allFiles,1)),
        filename = allFiles(fi).name
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
        fclose(fID);
    end; %Have read all files that match the string format for the channel number in question.
    allChannelDatByDay{csubi} = channelDatByDay;
    %     end;
end;