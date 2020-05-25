function sleep2write = writeDayMeanSEM2sheet(output,maxDays,sheetName,groupLabel,groupColCharNum,fliesInGroup,totalSleep,gi,di,sleep2write);
if(gi==1),
    xlswrite(output,[1:maxDays]',sheetName,['A3']);
end;
if(di==1),
    %Writing the labels in the second row.
    xlswrite(output,groupLabel,sheetName,[char(groupColCharNum) '1']);
    
    %If this is the first day, we need to enerate the matrices to
    %write. Otherwise, we need to accumulate the matrices to
    %write.
    sleep2write = [nanmean(totalSleep) std(totalSleep) fliesInGroup];
    
else,
    sleep2write = [sleep2write; nanmean(totalSleep) std(totalSleep) fliesInGroup];
    if(di==maxDays),
        xlswrite(output,sleep2write,sheetName,[char(groupColCharNum) '3']);
    end;
end;