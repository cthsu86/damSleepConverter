function tubeDwellToExcel()
%Can be run on the outputs of the following scripts:
%-
%-
%- PositionAnalysis

rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\DAM analysis code\Debug\Aging multibeam\2019_05_06';
mat2load = '2019_05_06_channelList_tubeCount9to9.mat';
% bins2write_hrs = 12;

cd(rootdir);
output = strrep(mat2load,'.mat','.xlsx');
if(exist([output],'file'));
    delete([output]);
end;
%Also want to take note of what kind of data this is:
underscoreIndex = strfind(mat2load,'_');
periodIndex = strfind(mat2load,'.');
datatypeSuffix = output((underscoreIndex(end)+1):(periodIndex-1));

A = load(mat2load);

allDatByGroup = A.allDatByGroup;

prevRow = 1;
for(gi = 1:size(A.allDatByGroup,1)),
    thisGroupName = allDatByGroup{gi,1}
    thisGroupData = allDatByGroup{gi,2};
%     thisGroupActivity = thisGroupData{
    for(di = 1:size(thisGroupData,1)),
        thisDayActivity = thisGroupData{di,1};
        if(size(thisDayActivity,1)>0)
            isNumIndices = find(~isnan(thisDayActivity(:,1)));
            thisDayActivity = thisDayActivity(isNumIndices,:);
            labels2write = cell(size(thisDayActivity,1),1);
            labels2write(1:end,1) = {thisGroupName};
            sheetName = ['Day ' num2str(di) ' 30min bin ' datatypeSuffix];
%             display(size(sheetName));
            xlswrite(output,labels2write,sheetName,['A' num2str(prevRow+1)]);
            xlswrite(output,thisDayActivity,sheetName,['B' num2str(prevRow+1)]);
        end;
        thisDaySleep = thisGroupData{di,2};
        if(size(thisDaySleep,1)>0),
            xlswrite(output,labels2write,['Day ' num2str(di) ' 30 min binned sleep'],['A' num2str(prevRow+1)]);
            xlswrite(output,thisDaySleep,['Day ' num2str(di) ' 30 min binned sleep'],['B' num2str(prevRow+1)]);
        end;
    end;
    prevRow = prevRow+size(thisDayActivity,1);
end;