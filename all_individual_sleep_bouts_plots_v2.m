rootdir = 'C:\Users\Windows 10\Dropbox\Sehgal Lab\Sensory DAM\TrpA1\GH146_TrpA1_ZT0_12hr31 summary';
boutLength_xl = 'GH146_TrpA1_ZT0to12_31C__ZT0to12_durationHist.xlsx';
groupNames = {'UAS-dTrpA1(II)/iso31';
    'GH146/UAS-dTrpA1(II)';
    'GH146/iso31'};

cd(rootdir);
[num,~,~] = xlsread(boutLength_xl,'Durations incl end cases (min)');

dayID_allGroups = num(:,1);
numDays = max(dayID_allGroups);

groupEnds = find(diff(dayID_allGroups)<0);
groupEnds = [groupEnds(:); numel(dayID_allGroups)];
display(groupEnds);
% display('pause.');

for(di = 1:numDays),
    
end;
