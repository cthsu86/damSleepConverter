function multibeamDwellAnalysis()
%https://trikinetics.com/Downloads/MB5%20Data%20Sheet.pdf
%
%Requires a folder, "Tube Counts", where "Tube Count" data has been output
%from DamFileScan. Will scan each for number of counts (movements within
%abeam) for each beam.

close all; clear all;
rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Odor Delivery\MethylAmine_Multibeam_191112'
plotAreaQuartiles = 1;
profileBinSize = 30; %usually 30;
rawdir = [rootdir '\Tube Counts'];
positionRangeOfInterest = [1 17]; %If only examining one position, just write it twice.
maxDays =5;
backslashIndices = strfind(rootdir,'\');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList'];

groupNames = {'Paraffin oil';'Methyl amine'};
groupColors = [0 0 0; 1 0 0; 0 0 1]; %; 0 1 0; 0 0 1]; %; 0 1 0]; %; 0 0 1]; %; 0 0 0; 1 0 1];

cd(rootdir);

[n,t,r] = xlsread([flyIDname '.xlsx']);

output = [flyIDname '_tubeCount' num2str(positionRangeOfInterest(1)) 'to' num2str(positionRangeOfInterest(2))];
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);
if(~exist([output '.mat'],'file')),
    if(size(r,2)>=3),
        allChannelDatByDay = processChannels(rawdir,groupNameByChannel,r(:,1),r(:,3),maxDays,positionRangeOfInterest);
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
                    activityCountsForDay = thisChannelDatByDay{di,2}; %1440 long vector.
                    display(di);
                    activityCounts30min_bin = sum(reshape(activityCountsForDay,profileBinSize,24*(60/profileBinSize)),1);
                    subplot(maxDays,2,(di-1)*2+1);
                    timepts = ([1:numel(activityCounts30min_bin)]-1)/(60/profileBinSize);
                    try,
                        plot(timepts,activityCounts30min_bin,'Color',groupColors(gi,:));
                    catch,
                        display('mr?');
                    end;
                    xlim([0 24]); %ylim([0 17]);
                    
                    %Want to save the information for this day into the
                    %relevant cell of the thisGroupActivity array.
                    thisDayGroupActivity = thisGroupActivity{di,1};
                    if(isempty(thisDayGroupActivity)),
                        thisGroupActivity{di,1} = activityCounts30min_bin;
                        
                    else,
                        thisDayGroupActivity = [thisGroupActivity{di,1}; activityCounts30min_bin];
                        thisGroupActivity{di,1} = thisDayGroupActivity;
                    end;
                    
                    %For TubeCount analysis, we also want to save sleep
                    %information computed from counts from the selected
                    %positions within the tube, since position 9 is used to
                    %compute sleep information comparable to what would be
                    %in a single tube.
                                        
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
                        isSleep(stoppedStarts(trueSleepStopBoutIndices(si)):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
                    end;
                    sleep30min_bin = sum(reshape(isSleep,profileBinSize,24*(60/profileBinSize)),1);
                    thisDayGroupSleep = thisGroupActivity{di,2};
                    if(isempty(thisDayGroupSleep)),
                    thisGroupActivity{di,2} = sleep30min_bin;
                    else,
                        thisDayGroupSleep = [thisGroupActivity{di,2}; sleep30min_bin];
                        thisGroupActivity{di,2} = thisDayGroupSleep;
                    end;
                end;
                subplot(maxDays,2,1); ylabel(['Counts in Pos ' num2str(positionRangeOfInterest(1)) ' to ' num2str(positionRangeOfInterest(2)) ' per ' num2str(profileBinSize) ' min bin']);
                ylim([0 400]);
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
            xlim([0 24]);
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
        positionRangeOfInterest = varargin{4};
    end;
end;
for(csubi = 1:size(groupNameByChannel,1)),
    ci = double(channelList{csubi});
    mnum = double(monitorDat{csubi});
    %FileNameFormat:     1101DwM001T01
    channelNameFormat = sprintf('*M%03dT%02d.txt',mnum,ci);
    allFiles = dir(channelNameFormat);
    %Contains all the files relevant to the monitor and channel name in question. Should theoretically be equal to the number of days.
    channelDatByDay = cell(size(allFiles,1),2);
    if(size(allFiles,1)==1),
        filename = allFiles(1).name;
        if(exist(filename,'file'));
            display(['Loading ' filename]);
            fID = fopen(filename);
            numSamplePts = 1440*maxDays; %str2double(fgets(fID));
            
            allSamplePts_vec = NaN(numSamplePts,1);
            timeptsZT_datevec = zeros(numSamplePts,6);
            timeptsZT_datenum = zeros(numSamplePts,1);
            fi = 1;
            for(ti = 1:numSamplePts),
                lineOfData = fgets(fID);
                tabIndices = strfind(lineOfData,char(9));
                %This produces 41 tabs, whose indices range from 2 to 99.
                %Column 11: Position
                %Column 12: Total Dwell (seconds)
                %Column 13-42: Dwell in each beam
                try,
                dwellDat = str2num(lineOfData((tabIndices(13)-1):end));
                catch,
                    display([num2str(numel(tabIndices)) ' tabs found']);
                end;
                dwellTimeInROI = sum(dwellDat(positionRangeOfInterest(1):positionRangeOfInterest(2)));
                
%                 samplesPerMin = str2double(fgets(fID));
                allSamplePts_vec(ti) = dwellTimeInROI;
                if(mod(ti,1440)==0),
                    allSamplePts_vecThisDay = allSamplePts_vec(ti-1440+1:ti);
                    channelDatByDay{fi,2} = allSamplePts_vecThisDay; %allSamplePts_sortedVec;
                    fi = fi+1;
                end;
            end;
            fclose(fID);
        end;
    end;
    allChannelDatByDay{csubi} = channelDatByDay; %number of rows in this cell array match up with the number of channels.
end;