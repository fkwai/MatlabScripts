function testRnnSMAP_map(outName,trainName,testName,epoch,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
% outFolder='Y:\Kuai\rnnSMAP\output\PA\';
% trainName='PA';
% testName='PA';
% iter=2000;
% opt=1; % 1->train; 2->test
% colorRange -> color range of map
% shapefile -> shapefile plot in map
% doAnorm -> if the result is anormaly then doAnorm=1

pnames={'shapefile','stat','opt','colorRange','optSMAP','optGLDAS','timeOpt'};
dflts={[],'rmse',1,[0,0.1],1,1,1};
[shapefile,stat,opt,colorRange,optSMAP,optGLDAS,timeOpt]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
dataFolder=kPath.DBSMAP_L3;
dirData=[dataFolder,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'time.csv'];

%% predefine
if timeOpt==1
    tTrain=1:366;
    tTest=367:732;
elseif timeOpt==2
    tTrain=1:732;
    tTest=1:732;
elseif timeOpt==3
    tTrain=1:366;
    tTest=1:366;
end

crd=csvread(fileCrd);
t=csvread(fileDate);
if strcmp(testName,trainName)
    tnum=datenumMulti(t(tTest),1);
else
    tnum=datenumMulti(t,1);
end
%% read data
[outTrain,outTest,covMethod]=testRnnSMAP_readData(...
    outName,trainName,testName,epoch,'timeOpt',timeOpt);

%% calculate stat
if opt==1
    out=outTrain;
elseif opt==2
    out=outTest;
end
disp('calculate Stat')
tic
statLSTM=statCal(out.yLSTM,out.ySMAP);
% statGLDAS=statCal(out.yGLDAS,out.yGLDAS);
% statLR=statCal(out.yLR,out.yLR);
% statNN=statCal(out.yNN,out.yNN);
toc


%% transfer to grid
[gridStatLSTM,xx,yy] = data2grid( statLSTM.(stat),crd(:,2),crd(:,1));

[gridSMAP,xx,yy] = data2grid3d(out.ySMAP',crd(:,2),crd(:,1));
tsStr(1).grid=gridSMAP;
tsStr(1).t=tnum;
tsStr(1).symb='or';
tsStr(1).legendStr='SMAP';

[gridLSTM,xx,yy] = data2grid3d(out.yLSTM',crd(:,2),crd(:,1));
tsStr(2).grid=gridLSTM;
tsStr(2).t=tnum;
tsStr(2).symb='-b';
tsStr(2).legendStr='LSTM';

[gridGLDAS,xx,yy] = data2grid3d(out.yGLDAS',crd(:,2),crd(:,1));
tsStr(3).grid=gridGLDAS;
tsStr(3).t=tnum;
tsStr(3).symb='-k';
tsStr(3).legendStr='GLDAS';

[gridGLDAS,xx,yy] = data2grid3d(out.yLR',crd(:,2),crd(:,1));
tsStr(4).grid=gridGLDAS;
tsStr(4).t=tnum;
tsStr(4).symb='*y';
tsStr(4).legendStr='LR';

[gridGLDAS,xx,yy] = data2grid3d(out.yNN',crd(:,2),crd(:,1));
tsStr(5).grid=gridGLDAS;
tsStr(5).t=tnum;
tsStr(5).symb='*g';
tsStr(5).legendStr='NN';

% if length(covMethod)==4
%     symMethod={'y.','yo','g.','go'};    
% elseif length(covMethod)==2
%     symMethod={'yo','go'};
% end
% for k=1:length(yCov)
%     [gridTemp,xx,yy] = data2grid3d(yCov{k}',crdTest(:,2),crdTest(:,1));
%     tsStrTemp.grid=gridTemp;
%     tsStrTemp.t=tnum;
%     tsStrTemp.symb=symMethod{k};
%     tsStrTemp.legendStr=covMethod{k};
%     tsStr=[tsStr,tsStrTemp];
% end

yIn=[length(yy):-1:1]';
xIn=1:length(xx);

showGrid( gridStatLSTM,yIn,xIn,1,'colorRange',colorRange,'tsStr',tsStr,...
    'shapefile',shapefile,'yRange',[0,0.5])
end

