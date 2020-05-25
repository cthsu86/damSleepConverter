function plotMedianQuartiles(vals,xcenter,medwidth,quartilewidth,linecolor,varargin);
iqr = 1;
if(~isempty(vals)),
    if(nargin==6),
        textHeight = varargin{1};
    else,
        textHeight = 1.1*max(vals);
    end;
    % valrange = max(vals)-min(vals);
    if(iqr),
        %------------Medians, IQRs
            medval = nanmedian(vals);
        %     % sortedvals = sort(vals,'ascend');
        %     % quartileNumvals = sum(~isnan(vals))/4;
        lowerQuartileVal = quantile(vals(~isnan(vals)),0.25);
        upperQuartileVal = quantile(vals(~isnan(vals)),0.75);
        iqr_range = upperQuartileVal-lowerQuartileVal;
        lowerWhiskerBound = medval-1.5*iqr_range;
        upperWhiskerBound =  medval+1.5*iqr_range;
    else,
        %------------Means, SEMs
        medval = nanmean(vals);
        lowerQuartileVal = medval-nanstd(vals)/sqrt(sum(~isnan(vals))); %quantile(vals(~isnan(vals)),0.25);
        upperQuartileVal = medval+nanstd(vals)/sqrt(sum(~isnan(vals))); %quantile(vals(~isnan(vals)),0.75);
            %This actually isn't the legitimate whisker definition for Means&SEMS
%         upperWhisker = quantile(vals(~isnan(vals)),0.95);
%         lowerWhisker = quantile(vals(~isnan(vals)),0.05);
        %Should be 3*stdev abov median?
        std_vals = nanstd(vals);
        lowerWhiskerBound = medval-3*std_vals;
        upperWhiskerBound =  medval+3*std_vals;
    end;
    
    plot([xcenter-(medwidth/2) xcenter+(medwidth/2)],[medval medval],'Color',linecolor,'LineWidth',2); hold on;
    %     plot([xcenter-(quartilewidth/2) xcenter+(quartilewidth/2)],[lowerQuartileVal lowerQuartileVal],'Color',linecolor,'LineWidth',1); hold on;
    %     plot([xcenter-(quartilewidth/2) xcenter+(quartilewidth/2)],[upperQuartileVal upperQuartileVal],'Color',linecolor,'LineWidth',1); hold on;
    %     plot([xcenter xcenter],[lowerQuartileVal upperQuartileVal],'Color',linecolor); hold on;
    
    plot([xcenter-(quartilewidth/2) xcenter-(quartilewidth/2)],[lowerQuartileVal upperQuartileVal],'Color',linecolor,'LineWidth',1); hold on;
    plot([xcenter+(quartilewidth/2) xcenter+(quartilewidth/2)],[lowerQuartileVal upperQuartileVal],'Color',linecolor,'LineWidth',1); hold on;

    withinWhiskerBoundIndices = find(vals<upperWhiskerBound & vals>lowerWhiskerBound);
    upperWhisker = max(vals(withinWhiskerBoundIndices));
    lowerWhisker = min(vals(withinWhiskerBoundIndices));
    plot([xcenter xcenter],[upperQuartileVal upperWhisker],'Color',linecolor,'LineWidth',1); hold on;
    plot([xcenter xcenter],[lowerQuartileVal lowerWhisker],'Color',linecolor,'LineWidth',1); hold on;
    
    upperWhiskerIndices = find(vals>upperWhiskerBound);
    lowerWhiskerIndices = find(vals<lowerWhiskerBound);
    %Things that exceed the whiksers.
    if(numel(upperWhiskerIndices)>0),
        plot(xcenter*ones(numel(upperWhiskerIndices,1)),vals(upperWhiskerIndices),'Color',linecolor,'Marker','o','MarkerSize',3);
    end;
    if(numel(lowerWhiskerIndices)>0),
        plot(xcenter*ones(numel(lowerWhiskerIndices,1)),vals(lowerWhiskerIndices),'Color',linecolor,'Marker','o','MarkerSize',3);
    end;
    
    if(strcmp(textHeight,' ')),
    else,
        %Set A
        %         text(xcenter-(medwidth/2),1*textHeight,[num2str(round(medval*10)/10)]);
        %         text(xcenter-(quartilewidth/2),0.9*textHeight,['(n_b = ' num2str(sum(~isnan(vals))) ')']);
        %Set B
        % text(xcenter-(medwidth/2),max(vals)+2*textHeight,[num2str(round(medval*10)/10)]);
        % text(xcenter-(quartilewidth/2),max(vals)+1*textHeight,['(n_b = ' num2str(sum(~isnan(vals))) ')']);
        %Set C
        text(xcenter-(medwidth/2),min(vals)*0.6,[num2str(round(medval*10)/10)],'Color',linecolor); % ', (n_b = ' num2str(sum(~isnan(vals))) ')']);
        
    end;
end;