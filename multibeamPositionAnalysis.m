function multibeamPositionAnalysis()
%https://trikinetics.com/Downloads/MB5%20Data%20Sheet.pdf
%
%This function outputs the average time a fly spends in a specific
%position.
%Takes in data output from DamFileScan in the "Channel Positions" format, which is a list of the position in which the fly spends the most time. 

close all; clear all;
rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Odor Delivery\MethylAmine_Multibeam_191112'
plotAreaQuartiles = 1;
profileBinSize = 12*60; %10; %usually 30;
rawdir = [rootdir '\Positions'];
maxDays =5;
backslashIndices = strfind(rootdir,'\');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList'];

groupNames = {'Paraffin oil'; 'Methyl amine'}; %; 'Air'};
groupColors = [0 0 0; 1 0 0; 0 0 1]; %; 0 1 0; 0 0 1]; %; 0 1 0]; %; 0 0 1]; %; 0 0 0; 1 0 1];

cd(rootdir);

[n,t,r] = xlsread([flyIDname '.xlsx']);

output = [flyIDname '_positions_' num2str(profileBinSize) 'minBins'];
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);
if(~exist([output '.mat'],'file')),
    if(size(r,2)>=3),
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel,r(:,1),r(:,3),maxDays);
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
                trueMaxDays = min(maxDays,size(thisChannelDatByDay,1));
                for(di = 1:trueMaxDays),
                    %In this version of the script, activityCountsForDay =
                    %position information.
                    activityCountsForDay = thisChannelDatByDay{di,2};
                    display(di);
                        activityCounts30min_bin = mean(reshape(activityCountsForDay,profileBinSize,24*(60/profileBinSize)),1);
                    subplot(maxDays,2,(di-1)*2+1);
                    timepts = ([1:numel(activityCounts30min_bin)]-1)/(60/profileBinSize);
                    try,
                        plot(timepts,activityCounts30min_bin,'Color',groupColors(gi,:));
                    catch,
                        display('mr?');
                    end;
                    xlim([0 24]); ylim([0 17]);
                    
                    %Want to save the information for this day into the
                    %relevant cell of the thisGroupActivity array.
                    thisDayGroupActivity = thisGroupActivity{di,1};
                    if(isempty(thisDayGroupActivity)),
                        thisGroupActivity{di,1} = activityCounts30min_bin;
                        
                    else,
                        thisDayGroupActivity = [thisGroupActivity{di,1}; activityCounts30min_bin];
                        thisGroupActivity{di,1} = thisDayGroupActivity;
                    end;
                end;
                subplot(maxDays,2,1); ylabel(['Avg position in ' num2str(profileBinSize) ' min bin']);
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
%         sleepDat = thisGroupActivity{di,2};
        %         display(size(sum(activityDat,2)));
