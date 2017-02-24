function testRnnSMAP_map(outFolder,trainName,testName,iter,varargin)
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

pnames={'shapefile','stat','opt','colorRange','doAnorm'};
dflts={[],'nash',1,[],0};
[shapefile,stat,opt,colorRange,doAnorm]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
dirSMAP='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat','tnum');

testFile=[outFolder,'\',testName,'.csv'];
testInd=csvread(testFile);
nt=4160;
ntrain=2209;

%% read data
[ySMAP,yLSTM,yGLDAS,yCov,covMethod]=...
    testRnnSMAP_readData(outFolder,trainName,testName,iter,'doAnorm',1);


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
crdFile=[dirSMAP,'crdIndex.csv'];
crdAll=csvread(crdFile);
crdTest=crdAll(testInd,:);
xSort=sort(unique(crdTest(:,1)));
cellsize=xSort(2)-xSort(1); %!!!may modify later
[gridStat,xx,yy] = data2grid( statLSTM(opt+1).(stat),crdTest(:,2),crdTest(:,1),cellsize);

[gridSMAP,xx,yy] = data2grid3d(ySMAP',crdTest(:,2),crdTest(:,1),cellsize);
tsStr(1).grid=gridSMAP;
tsStr(1).t=tnum;
tsStr(1).symb='or';
tsStr(1).legendStr='SMAP';

[gridLSTM,xx,yy] = data2grid3d(yLSTM',crdTest(:,2),crdTest(:,1),cellsize);
tsStr(2).grid=gridLSTM;
tsStr(2).t=tnum;
tsStr(2).symb='-b';
tsStr(2).legendStr='LSTM';

[gridGLDAS,xx,yy] = data2grid3d(yGLDAS',crdTest(:,2),crdTest(:,1),cellsize);
tsStr(3).grid=gridGLDAS;
tsStr(3).t=tnum;
tsStr(3).symb='-k';
tsStr(3).legendStr='GLDAS';

% for k=1:length(yCov)
%     [gridTemp,xx,yy] = data2grid3d(yCov{k}',crdTest(:,2),crdTest(:,1),cellsize);
%     tsStrTemp.grid=gridTemp;
%     tsStrTemp.t=tnum;
%     tsStrTemp.symb=getS(k,'l');
%     tsStrTemp.legendStr=covMethod{k};
%     tsStr=[tsStr,tsStrTemp];
% end

showGrid( gridStat,xx,yy,cellsize,'colorRange',colorRange,'tsStr',tsStr,'shapefile',shapefile)
end

