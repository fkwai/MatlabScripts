function statBoxPlot( statLSTM,statGLDAS,statCov,covMethod,figfolder,varargin )
%PLOTSTATSMAP_BAR Summary of this function goes here
% example:
% load('Y:\Kuai\rnnSMAP\output\CONUS_div\statExtro.mat')
% covMethod={'LR','NN'};
% figfolder=['Y:\Kuai\rnnSMAP\output\CONUS_div\plot\Extro\'];
% if ~exist(figfolder,'dir')
%     mkdir(figfolder)
% end
% statCov(1)=statLR;
% statCov(2)=statNN;


%
postStr=[];
% if ~isempty(varargin)
%     postStr=varargin{1};
% end

figPos=[100,100,800,600];
statLst={'nash','rsq','rmse','bias'};
plotRangeLst=[-10,1;0,1;0,0.5;0,0.5];

for k=1:4
    stat=statLst{k};
    plotRange=plotRangeLst(k,:);
    plotData=[statLSTM.(stat),statGLDAS.(stat)];
    for i=1:length(statCov)
        plotData=[plotData,statCov(i).(stat)];
    end
    plotLabel=['LSTM','GLDAS',covMethod];
    
    f=figure('Position',figPos);
    boxplot(plotData,'Labels',plotLabel);
    ylim(plotRange);
    title(stat)
    fixFigure()
    savefig([figfolder,'\',stat,'Box',postStr,'.fig'])
    close(f)
    
    f=figure('Position',figPos);
    H=notBoxPlot(plotData,[],'jitter',0.5);
    ylim(plotRange);
    set([H.data],'markersize',2)
    set(gca,'XTickLabel',plotLabel)
    title(stat)
    fixFigure()
    savefig([figfolder,'\',stat,'notBox',postStr,'.fig'])
    close(f)    
end



end

