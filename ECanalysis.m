function ECanalysis (src,evt,day,list,analysis,BinLength,analyzeforBin,ecchoiceA,setnum,group,selectBinLength)


CalcXObject = get(analyzeforBin,'Userdata');
if strcmp(BinLength,'Default (12/24hr)') || strcmp (BinLength,'12/24');
    error('This Analysis only works for single bin length values, not double 12/24 bins.')
end
ECoutput = {}; %this will be like mplnoutput-the same as CalcXObject, except restricted to selected groups and analysis types


%The following gets data from the GUI and uses it to defines vectors/cell arrays
%for selected days, selected groups, selected analysis types, E vs C selections and Set# selections

selectedDays=[]; %Create vector of selected days
dayChoice = get(day,'Value');
for i=1:length(day)
    if length(day) == 1     %if there is only 1 day in experiment
        selectedDays = 1;
    else
        if dayChoice{i} == 1
            
            selectedDays = [selectedDays i];
        end
    end
end


if isempty(selectedDays)
    error('You did not select any days to analyze!')
end
analysis=get(analysis,'Value');

selectedAnalysis=[];  %Create vector of selected analysis types

for i=1:length(analysis)
    if analysis{i} == 1
        selectedAnalysis = [selectedAnalysis i];
    end
end

if isempty(selectedAnalysis)
    error('You did not select any analyses to graph!')
end

SetsArray={};   %Convert number series (ie. 1,2,3) entered in Sets text boxes into
%a cell array containing Sets vectors for each genotype
%Sets will be used to determine which genotypes
%to compare to each other
BinLength = get(selectBinLength,'string');
BinLengthNum = str2num(BinLength);
Sets= get(setnum,'string');
if isnumeric(Sets); Sets = num2cell(Sets);
end

for i=1:length(list)
    x= str2num(Sets{i});
    SetsArray(i)={x};
    
end
%SetsArray(3)
%SetsArray{1,3}


selectedGroups= []; %This is a vector indicating which geneotypes have been selected ie. [2 5 8]
ECselectedGroups= []; %This vector indicates whether each genotype in selectedGroups is a control (1) or experimental (0)
% ie. [1 1 1] if all controls are selected

% Get user selections from radio buttons where if selected E=0 and C=1
selected = get(group,'Value'); %check boxes
if isempty(selected)
    error('You did not select any groups!')
end

ECselected=get(ecchoiceA,'Value');      %radio buttons

selectedGroups = []; %all groups with checked boxes
ECselectedGroups=[];   %radio button values for selectedGroups only

for i=1:length(selected)
    if length(group)==1 %if there is only one genotype (selected or not)
        if selected(i) == 1
            selectedGroups = [selectedGroups i];
            ECselectedGroups = [ECselected i];
        end
    elseif length(selected) > 1
        if selected{i} == 1  %if checkbox is checked
            selectedGroups = [selectedGroups i];
            ECselectedGroups = [ECselectedGroups ECselected{i}];
        end
    end
end

selectedExpGroups=[];           %Make vectors of selected control and experimental groups
selectedControlGroups=[];      %ie. if genotypes 1 and 3 are selected then vector is [1 3]

for i=1:length(ECselectedGroups)
    if ECselectedGroups(i) == 0
        selectedExpGroups=[selectedExpGroups selectedGroups(i)];
    elseif ECselectedGroups(i) == 1
        selectedControlGroups= [selectedControlGroups selectedGroups(i)];
    end
end

groupnames={};%contains actual genotype names
for i=1:length(selectedGroups)
    groupnames=[groupnames list(selectedGroups(i))];
end

% Now use all input GUI selections to restrict CalcXObject data to genotype and analysis type selections only, which becomes ECoutput

plotdatadaily=[]; %Create a matrix of NaN of the correct dimensions for plotting sleep analysis types 3-17
plotdatadaily30=[];  %Create a matrix of NaN of the correct dimensions for plotting sleep analysis types 1-2 (s30, amean)
plotSEMdaily=[]; %Create the same matrices for SEM data
plotSEMdaily30=[];
for j=1:length(selectedAnalysis)%length(mplnoutput{i}) %running through each sleep data/analysis type
    
    if selectedAnalysis(j)<3    %for s30 and amean
        binlength=.5;
        BinsPerDay=48;
        numBins= BinsPerDay*length(selectedDays);
        plotdatadaily30= NaN(numBins,length(selectedGroups));
        plotSEMdaily30= NaN(numBins,length(selectedGroups));
    else                                %for all other analysis types
        binlength=BinLengthNum;
        BinsPerDay = (24/binlength);
        numBins= BinsPerDay*length(selectedDays);
        plotdatadaily = NaN(numBins,length(selectedGroups)); % (numbins, numgroups)
        plotSEMdaily = NaN(numBins,length(selectedGroups)); % (numbins, numgroups)
    end
    
