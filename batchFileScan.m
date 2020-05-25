function batchFileScan()
% Written upon Fola's request:
% CTH Feb 15, 2019
% Assumes that the user has already run DAMFileScan to generate a list of
% all the bins for the entire experiment.

%% PARAMETERS FOR THE USER TO CHANGE:
rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\DAM analysis code\Debug\23E10_KK105324_190204 Raw Data';
% allChannelDatByDay = processChannels(rawdir,groupNameByChannel,r(:,1),r(:,3));


%%
%     function allChannelDatByDay = processChannels(rawFolder)
cd(rawFolder); %Given the raw data folder
for(mi=1:numel(monitorList)),
    mnum = monitorList(mi);
    for(ci = 1:32),
        channelNameFormat = sprintf('*M%03dC%02d.txt',mnum,ci);
        %         %Use this
        % channelNameFormat = sprintf('*C%02d.txt',ci);
        %     end;
        allFiles = dir(channelNameFormat);
        %Contains all the files relevant to the monitor and channel name in question. Should theoretically be equal to the number of days.
        channelDatByDay = cell(size(allFiles,1),2);
        datenumList = NaN(size(channelDatByDay,1),1);
        %DamFiles were saved in a multi-day format.
        if(size(allFiles,1)==1),
            filename = allFiles(1).name;
            if(exist(filename,'file'));
                display(['Loading ' filename]);
                fID = fopen(filename);
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
                        [sortedTimes, sortedIndices] = sort(timeptsZT_datenum(ti-1440+1:ti));
                        allSamplePts_vecThisDay = allSamplePts_vec(ti-1440+1:ti);
                        timeptsZT_sortedDatenum = sortedTimes;
                        allSamplePts_sortedVec = allSamplePts_vecThisDay(sortedIndices);
                        channelDatByDay{fi,1} = timeptsZT_sortedDatenum;
                        channelDatByDay{fi,2} = allSamplePts_sortedVec;
                        datenumList(fi) = timeptsZT_sortedDatenum(1);
                        fi = fi+1;
                        %                 timeptsZT_datenum = timeptsZT_datenum+1;
                    end;
                end;
                fclose(fID);
            end;
        end;
    end;
    allChannelDatByDay{csubi} = channelDatByDay; %number of rows in this cell array match up with the number of channels.
end;