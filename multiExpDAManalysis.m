function multiExpDAManalysis()
close all;
% primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Dop1R mutants with cohort';
% xl2read = 'Dop1R2 no hets mat2read.xlsx';
primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Olfactory Surgery\';
xl2read = 'Ax vs Ctrl ZT4clip mat2read.xlsx';
exp_gi = 2;
% groupColors = [0 0 0; %Black: UAS ctrl, 'tubGal80ts/iso31; UAS-kir-2.1/iso31';
%     0.75 0.5 0;% Red: 'orco/iso31; tubGal80ts/iso31; UAS-kir-2.1/iso31';
% 0 0 1; % Blue: 'orco/iso31';
% 0 1 1; % Cyan: 'orco/iso31; iso31; 23E10/iso31';
% 1 0 0;%     'Red: orco/iso31; tubGal80ts/iso31; 23E10/UAS-kir-2.1';
% 0.5 0.5 0.5; %     '23E10/iso31';
% 0 1 0]; %     'Green: tubGal80ts/iso31; 23E10/UAS-kir-2.1'};
%6 colors
% groupColors = [0 0 0; 0.5 0.5 0; 0 1 0; 1 0 0; 0 0 1; 1 0 1]; %0 0 1; 1 0 0];
% groupColors = [0 1 0; 1 0 0; 0 0 1; 1 0 1]; %0 0 1; 1 0 0];
% groupColors = [0 0 0; 1 0 0; 0 0 1];
groupColors = [0 0 0; 1 0 0; 0 0 1; 1 0 1; 0 1 1];
showNormality = 0;
% primedir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Shibire'; %\ShibireExp3_170408';
% xl2read = 'orco not backcrossed mat2read.xlsx';
maxDays = 5;
subp_cols = ceil(sqrt(maxDays));
subp_rows = ceil(maxDays/subp_cols);
durationMinuteBins = 10:10:600;

output = strrep(xl2read,'mat2read.xlsx','plots');

cd(primedir);
if(exist([output '.ps'],'file'));
    delete([output '.ps']);
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
        minsAwakePerGroup = [];
        sleepBinaryPerGroup = [];
        for(ri = 1:size(raw,1)),
            
            groupName2Match = raw{ri,gi+2};
            rootdir = raw{ri,1};
            matname = raw{ri,2};
