function testRnnSMAP_plot(outFolder,trainName,testName,iter,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
% outFolder='Y:\Kuai\rnnSMAP\output\PA\';
% trainName='PA';
% testName='PA';
% iter=2000;
% optSMAP: 1 -> real; 2 -> anomaly
% optGLDAS: 1 -> real; 2 -> anomaly; 0 -> no soilM

pnames={'optSMAP','optGLDAS','indSel','testTime'};
dflts={1,1,[],1};
[optSMAP,optGLDAS,indSel,testTime]=internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
if isempty(indSel)
    figfolder=[outFolder,'/plot/',trainName,'_',testName,'_',num2str(iter),'/'];
else
    figfolder=[outFolder,'/plot/',trainName,'_',testName,'_',num2str(iter),'_sel/'];
end
if ~exist(figfolder,'dir')
    mkdir(figfolder)
end

%% read data
[outTrain,outTest,covMethod]=testRnnSMAP_readData(...
    outFolder,trainName,testName,iter,'testTime',testTime);

if length(covMethod)==4
    symMethod={'b.','bo','g.','go'};    
elseif length(covMethod)==2
    symMethod={'b.','g.'};
end


for kk=1:2
    if kk==1
        out=outTrain;
    else
        out=outTest;
    end
    
    indSel=1:size(out.ySMAP,2);
    
%% calculate stat    
    statLSTM=statCal(out.yLSTM(:,indSel),out.ySMAP(:,indSel));
    statGLDAS=statCal(out.yGLDAS(:,indSel),out.ySMAP(:,indSel));
    for k=1:length(covMethod)
        mStr=covMethod{k};
        yTemp=out.(['y',mStr]);
        statCov(k)=statCal(yTemp(:,indSel),out.ySMAP(:,indSel));
    end

%% box plot
    if kk==1
        statBoxPlot(statLSTM,statGLDAS,statCov,covMethod,figfolder,'_Train')
    else
        statBoxPlot(statLSTM,statGLDAS,statCov,covMethod,figfolder,'_Test')
    end
end


end

