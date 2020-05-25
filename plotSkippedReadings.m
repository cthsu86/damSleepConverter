close all;
clear all;


rootdir = 'C:\Users\JH\Dropbox\Sehgal Lab\DAM analysis code\Debug\G6PD_Sleep_20190824';
filename = 'Monitor2.xlsx';
startrow = 1943; %When we actually have lights on for the day we are analyzing.

[num, text,raw] = xlsread(filename);

secondsArray = NaN(size(raw,1),1);

for(ri = startrow:size(raw,1))
    secondsArray(ri) = raw{ri,3};
end;

secondsArray = secondsArray(startrow:end); %Removes NaNs
diffSecondsArray = diff(secondsArray)*24*3600;
figure; imagesc(diffSecondsArray',[50 80]);
colormap jet;
colorbar southoutside;

[n,xout] = hist(diffSecondsArray,[50:1:80]);
figure;
bar(xout,n);