function basicDAManalysis()
close all; clear all;
rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\LHON\LH1554_191231';
% xl2read = 'orco_TrpA1_6hr_ZT21_ZT9_190510_channelList.xlsx';
% rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\KIR\WhiteCS_orco_180320';
plotAreaQuartiles = 1;
profileBinSize = 30; %usually 30;
% rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\Dop1R mutants with cohort\Dop1R2_180525';
rawdir = [rootdir '\Raw Data'];
% rawdir = [rootdir '\Channel Counts'];
maxDays =5;
backslashIndices = strfind(rootdir,'\');
if(backslashIndices(end)==numel(rootdir)),
    lastDirIndex = backslashIndices(end-1)+1;
else,
    lastDirIndex =backslashIndices(end)+1;
end;
expName = rootdir(lastDirIndex:end);
flyIDname = [expName '_channelList'];
% %
% groupNames = {'tubGal80ts/iso31; UAS-kir-2.1/iso31';
%     'orco/iso31; tubGal80ts/iso31; UAS-kir-2.1/iso31';
%     'orco/iso31';
%     'R30A10/orco';
% %     'orco/iso31; iso31; R30A10/iso31';
%     'orco/iso31; tubGal80ts/iso31; R30A10/UAS-kir-2.1';
%     'R30A10/iso31';
% %     'tubGal80ts/iso31; R30A10/UAS-kir-2.1'};
% groupNames = {'tub/+;kir/+';
%     'orco;tub;kir';
%     'orco/iso31';
%     '16A06/orco';
% %     'orco/iso31; iso31; R30A10/iso31';
%     'orco/+;tub/+;R16A06/kir';
%     '16A06/iso31';
%     'tub/+;R16A06/kir'};
% groupColors = [0 0 0; %Black: UAS ctrl, 'tubGal80ts/iso31; UAS-kir-2.1/iso31';
%     0.75 0.5 0;% Red: 'orco/iso31; tubGal80ts/iso31; UAS-kir-2.1/iso31';
% 0 0 1; % Blue: 'orco/iso31';
% 0 1 1; % Cyan: 'orco/iso31; iso31; 23E10/iso31';
% 1 0 0;%     'Red: orco/iso31; tubGal80ts/iso31; 23E10/UAS-kir-2.1';
% 0.5 0.5 0.5; %     '23E10/iso31';
% 0 1 0]; %     'Green: tubGal80ts/iso31; 23E10/UAS-kir-2.1'};
%
% groupNames = {'Intact Red Canton S'; 'Glued Red Canton S'};
% groupColors = [0 0 0; 1 0 0];
% groupNames = {'20XUAS-shib/iso31 Intact'; '20XUAS-shib/iso31 Glued'; ...
%     'R15B01/iso31 Intact'; 'R15B01/iso31 Glued'; ...
% %     'R15B01/20XUAS-shib Intact'; 'R15B01/20XUAS-shib Glued'};
% groupNames = {'UAS-kir-2.1/iso31 ctr'; 'UAS-kir-2.1/iso31 AG'; ... ...
%     '58H05/kir ctr'; '58H05/kir AG';...
%         'R58H05/iso31 ctr'; 'R58H05/iso31 AG';};
% groupNames = {'UAS-TNT/iso31 intact'; 'UAS-TNT/iso31 glued'; ... ...
%     'R94B10/iso31 intact'; 'R94B10/iso31 glued';...
%         'R94B10/UAS-TNT intact'; 'R94B10/UAS-TNT glued';};
% groupNames = {'iso31/tubGal80ts;UAS-kir-2.1 ctr'; 'iso31/tubGal80ts;UAS-kir-2.1 AG'; ...
%     'R16A06/iso31 ctr'; 'R16A06/iso31 AG'; ...
%     'tub/+;R16A06/kir ctr'; 'tub/+;R16A06/kir AG'}; %iso31; UA
% groupNames = {'KK105324/iso31 Ctrl'; 'KK105324/iso31 AxMx';  ...
%     'nsybGS/KK105324 Ctrl'; 'nsybGS/KK105324 AxMx'; ...
%     'nsybGS/iso31 Ctrl'; 'nsybGS/iso31 AxMx'};
% groupNames = { ...
%     'UAS-kir2.1/iso31 Ctrl'; 'UAS-kir2.1/iso31 AxMx';  ...
%     'MB077B>UAS-kir2.1 Ctrl'; 'MB077B>UAS-kir2.1 AxMx'; ...
%     'MB077B/iso31 Ctrl'; 'MB077B/iso31 AxMx'};
% groupNames = {'UAS-G6PD9g/+ Male'; 'UAS-G6PD9g;TH-GAL4 Male'; 'TH-GAL4/+ Male'; ...
%     'UAS-G6PD9g/+ Female'; 'UAS-G6PD9g;TH-GAL4 Female'; 'TH-GAL4/+ Female'};%...
%     'UAS-G6PD9g;Tub-GAL4 Male';'UAS-G6PD9g;Tub-GAL4 Female';'Tub-GAL4/+ Male';'Tub-GAL4/+ Female';...
%     'PDF-GAL4/UAS-G6PD9g Male';'PDF-GAL4/UAS-G6PD9g Female';'PDF-GAL4/+ Male';'PDF-GAL4/+ Female'};