end
%         numBins
%Restrict ECoutput to only selected analysis types (Here ECoutput is like mplnoutput)



plotdataarraydaily=cell(length(selectedGroups),1);
plotSEMarraydaily=cell(length(plotSEMarraydaily),1);

NumFlies=NaN(1,length(selectedGroups)); %Create a vector that will contain the number of flies for each selected group
%                 ECoutput = cell(length(selectedGroups),length(selectedAnalysis));
for i = 1:length(selectedGroups)
    
    NumFlies(1,i)=length(CalcXObject{i}{1}(1,:)); %Fill in NumFlies vector for each group
    
    for j=1:length(selectedAnalysis) %length(selectedanalyses)
        
        if selectedAnalysis(j)<3    %for s30 and amean
            binlength=.5;
            BinsPerDay=48;
            numBins= BinsPerDay*length(selectedDays);
            %                                      plotdatadaily30= NaN(numBins,length(selectedGroups));
            %                                      plotSEMdaily30= NaN(numBins,length(selectedGroups));
        else                                %for all other analysis types
            binlength=BinLengthNum;
            BinsPerDay = (24/binlength);
            numBins= BinsPerDay*length(selectedDays);
            %                                      plotdatadaily = NaN(numBins,length(selectedGroups)); % (numbins, numgroups)
            %                                      plotSEMdaily = NaN(numBins,length(selectedGroups)); % (numbins, numgroups)
        end
        
        
        if length(CalcXObject)==2
            error('This Analysis only works for single bin length values, not 12/24 bins')
        else
            
            ECoutput{i}{j} = CalcXObject{selectedGroups(i)}{selectedAnalysis(j)}; %CalcXObject{genotype}{selectedAnalysis(j)}
            
            for k=1:numBins      %Need to run through bins to take the mean across flies within a given analysis type, group and bin                
                GroupAvgECoutput{i}{j}(k,1)= nanmean(ECoutput{i}{j}(k,:));  %Take the mean across flies within a given analysis type, group and bin
                %(average each bin separately)
                GroupAvgSEMECoutput{i}{j}(k,1)= (nanstd(ECoutput{i}{j}(k,:)))/sqrt(NumFlies(1,i));  %take the SEM across flies within a given analysis type, group and bin
                %Since there is no SEM function, need to use standard dev/ sqrt(NumFlies)
                %                                         plotdatadaily(k,i)= GroupAvgECoutput{i}{j}(k);          %Need to reorganize data for plotting: plotdatadaily{j}= [num bins numgenotypes]
                %                                         plotSEMdaily(k,i)= GroupAvgSEMECoutput{i}{j}(k);
                %                                         size(plotdatadaily);
                if selectedAnalysis(j)>2
                    plotdatadaily(k,i)= GroupAvgECoutput{i}{j}(k);          %Need to reorganize data for plotting: plotdatadaily{j}= [num bins numgenotypes]
                    plotSEMdaily(k,i)= GroupAvgSEMECoutput{i}{j}(k);
%                     size(plotdatadaily);
                else
                    plotdatadaily30(k,i)= GroupAvgECoutput{i}{j}(k);          %Need to reorganize data for plotting: plotdatadaily{j}= [num bins numgenotypes]
                    plotSEMdaily30(k,i)= GroupAvgSEMECoutput{i}{j}(k);
%                     size(plotdatadaily);
                end
                
            end %Close number of bins.
            
            %Once all the bins have been filled into plotdatadaily, it
            %gets saved into (j)
            plotdataarraydaily{j}= plotdatadaily;       %fill in plotdata arrays with bin data
            plotSEMarraydaily{j}= plotSEMdaily;
            if selectedAnalysis(j)>2                         %if analysis type >3
                plotdataarraydaily{j}= plotdatadaily;       %fill in plotdata arrays with bin data
                plotSEMarraydaily{j}= plotSEMdaily;
            else                            %if analysis type is in 30min bins (s30 or amean)
                plotdataarraydaily{j}= plotdatadaily30;
                plotSEMarraydaily{j}= plotSEMdaily30;
                
            end
        end %length of CalcXObject = 2.
    end
end