%             display(['Entering ' rootdir]);
%             display(numel(rootdir));
if(ischar(rootdir) && isdir(rootdir)),
            cd(rootdir);
            M = load(matname);
            groupDatForExp = M.allDatByGroup;
            for(gii=1:size(groupDatForExp,1)),
                if(strcmp(groupDatForExp{gii,1},groupName2Match)),
                    gi2match=gii;
                else,
                    display(['gii=' num2str(gii) ', ' groupDatForExp{gii,1}]);
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
                    end;
                end;
                clear gi2match;
            end;
        end;
        
        end;
        %Have accumulated all information for this group on this day now.
        %Plot!
        
        %         if(max(size(thisGroupActivity{di,3}>0))),
        timepts = [0.5:1:47.5]; %([1:size(activityCounts30min_bin,2)]-1)/2;
        meanAct = median(activityPerMinutePerGroup);
        meanSleep = median(sleepPerMinutePerGroup);
        stdArea = [quantile(activityPerMinutePerGroup,0.25); quantile(activityPerMinutePerGroup,0.75)-quantile(activityPerMinutePerGroup,0.25)];
        
        %-------------Plot the 24 hour cycle.--------------------------
        figure(1);
        subplot(maxDays,2,(di-1)*2+1);
        if(numel(stdArea)>2)
            display(size(stdArea));
            display(size(timepts));
            hArea = area(timepts,stdArea');
            set(hArea(1),'Visible','off');
            
            set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
            alpha(0.2);
        end;
        plot(timepts,meanAct,'Color',groupColors(gi,:));
        ylim([0 150]);
        
        stdArea = [quantile(sleepPerMinutePerGroup,0.25); quantile(sleepPerMinutePerGroup,0.75)-quantile(sleepPerMinutePerGroup,0.25)];
        subplot(maxDays,2,2*di);
        if(numel(stdArea)>2),
            hArea = area(timepts,stdArea');
            set(hArea(1),'Visible','off');
            set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
            alpha(0.2);
        end;
        plot(timepts,meanSleep,'Color',groupColors(gi,:));
        text(15+(gi-1)*5,5,['n=' num2str(size(sleepPerMinutePerGroup,1))],'Color',groupColors(gi,:));
        %         text([20,5,['n=' num2str(size(sleepPerMinutePerGroup,1))],'Color','r');
        ylim([0 30]);
        %--------------------------------------------------
        figure(2);
%         subplot(2,2,1);
        totalActivity = nansum(activityPerMinutePerGroup,2)./minsAwakePerGroup; %nansum(minsAwakePerGroup,2); %./totalsForGroup{di,3};
        plot(ones(size(totalActivity))*di+0.2*(gi-1)-0.5,totalActivity,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
        
        if(showNormality),
            text(0,9,'Normality (kstest)');
            [h,p] = kstest(totalActivity)
            text(di+0.2*(gi-1)-0.5,max(totalActivity)+1,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        end;
        ylim([0 10]); xlim([0 maxDays+1]);
        
        subplot(2,2,2);
        totalSleep = nansum(sleepPerMinutePerGroup,2);
        plot(ones(size(totalSleep))*di+0.2*(gi-1)-0.5,totalSleep,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
        if(showNormality),
            [h,p] = kstest(totalSleep);
            text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        end;
        ylim([0 1440]); xlim([0 maxDays+1]);
        
        subplot(2,2,3);
        plotMedianQuartiles(totalActivity,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 10]); xlim([0 maxDays+1]);
        
        subplot(2,2,4);
        plotMedianQuartiles(totalSleep,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 1440]); xlim([0 maxDays+1]);
        
        %         actPerMin_CtrlVsExp = cell{maxDays,2};
        %         totalSleep_CtrlVsExp = cell{maxDays,2};
        actPerMin_CtrlVsExp{di,gi} = totalActivity;
        totalSleep_CtrlVsExp{di,gi} = totalSleep;
        
        %-------------PLOT BOUT DURATION CUMULATIVE HIST-----------------
        figure(3);

        %Here, iterate through all the flies in the group and plot.
        
        latency_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        longestSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        meanSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        numSleep_dayGroup = NaN(size(sleepBinaryPerGroup,1),1);
        sleepBoutDurationVsStartTime = cell(size(sleepBinaryPerGroup,1),2);
        for(xi = 1:size(sleepBinaryPerGroup,1)),
            thisFlyBinary = sleepBinaryPerGroup(xi,:);
            %             try,
            [durationHist, allDurations, sleepBoutStarts] = durationHistogram(thisFlyBinary, durationMinuteBins);
            figure(3);
                    subplot(subp_rows,subp_cols,di);
            plot(durationMinuteBins,durationHist,'Color',groupColors(gi,:)); hold on;
            
            %While we're iterating through all the files, may as well grab
            %the other sleep data we need:
            %         latency_CtrlVsExp = cell(maxDays,2);
            %         longestSleepBout_CtrlVsExp = cell(maxDays,2);
            %         meanSleepBout_CtrlVsExp = cell(maxDays,2);
            latencyVal = find(thisFlyBinary(12*60+1:end)==1,1);
            if(~isempty(latencyVal)),
                latency_dayGroup(xi) = latencyVal;
            end;
            %             display(size(allDurations));
            if(numel(allDurations)>0),
                longestSleep_dayGroup(xi) = max(allDurations);
                meanSleep_dayGroup(xi) = mean(allDurations);
            end;
            numSleep_dayGroup(xi) = numel(allDurations);
            sleepBoutDurationVsStartTime{xi,1} = sleepBoutStarts;
            sleepBoutDurationVsStartTime{xi,2} = allDurations;
            
            
            %--------------PLOT SLEEP BOUT VS TIME TO FALL ASLEEP-----------------------
            %
            figure(6);
            subplot(maxDays,1,di);
            plot(sleepBoutStarts,allDurations,'o','MarkerSize',3,'Color',groupColors(gi,:));
            xlim([0 1440]);
            %             catch,
            %             end;
        end;
        %
        %         figure(7);
        %         subplot(maxDays,1,di);
        %         imagesc(sleepBinaryPerGroup);
        
        latency_CtrlVsExp{di,gi} = latency_dayGroup;
        longestSleepBout_CtrlVsExp{di,gi} = longestSleep_dayGroup;
        meanSleepBout_CtrlVsExp{di,gi} = meanSleep_dayGroup;
        numSleepBout_CtrlVsExp{di,gi} = numSleep_dayGroup;
        
        %Plot mean and longest bout duration----------------------------
        figure(4);
        subplot(2,3,1);
        plot(ones(size(meanSleep_dayGroup))*di+0.2*(gi-1)-0.5,meanSleep_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3);
        hold on;
        %         text(0,9,'Normality (kstest)');
        %         [h,p] = kstest(totalActivity)
        %         text(di+0.2*(gi-1)-0.5,max(totalActivity)+1,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        ylim([0 100]); xlim([0 maxDays+1]);
        %
        subplot(2,3,2);
        plot(ones(size(longestSleep_dayGroup))*di+0.2*(gi-1)-0.5,longestSleep_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
        %         [h,p] = kstest(totalSleep);
        %         text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        ylim([0 800]); xlim([0 maxDays+1]);
        
        subplot(2,3,3);
        plot(ones(size(numSleepBout_CtrlVsExp{di,gi}))*di+0.2*(gi-1)-0.5,numSleepBout_CtrlVsExp{di,gi},'o',...
            'LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
        %         [h,p] = kstest(totalSleep);
        %         text(di+0.2*(gi-1)-0.5,max(totalSleep)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        ylim([0 70]); xlim([0 maxDays+1]);
        %
        %
        subplot(2,3,4);
        plotMedianQuartiles(meanSleep_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 100]); xlim([0 maxDays+1]);
        ylabel(['Mean Sleep Bout Duration (min)']);
        %
        subplot(2,3,5);
        plotMedianQuartiles(longestSleep_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 800]); xlim([0 maxDays+1]);
        ylabel(['Longest sleep bout (min)']);
        
        subplot(2,3,6);
        plotMedianQuartiles(numSleepBout_CtrlVsExp{di,gi},di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 70]); xlim([0 maxDays+1]);
        ylabel(['Number of sleep bouts']);
        %--------------PLOT LATENCY TO FALL ASLEEP-----------------------
        figure(5);
        subplot(2,2,1);
        plot(ones(size(latency_dayGroup))*di+0.2*(gi-1)-0.5,latency_dayGroup,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
        [h,p] = kstest(latency_dayGroup);
        text(di+0.2*(gi-1)-0.5,max(latency_dayGroup)+100,num2str(round(p*10000)/10000),'Color',groupColors(gi,:));
        ylim([0 400]); xlim([0 maxDays+1]);
        ylabel(['Latency to sleep (min after lights off)']);
        %
        %
        subplot(2,2,2);
        plotMedianQuartiles(latency_dayGroup,di+0.2*(gi-1),0.1,0.1,groupColors(gi,:));
        ylim([0 400]); xlim([0 maxDays+1]);
        
        
    end; %Close the "day" for loop.
end; %Close the "group" for loop.

% end;
figure(1);
subplot(maxDays,2,1); ylabel(['Activity/30 min bins']);
subplot(maxDays,2,2); ylabel(['Sleep (mins)']);

figure(2);
subplot(2,2,1); ylabel(['Activity/Waking min']);
% text(0,9,'Normality (kstest)');
title([output]);
% text(0,100,'Normality (kstest)');

subplot(2,2,2); ylabel(['Sleep/Day (mins)']);

subplot(2,2,3); xlabel(['Day']); %Activity/min vs day, IQRs
subplot(2,2,4); xlabel(['Day']); %Total sleep time vs day, IQRs

for(di = 1:maxDays), %Need to iterate through all the days and put stats on subplots 3 and 4.
    subplot(2,2,3); xlabel(['Day']); %Activity/min vs day, IQRs
    [h,p_act] = ttest2(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,exp_gi});
    %     text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,2}]),...
    %         num2str(round(ranksum(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_act*10000)/10000),'Color',groupColors(exp_gi,:));
    subplot(2,2,4); xlabel(['Day']); %Total sleep time vs day, IQRs
    %     text(di-0.2,1.1*max([totalSleep_CtrlVsExp{di,1}; totalSleep_CtrlVsExp{di,2}]),...
    %         num2str(round(ranksum(totalSleep_CtrlVsExp{di,1},totalSleep_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    [h,p_sleep] = ttest2(totalSleep_CtrlVsExp{di,1},totalSleep_CtrlVsExp{di,exp_gi});
    text(di-0.2,1.1*max([totalSleep_CtrlVsExp{di,1}; totalSleep_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_sleep*10000)/10000),'Color',groupColors(exp_gi,:));
end;

%         latency_CtrlVsExp{di,gi} = latency_dayGroup;
for(di = 1:maxDays), %Need to iterate through all the days and put stats on subplots 3 and 4.
    
    figure(5); %Latency:
    subplot(2,2,2); xlabel(['Day']); %Activity/min vs day, IQRs
    [h,p_lat] = ttest2(latency_CtrlVsExp{di,1},latency_CtrlVsExp{di,exp_gi});
    %     %     text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,2}]),...
    %     %         num2str(round(ranksum(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    text(di-0.2,1.1*max([latency_CtrlVsExp{di,1}; latency_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_lat*10000)/10000),'Color',groupColors(exp_gi,:));
    
    
    figure(4); %Latency:
    subplot(2,3,4); xlabel(['Day']); %Activity/min vs day, IQRs
    [h,p_mean] = ttest2(meanSleepBout_CtrlVsExp{di,1},meanSleepBout_CtrlVsExp{di,exp_gi});
    %     %     text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,2}]),...
    %     %         num2str(round(ranksum(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    text(di-0.2,1.1*max([meanSleepBout_CtrlVsExp{di,1}; meanSleepBout_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_mean*10000)/10000),'Color',groupColors(exp_gi,:));
    
    subplot(2,3,5); xlabel(['Day']); %Activity/min vs day, IQRs
    [h,p_long] = ttest2(longestSleepBout_CtrlVsExp{di,1},longestSleepBout_CtrlVsExp{di,exp_gi});
    %     %     text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,2}]),...
    %     %         num2str(round(ranksum(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    text(di-0.2,1.1*max([longestSleepBout_CtrlVsExp{di,1}; longestSleepBout_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_long*10000)/10000),'Color',groupColors(exp_gi,:));
    
    subplot(2,3,6); xlabel(['Day']); %Activity/min vs day, IQRs
    [h,p_long] = ttest2(numSleepBout_CtrlVsExp{di,1},numSleepBout_CtrlVsExp{di,exp_gi});
    %     %     text(di-0.2,1.1*max([actPerMin_CtrlVsExp{di,1}; actPerMin_CtrlVsExp{di,2}]),...
    %     %         num2str(round(ranksum(actPerMin_CtrlVsExp{di,1},actPerMin_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    text(di-0.2,1.1*max([numSleepBout_CtrlVsExp{di,1}; numSleepBout_CtrlVsExp{di,exp_gi}]),...
        num2str(round(p_long*10000)/10000),'Color',groupColors(exp_gi,:));
    %     subplot(2,2,4); xlabel(['Day']); %Total sleep time vs day, IQRs
    %     %     text(di-0.2,1.1*max([totalSleep_CtrlVsExp{di,1}; totalSleep_CtrlVsExp{di,2}]),...
    %     %         num2str(round(ranksum(totalSleep_CtrlVsExp{di,1},totalSleep_CtrlVsExp{di,3})*10000)/10000),'Color',groupColors(gi,:));
    %     [h,p_sleep] = ttest2(totalSleep_CtrlVsExp{di,1},totalSleep_CtrlVsExp{di,exp_gi});
    %     text(di-0.2,1.1*max([totalSleep_CtrlVsExp{di,1}; totalSleep_CtrlVsExp{di,exp_gi}]),...
    %         num2str(round(p_sleep*10000)/10000),'Color',groupColors(exp_gi,:));
end;
%         longestSleepBout_CtrlVsExp{di,gi} = longestSleep_dayGroup;
%         meanSleepBout_CtrlVsExp{di,gi} = meanSleep_dayGroup;
%


cd(primedir);
for(fignum = [1:6]),
    orient(figure(fignum),'landscape');
    print(figure(fignum),'-dpsc2',[output '.ps'],'-append');
    close(figure(fignum));
end;

ps2pdf('psfile', [output '.ps'], 'pdffile', [output '.pdf'], ...
    'gspapersize', 'letter',...
    'verbose', 1, ...
    'gscommand', 'C:\Program Files\gs\gs9.21\bin\gswin64.exe');