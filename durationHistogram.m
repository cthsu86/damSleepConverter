function [durationHist, sleepBoutLengths,varargout] = durationHistogram(isSleepBinary, durationMinuteBins);

%Want to deal with the end cases first:
% if(isSleepBinary(1)),
%     isSleepBinary

%First, want to compute the sleep lengths;
sleepStartIndices = find(diff(isSleepBinary)==1)+1;
if(isSleepBinary(1)),
    sleepStartIndices = [1 sleepStartIndices];
end;
sleepEndIndices = find(diff(isSleepBinary)==-1);
if(isSleepBinary(end)),
    sleepEndIndices = [sleepEndIndices numel(isSleepBinary)];
end;

% if(numel(sleepStartIndices)>0 && numel(sleepEndIndices)>0),

%Discard sleep bouts that are incomplete.
numSleepBouts = numel(sleepStartIndices);
% if(isSleepBinary(1)),
%     numSleepBouts = numSleepBouts+1;
% end;
varargout{2} = numSleepBouts;
% try,
if(numel(sleepStartIndices)>0 && numel(sleepEndIndices)>0),
%     if(sleepStartIndices(1)>sleepEndIndices(1) && numel(sleepEndIndices)>1),
%         firstSleepBoutLength = sleepEndIndices(1);
%         sleepEndIndices = sleepEndIndices(2:end);
%     else,
%         firstSleepBoutLength = [];
%     end;
%     % try
%     if(sleepEndIndices(end)<sleepStartIndices(end) && numel(sleepStartIndices)>1),
%         
%         lastSleepBoutLength = numel(isSleepBinary)-sleepStartIndices(end)+1;
%         sleepStartIndices = sleepStartIndices(1:(end-1));
%     else,
%         lastSleepBoutLength = [];
%     end;
    sleepBoutLengths = sleepEndIndices-sleepStartIndices+1;
    sleepBoutLengthsWithEnds = sleepBoutLengths;
%     sleepBoutLengthsWithEnds = [firstSleepBoutLength sleepBoutLengths lastSleepBoutLength];
    varargout{3} = sleepBoutLengths; %WithEnds; %[firstSleepBoutLength sleepBoutLengths lastSleepBoutLength];
    if(mean(sleepBoutLengthsWithEnds)<=0),
        display('sadness and despair.');
    end;
    [n,xout] = hist(sleepBoutLengths, durationMinuteBins);
    durationHist = cumsum(n)/sum(n);
    varargout{1} = sleepStartIndices;
else,
    sleepBoutLengths = [];
    durationHist = zeros(size(durationMinuteBins));
    varargout{1} = [];
    varargout{2}=[];
    varargout{3}=[];
end;
% catch,
%     display('what?');
% end;

% display(sleepEndIndices);
% display(sleepStartIndices);

% catch,
%     durationHist = zeros(size(durationMinuteBins));
%     sleepBoutLengths = [];
% end;