function [statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,iter,varargin)
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

pnames={'optSMAP','optGLDAS'};
dflts={1,1};
[optSMAP,optGLDAS]=internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat','tnum');
nt=520;
ntrain=276;

%% read data
[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(...
    outFolder,trainName,testName,iter,'optSMAP',optSMAP,'optGLDAS',optGLDAS);

%% calculate stat
disp('calculate Stat')
tic
t1=1:ntrain-1;
t2=ntrain:nt;
statLSTM(1)=statCal(yLSTM,ySMAP);
statLSTM(2)=statCal(yLSTM(t1,:),ySMAP(t1,:));
statLSTM(3)=statCal(yLSTM(t2,:),ySMAP(t2,:));

statGLDAS(1)=statCal(yGLDAS,ySMAP);
statGLDAS(2)=statCal(yGLDAS(t1,:,:),ySMAP(t1,:));
statGLDAS(3)=statCal(yGLDAS(t2,:,:),ySMAP(t2,:));

for k=1:length(covMethod)
    mStr=covMethod{k};
    yTemp=yCov{k};
    statAll(k)=statCal(yTemp,ySMAP);
    statTrain(k)=statCal(yTemp(t1,:,:),ySMAP(t1,:));
    statTest(k)=statCal(yTemp(t2,:,:),ySMAP(t2,:));
end

if length(covMethod)==4
    symMethod={'b.','bo','g.','go'};    
elseif length(covMethod)==2
    symMethod={'b.','g.'};
end
toc


%% plot stat
figfolder=[outFolder,'/plot/',trainName,'_',testName,'_',num2str(iter),'/'];
if ~exist(figfolder,'dir')
    mkdir(figfolder)
end
% statCompPlot(statLSTM(1),statGLDAS(1),statAll,covMethod,symMethod,figfolder,'_All')
% statCompPlot(statLSTM(2),statGLDAS(2),statTrain,covMethod,symMethod,figfolder,'_Train')
% statCompPlot(statLSTM(3),statGLDAS(3),statTest,covMethod,symMethod,figfolder,'_Test')

statBoxPlot(statLSTM(1),statGLDAS(1),statAll,covMethod,figfolder,'_All')
statBoxPlot(statLSTM(2),statGLDAS(2),statTrain,covMethod,figfolder,'_Train')
statBoxPlot(statLSTM(3),statGLDAS(3),statTest,covMethod,figfolder,'_Test')


end