% groupColors = rand(size(groupNames,1),3);
% groupColors = [0 0 0; 0.5 0.5 0;
%   0 1 0; 1 0 0
%     0 0 1; 1 0 1];

% groupNames = {'2% agar, 5% sucrose'; '10^-2 Benzylaldehyde, 5% sucrose'; ...
%     '10^-2 Acetic Acid, 5% sucrose'; '10^-4 Acetic Acid, 5% sucrose'};
% groupColors = [0 0 0; 1 0 0; ...
%     0 1 1; 0 0 1];

% groupNames = {'KK105324/iso31 (+RU) Ctrl'; 'KK105324/iso31 (+RU) AxMx';  ...
%     'nsybGS/KK105324 Ctrl'; 'nsybGS/KK105324 AxMx'; ...
%     'nsybGS/iso31 Ctrl'; 'nsybGS/iso31 AxMx'; ...
%     'KK105324/iso31 (mol=>sucrose) Ctrl'; 'KK105324/iso31 (mol=>sucrose) AxMx';  ...
%     'nsybG4/KK05324 Ctrl'; 'nsybG4/KK05324 AxMx'; ...
%     'nsybG4/iso31 Ctrl'; 'nsybG4/iso31 AxMx'};
% groupNames = {'orco/iso31 No stimulus
% 
% groupColors = [0 0 0; 0.5 0.5 0;
%   0 1 0; 1 0 0;
%     0 0 1; 1 0 1;
%     0 0 0; 0.5 0.5 0;
%   0 1 0; 1 0 0;
%     0 0 1; 1 0 1];
% groupNames = {'UAS-shib'; 'orcoGal4>UAS-shib'; 'orcoGal4'}; %, iso31';'Air, iso31';'Acetic Acid, iso31'}; %; 'Day 0'};
% groupNames = {'Shib male'; 'GMR>shib male'; 'GMR-Gal4 male'}; %, iso31';'Air, iso31';'Acetic Acid, iso31'}; %; 'Day 0'};
% groupNames = {'UAS-NaChBac/iso31'; 'GH146/NaChBac'; 'GH146/iso31'};
% groupNames = {'GtACR1(II)/iso31'; 'R84C10/GtACR1(II)'; 'R84C10/iso31'};
% groupNames = {'Intact 20XUASshib/iso31'; 'JO15/20XUAS-shib'; 'JO15/iso31'};
% groupNames = {'GtACR1(II)/iso31'; 'orco-Gal4/GtACR1(II)'; 'orco-Gal4/iso31'};
% % groupNames = {'GtACR1(II)/iso31'; 'R18H11/GtACR1(II)'; 'R18H11/iso31'};
% groupNames = {'20XUAS-shib/iso31'; 'JO15/20XUAS-shib'; 'JO15/iso31'};
% groupNames = {'tubGal80ts/iso31; UAS-kir-2.1/iso31'; 'orco/iso31; tubGal80ts/iso31; UAS-kir-2.1/iso31'; 'orco/iso31'};
% groupNames = {'tubGal80ts/iso31; UAS-kir-2.1/iso31'; 'tubGal80ts/iso31; Gr21a-Gal4/UAS-kir-2.1'; 'Gr21a-Gal4/iso31'};
% groupNames = {'UAS-dTrpA1/iso31'; 'MZ699/TrpA1'; 'MZ699/iso31'};
% groupNames = {'tubGal80ts/iso31; UAS-kir-2.1/iso31'; 'tubGal80ts/iso31; JO15/UAS-kir-2.1'; 'JO15/iso31'};
% groupNames = {'tubGal80ts/WhiteCS; UAS-kir-2.1/WhiteCS'; 'orco/tubGal80ts; UAS-kir-2.1/WhiteCS'; 'orco/WhiteCS'};

% groupNames = {'UAS-Dicer/+; +; nsyb-GeneSwitch/+'; 'HMS05293/iso31';'UAS-Dicer/+; +; nsyb-GeneSwitch/HMS05293'};
% groupNames = {'UAS-dTrpA1(II)/iso31'; 'orco>UAS-dTrpA1(II)'; 'orco-Gal4/iso31'};
% groupNames = {'QUAS-shibts(2)'; 'GH146(3)>QUAS-shib(2)';'GH146-QF(3)'};
% groupNames = {'UAS-dTrpA1/iso31'; 'MZ699>TrpA1'; 'MZ699/iso31'};
% groupNames ={'orco-Gal4>UAS-kir-2.1 No stimulus'; 'LH180/iso31 benzaldehyde';'LH180/iso31 Paraffin Oil'};

% groupNames ={'orco-Gal4>UAS-kir-2.1 No stimulus'; 'tub; LH180>kir benzaldehyde';'tub; LH180>kir Paraffin Oil'};
% groupNames = {'GD32344/iso31'; 'Mz699>GD32344'; 'Mz699/iso31'};PDF-GAL4/+ Male
% groupNames = {'tub/+;kir/+'; 'tubGal80ts; LH421>kir'; 'LH421/iso31'};
groupNames = {'tub/+;kir/+'; 'tubGal80ts;LH1554>kir'; 'LH1554/iso31'};
% groupNames = {'WCSG 11/23-25 Female'; 'WCSG 11/1-5 Female'; 'WCSG 10/26-31 Female'};
% groupNames = {'20XUAS-Shibts/iso31 SD'; '20XUAS-Shibts>23E10-Gal4 SD';'23E10/iso31 SD'};
% groupNames = {'Paraffin oil'; 'Methyl amine'};


% groupNames = {'tubGal80ts/iso31; UAS-kir-2.1/iso31'; 'tubGal80ts/iso31; NP6303/UAS-kir-2.1'; 'NP6303/iso31'}; %Ctrl Day 4'; 'Antennae Removed'}; %'Day 0'};
% groupNames = {'20XUAS-shibts/iso31';'23E10>20XUAS-shib';'23E10/iso31'};
% groupColors = [0 0 0; 1 0 0; 0 0 1; 1 0 1]; %; 0 1 0; 0 0 1]; %; 0 1 0]; %; 0 0 1]; %; 0 0 0; 1 0 1];
% groupNames = {'UAS-dTrpA1/iso31; GD32344/iso31'; 'UAS-dTrpA1/iso31; Mz699/GD32344'; 'Mz699/iso31'}; %'Methyl amine'; 'Paraffidn Oil'};
groupColors = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
%
% groupNames = {'Redeye intact'; 'Redeye glued'};
% groupNames = {'Ddclo intact'; 'Ddclo glued'};
% groupNames = {'No stimulus'; 'ACV'; 'Air'};
% groupNames = {'Young'; 'Old'};
% groupColors = [0 0 0; 1 0 0];
% groupNames = {'tub/+;kir/+'; 'tub;LH2446>UAS-kir-2.1';'LH2446/iso31'};
% groupNames = {'tub/+;kir/+'; 'tub/+;NP6250/kir';'NP6250/iso31'};
% groupNames = {'UAS-dTrpA/iso31'; 'LH180>UAS-dTrpA1'; 'LH180/iso31'}
% groupNames = {'tub/+;kir/+'; 'tub;LH180>UAS-kir-2.1'; 'LH180/iso31'}
% groupColors = [0 0 0; 1 0 0; 0 0 1];% 0 0 1];
% groupNames = {'iso31 centre'; 'iso31 AG'; 'pdf01/iso31 centre'; 'pdf01/iso31 AG';...
%     'pdf01/pdf01 centre'; 'pdf01/pdf01 AG'} %5HT1A/iso31 intact'; '5HT1A/iso31 glued'};
% groupNames = {'UAS-dTrpA1/iso31 SD'; 'Mz699>UAS-dTrpA1 SD'; 'Mz699/iso31 SD'}; %...
%     'UAS-dTrpA1/iso31 SD'; 'GH146/UAS-dTrpA1 SD'; 'GH146/iso31 SD'; };
% groupNames = {'TH-Gal4>UAS-G6PD9g';
%     'TH-Gal4/WCS G';
%     'D42-Gal4>UAS-G6PD9g';
%     'D42-Gal4/WCS G';
%     'G6PD9g'};
% groupColors = [0 0 0; 0 0 1; 0 1 1; 1 0 1; 0 1 0; 1 0 0];
% %
% groupNames = {'Centre crowded'; 'AG crowded';...
%     'Centre isolated'; 'AG isolated'};
% groupNames = {'5% sucrose'; '1.25% sucrose'; 'ETA-2'; 'ETA-3';  'ETA-4'};
% groupNames = {'Sucrose only';'10^-2 Acetic Acid';'10^-4 Acetic Acid'}; %, 5% sucrose'};
% groupColors = [0 0 0; 0 0 1; 0 1 1; 1 0 1; 1 0 0];
% % groupNames = {'Sucrose only'; 'ETA-2'; 'ETA-3'};
% groupNames = {'CsChrimson/iso31 200 uM';  ...
%     'orco/CsChrimson 200 uM'; %'23E10/CsChrimson AG'; ...
%     'orco-Gal4/iso31 200 uM'}; %'23E10/iso31 AG';};
% groupNames = {...'UAS-dTrpA1/iso31'; 'UAS-dTrpA1/GH146'; 'GH146/iso31'};
%     groupNames = {... %'UAS-dTrpA1/iso31 No SD'; 'GH146/UAS-dTrpA1 No SD'; 'GH146/iso31 No SD'; ...
    %     'UAS-dTrpA1/iso31 SD'; 'GH146/UAS-dTrpA1 SD'; 'GH146/iso31 SD'; };
    % 'No stimulus';'Octanoic acid';'Paraffin Oil'};
