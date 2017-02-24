function statCompPlot(statLSTM,statGLDAS,statCov,covMethod,symMethod,figfolder,varargin)
% plot and save figures
% removed LR and LRsolo

postStr=[];
if ~isempty(varargin)
    postStr=varargin{1};
end

figPos=[100,100,800,600];

statLst={'nash','rsq','rmse','bias'};
plotRangeLst=[-10,1;0,1;0,0.4;-0.3,0.3];

for k=1:length(statLst)
    f=figure('Position',figPos);
    stat=statLst{k};
    plotRange=plotRangeLst(k,:);
    plot(statLSTM.(stat),statGLDAS.(stat),'r*');hold on    
    for kk=1:length(statCov)        
        plot(statLSTM.(stat),statCov(kk).(stat),symMethod{kk});hold on
    end    
    indLSTM=statLSTM.(stat)>plotRange(1)&statLSTM.(stat)<plotRange(2);    
    legendStr=[];    
    item=['GLDAS',covMethod];
    for kk=1:length(item)
        if kk==1
            statItem=eval(['stat',item{kk}]);
        else
            statItem=statCov(kk-1);
        end
        indItem=statItem.(stat)>plotRange(1)&statItem.(stat)<plotRange(2);
        if ~strcmp(stat,'bias')
            v1=num2str(mean(statItem.(stat)(indItem)));
        else
            v1=num2str(mean(abs(statItem.(stat)(indItem))));
        end
        v2=num2str(sum(indItem));
        legendStr=[legendStr,{[item{kk},' ',num2str(v1),'(',num2str(v2),')']}];
    end
    
    axis equal
    xlim(plotRange)
    ylim(plotRange)
    plot121Line
    if ~strcmp(stat,'bias')
        title([stat,'; ',num2str(mean(statLSTM.(stat)(indLSTM))),'(',num2str(sum(indLSTM)),')'])
    else
        title([stat,'; ',num2str(mean(abs(statLSTM.(stat)(indLSTM)))),'(',num2str(sum(indLSTM)),')'])
    end
    xlabel('LSTM')
    ylabel('Prediction')
    legend(legendStr,'Location','northeastoutside');
    fixFigure()
    savefig([figfolder,'\',stat,'Comp',postStr,'.fig'])
    hold off
    close(f)
end

end

