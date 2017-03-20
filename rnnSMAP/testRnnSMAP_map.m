function [gridStat,xx,yy,cellsize]=testRnnSMAP_map(outFolder,trainName,testName,iter,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
% outFolder='Y:\Kuai\rnnSMAP\output\PA\';
% trainName='PA';
% testName='PA';
% iter=2000;
% opt=1; %0->all; 1->train; 2->test
% colorRange -> color range of map
% shapefile -> shapefile plot in map
% doAnorm -> if the result is anormaly then doAnorm=1

pnames={'shapefile','stat','opt','colorRange','optSMAP','optGLDAS'};
dflts={[],'nash',1,[],1,1};
[shapefile,stat,opt,colorRange,optSMAP,optGLDAS]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
dirSMAP='E:\Kuai\rnnSMAP\Database\tDB_SMPq_Anomaly_Daily\';
tInd=csvread([dirSMAP,'\tIndex.csv']);
tStr=num2str(tInd,'%8.0f');
tnum=datenum(tStr,'yyyymmdd');

testFile=[outFolder,'\',testName,'.csv'];
testInd=csvread(testFile);
nt=520;
ntrain=277;

%% read data
[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(...
    outFolder,trainName,testName,iter,'optSMAP',optSMAP,'optGLDAS',optGLDAS,'readCov',1);


%% calculate stat
disp('calculate Stat')
tic
t1=1:ntrain-1;
t2=ntrain:nt;
statLSTM(1)=statCal(yLSTM,ySMAP);
statLSTM(2)=statCal(yLSTM(t1,:,:),ySMAP(t1,:));
statLSTM(3)=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
toc


%% transfer to grid
crdFile=['Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv'];
crdAll=csvread(crdFile);
crdTest=crdAll(testInd,:);
xSort=sort(unique(crdTest(:,1)));
cellsize=xSort(2)-xSort(1); %!!!may modify later
[gridStatLSTM,xx,yy] = data2grid( statLSTM(opt+1).(stat),crdTest(:,2),crdTest(:,1));

[gridSMAP,xx,yy] = data2grid3d(ySMAP',crdTest(:,2),crdTest(:,1));
tsStr(1).grid=gridSMAP;
tsStr(1).t=tnum;
tsStr(1).symb='or';
tsStr(1).legendStr='SMAP';

[gridLSTM,xx,yy] = data2grid3d(yLSTM',crdTest(:,2),crdTest(:,1));
tsStr(2).grid=gridLSTM;
tsStr(2).t=tnum;
tsStr(2).symb='-b';
tsStr(2).legendStr='LSTM';

[gridGLDAS,xx,yy] = data2grid3d(yGLDAS',crdTest(:,2),crdTest(:,1));
tsStr(3).grid=gridGLDAS;
tsStr(3).t=tnum;
tsStr(3).symb='-k';
tsStr(3).legendStr='GLDAS';

yCov=yCov([1,3]);
covMethod=covMethod([1,3]);
if length(covMethod)==4
    symMethod={'y.','yo','g.','go'};    
elseif length(covMethod)==2
    symMethod={'yo','go'};
end
for k=1:length(yCov)
    [gridTemp,xx,yy] = data2grid3d(yCov{k}',crdTest(:,2),crdTest(:,1));
    tsStrTemp.grid=gridTemp;
    tsStrTemp.t=tnum;
    tsStrTemp.symb=symMethod{k};
    tsStrTemp.legendStr=covMethod{k};
    tsStr=[tsStr,tsStrTemp];
end

showGrid( gridStatLSTM,xx,yy,cellsize,'colorRange',colorRange,'tsStr',tsStr,'shapefile',shapefile)
end