%     'dummy var';'tub/orco;kir/+ methyl amine';'tub/orco;kir/+ Paraffin oil'};
%     'iso31'};
% groupColors = [0 0 0; 1 0 0; 0 0 1]; %; 1 0 0];r
% groupNames = {'LK-Gal4(II)/iso31 ctr'; 'LK-Gal4(II)/iso31 AG'};
% groupNames = {'23E10>CaLexaGFP,RFP ctr'; '23E10>CaLexaGFP,RFP AG'};
% % groupNames = {'tubGal80ts/UAS-kir-2.1 centre'; 'tubGal80ts/UAS-kir-2.1 AG'};
% groupNames = {'23E10 Ctrl'; '23E10 AxMx'};
% groupNames = {'Ctrl'; 'AxMx'};
% groupNames = {'iso31 center'; 'iso31 glued'};
% groupNames = {'Paraffin oil';'Benzaldehyde 10^-3'};
% groupColors = [0 0 0; 1 0 0];
% groupNames = {'Dop1R2 ctrl/ TM6, Sb'; 'Dop1R2 Mutant/TM6'; 'iso31'; 'iso31>Dop1R2 Mutant/TM6,Sb'};
% groupColors = [0 0 1; 1 0 0; 0 0 0; 1 0 1];

% groupNames = {'iso31 Wing'; 'iso31 AxMx'; 'Dop1R2 Mutant/iso31 Wing'; 'Dop1R2 Mutant/iso31 AxMx'};
% groupColors = [0 0 1; 1 0 0; 0 0 0; 1 0 1];