%         display(size(thisGroupActivity{di,3}));
        if(max(size(thisGroupActivity{di,1}>0))),
            totalsForGroup{di,1} = nanmean(activityDat,2); %./thisGroupActivity{di,3};
            meanAct = median(activityDat);
            stdAct = std(activityDat);
            stdArea = [quantile(activityDat,0.25); quantile(activityDat,0.75)-quantile(activityDat,0.25)];
            
            %         try,
            subplot(maxDays,2,(di-1)*2+1);
            %         try,
            if(numel(stdArea)>2 && plotAreaQuartiles),
                display(numel(stdArea));
                hArea = area(timepts,stdArea');
                set(hArea(1),'Visible','off');
                set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
                alpha(0.2);
            end;
            plot(timepts,meanAct,'Color',groupColors(gi,:)); hold on;
            ylim([0 17]); xlim([0 24]);
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
    if(nargin>4)
        maxDays=varargin{3};
    end;
end;
for(csubi = 1:size(groupNameByChannel,1)),
    ci = double(channelList{csubi});
    %     if(strmatch(groupNameByChannel{ci},groupName2Match)),
    if(exist('monitorDat','var')),
        mnum = double(monitorDat{csubi});
        %         channelNameFormat = sprintf('*CtM%03dC%02d.txt',mnum,ci);
        channelNameFormat = sprintf('*M%03dC%02d.txt',mnum,ci);
    else,
        channelNameFormat = sprintf('*C%02d.txt',ci);
    end;
    allFiles = dir(channelNameFormat);
    %Contains all the files relevant to the monitor and channel name in question. Should theoretically be equal to the number of days.
    channelDatByDay = cell(size(allFiles,1),2);
    datenumList = NaN(size(channelDatByDay,1),1);
    if(size(allFiles,1)>1 || maxDays==1),
        for(fi = 1:size(allFiles,1)),
            filename = allFiles(fi).name
            fID = fopen(filename);
            lineFileDate = fgets(fID);
            dateString = lineFileDate(15:end);
            dateVec = datevec(dateString);
            
            numSamplePts = str2double(fgets(fID));
            if(numSamplePts<=1440),
                numSamplePts = 1440;
            end;
            line3 = fgets(fID); %Lines 3 and 4 are discarded.
            line4 = fgets(fID);
            
            allSamplePts_vec = NaN(numSamplePts,1);
            timeptsZT_datevec = zeros(numSamplePts,6);
            timeptsZT_datevec(:,1) = dateVec(1); %dateVec contains the date of the channel file (first line of the channel data.
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
            datenumList(fi) = timeptsZT_sortedDatenum(1);
            fclose(fID);
            %         end; %Have saved all of the samplePts in the file/day in question in the relevant slot in channelDatByDay{fi,1};
        end; %Have read all files that match the string format for the channel number in question.
        
        [sortedTimes,sortedIndices] = sort(datenumList,'ascend');
        channelDatByDay_unsorted = channelDatByDay;
        for(si = 1:numel(sortedIndices)),
            channelDatByDay{si,1} = channelDatByDay_unsorted{sortedIndices(si),1};
            channelDatByDay{si,2} = channelDatByDay_unsorted{sortedIndices(si),2};
        end;
    else,
        %DamFiles were saved in a multi-day format.
        %         try,
        if(size(allFiles,1)==1),
            filename = allFiles(1).name;
            if(exist(filename,'file'));
                display(['Loading ' filename]);
                fID = fopen(filename);
                %         else,
                %             ME = MException('MyComponent:noSuchVariable', ...
                %                 'Could not find files of the format %s',channelNameFormat);
                %             %         'Variable %s not found',str);
                %             throw(ME)
                %         end;
                lineFileDate = fgets(fID);
                dateString = lineFileDate(15:end);
                dateVec = datevec(dateString);
                
                numSamplePts = str2double(fgets(fID));
                line3 = fgets(fID); %Lines 3 and 4 are discarded.
                line4 = fgets(fID);
                
                allSamplePts_vec = NaN(numSamplePts,1);
                timeptsZT_datevec = zeros(numSamplePts,6);
                timeptsZT_datevec(:,1) = dateVec(1); %dateVec contains the date of the channel file (first line of the channel data).
                timeptsZT_datevec(:,2) = dateVec(2);
                timeptsZT_datevec(:,3) = dateVec(3);
                timeptsZT_datenum = zeros(numSamplePts,1);
                fi = 1;
                for(ti = 1:numSamplePts),
                    samplesPerMin = str2double(fgets(fID));
                    allSamplePts_vec(ti) = samplesPerMin;
                    minute_time = mod(ti,60); %This is in ZT time, not absolute time, since DAMFileScan has already converted things into ZT0.
                    hr_time = round(ti/60);
                    timeptsZT_datevec(ti,4:5) = [hr_time minute_time];
                    %Just to make sure, want to convert the time into datenum so that I can sort later.
                    timeptsZT_datenum(ti) = datenum(timeptsZT_datevec(ti,:))+fi-1;
                    %             end;
                    if(mod(ti,1440)==0),
%We haven't reached the end of the day yet.                        %                         else,
                        %             display('help!');
                        %                         end;
%                         try,
                                        [sortedTimes, sortedIndices] = sort(timeptsZT_datenum(ti-1440+1:ti));
                        %             try,
                        allSamplePts_vecThisDay = allSamplePts_vec(ti-1440+1:ti);
                        %             catch,
                        %             end;
                        %                 timeptsZT_sortedDatenum = sortedTimes;
                        %                 allSamplePts_sortedVec = allSamplePts_vecThisDay(sortedIndices);
                        %                 channelDatByDay{fi,1} = timeptsZT_sortedDatenum;
                        channelDatByDay{fi,2} = allSamplePts_vecThisDay; %allSamplePts_sortedVec;
%                         datenumList(fi) = timeptsZT_sortedDatenum(1);
                        fi = fi+1;
%                         catch,
%                             display('help.');
%                         end;
                    end;
                end;
                fclose(fID);
                %         end;
                %         %Don't need to sort since DamFileScan already took care of that
                %         for us.
                %         [sortedTimes,sortedIndices] = sort(datenumList,'ascend');
                %         channelDatByDay_unsorted = channelDatByDay;
                %         for(si = 1:numel(sortedIndices)),
                %             channelDatByDay{si,1} = channelDatByDay_unsorted{sortedIndices(si),1};
                %             channelDatByDay{si,2} = channelDatByDay_unsorted{sortedIndices(si),2};
                %         end;
            end;
        end;
    end;
    allChannelDatByDay{csubi} = channelDatByDay; %number of rows in this cell array match up with the number of channels.
end;