cd(rootdir);

% flyIDname = '161229_channelList trueGenotype';
% try,
[n,t,r] = xlsread([flyIDname '.xlsx']);
% catch,
% end;

output = [flyIDname];
if(exist([output '.ps'],'file')),
    delete([output '.ps']);
end;

groupNameByChannel = r(:,2);
% if(~exist(['F_' output '.mat'],'file')),
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
                trueMaxDays = min(maxDays,size(thisChannelDatByDay,1))
                for(di = 1:trueMaxDays),
                    activityCountsForDay = thisChannelDatByDay{di,2};
                    display(di);
                    try,
                        activityCounts30min_bin = sum(reshape(activityCountsForDay,profileBinSize,24*(60/profileBinSize)),1);
                    catch,
                        display(numel(activityCountsForDay));
                    end;
                    subplot(maxDays,2,(di-1)*2+1);
                    timepts = ([1:numel(activityCounts30min_bin)]-1)/(60/profileBinSize);
                    try,
                        plot(timepts,activityCounts30min_bin,'Color',groupColors(gi,:));
                    catch,
                        display('mr?');
                    end;
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
                    
                    stopLengths = stoppedEnds-stoppedStarts+1;
                    trueSleepStopBoutIndices = find(stopLengths>=5);
                    if(gi==2 && ci==17 && di==2),
                        display('pause and debug.');
                    end;
                    isSleep = zeros(size(activityCountsForDay));
                    for(si = 1:numel(trueSleepStopBoutIndices))
                        isSleep(stoppedStarts(trueSleepStopBoutIndices(si)):stoppedEnds(trueSleepStopBoutIndices(si))) = 1;
                    end;
                    minsAwake = 1440-sum(isSleep);
                    display(numel(isSleep));
                    try,
                        sleep30min_bin = sum(reshape(isSleep,profileBinSize,24*(60/profileBinSize)),1);
                    catch,
                        pause;
                    end;
                    subplot(maxDays,2,di*2);
                    plot(timepts,sleep30min_bin,'Color',groupColors(gi,:));
                    xlim([0 24]); ylim([0 profileBinSize]);
                    
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
            if(numel(stdArea)>2 && plotAreaQuartiles),
                display(numel(stdArea));
                hArea = area(timepts,stdArea');
                set(hArea(1),'Visible','off');
                set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
                alpha(0.2);
            end;
            plot(timepts,meanAct,'Color',groupColors(gi,:)); hold on;
            ylim([0 150]); xlim([0 24]);
            
            stdArea = [quantile(sleepDat,0.25); quantile(sleepDat,0.75)-quantile(sleepDat,0.25)];
            subplot(maxDays,2,2*di);
            if(numel(stdArea)>2 && plotAreaQuartiles),
                hArea = area(timepts,stdArea');
                set(hArea(1),'Visible','off');
                set(hArea(2),'FaceColor',groupColors(gi,:),'EdgeColor','none'); hold on;
                alpha(0.2);
            end;
            plot(timepts,meanSleep,'Color',groupColors(gi,:)); hold on;
            ylim([0 profileBinSize]); xlim([0 24]);
            
            figure(3);
            subplot(2,2,1);
            totalActivity = totalsForGroup{di,1}; %./totalsForGroup{di,3};
            plot(ones(size(totalActivity))*di+0.15*(gi-1),totalActivity,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
            %             ylim([0 100]);
            %                         ylim([0 10]);
            if(mean(totalActivity)<3),
            ylim([0 25]);
            else,
                ylim([0 6]);
            end;
            xlim([0 maxDays+1]);
            
            subplot(2,2,2);
            totalSleep = totalsForGroup{di,2};
            plot(ones(size(totalSleep))*di+0.15*(gi-1),totalSleep,'o','LineStyle','none','Color',groupColors(gi,:),'MarkerSize',3); hold on;
            ylim([0 1440]); xlim([0 maxDays+1]);
            
            subplot(2,2,3);
            plotMedianQuartiles(totalActivity,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
            %             ylim([0 10]);
            ylim([0 10]);
            xlim([0 maxDays+1]);
            
            % ylim([0 100]);
            
            subplot(2,2,4);
            plotMedianQuartiles(totalSleep,di+0.15*(gi-1),0.1,0.1,groupColors(gi,:));
            ylim([0 1440]); xlim([0 maxDays+1]);
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
            allSamplePts_sortedVec = allSamplePts_vec; %(sortedIndices);
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