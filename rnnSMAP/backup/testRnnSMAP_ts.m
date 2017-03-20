function testRnnSMAP_ts(outFolder,trainName,testName,iter,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
% outFolder='Y:\Kuai\rnnSMAP\output\PA\';
% trainName='PA';
% testName='PA';
% iter=2000;

pnames={'stat','gridInd'};
dflts={'nash',[]};
[stat,gridInd]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
dirSMAP='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
dirGLDAS='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
testFile=[outFolder,'\',testName,'.csv'];
testInd=csvread(testFile);
nt=4160;
ntrain=2209;
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat','tnum');

%% read prediction data
disp('read Prediction')
tic
dataLSTM=readRnnPred( outFolder,trainName,testName,iter);
toc

%% read obs and soilM
disp('read SMAP and GLDAS')
tic
% SMAP
ySMAP=zeros(nt,length(testInd));
for i=1:length(testInd)
    yfile=[dirSMAP,'data\',sprintf('%06d',testInd(i)),'.csv'];
    ySMAP(:,i)=csvread(yfile);
end
ySMAP(ySMAP==-9999)=nan;
temp=csvread([dirSMAP,'stat.csv']);
lbSMAP=temp(1);ubSMAP=temp(2);

% GLDAS
yGLDAS=zeros(4160,length(testInd));
for i=1:length(testInd)
    yfile=[dirGLDAS,'data\',sprintf('%06d',testInd(i)),'.csv'];
    yGLDAS(:,i)=csvread(yfile);
end
yGLDAS(yGLDAS==-9999)=nan;
yGLDAS=yGLDAS/100;

% LSTM
yLSTM=(dataLSTM+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
toc

%% calculate stat
disp('calculate Stat')
tic
t1=1:ntrain-1;
t2=ntrain:nt;
statLSTM(1)=statCal(yLSTM,ySMAP);
statLSTM(2)=statCal(yLSTM(t1,:,:),ySMAP(t1,:));
statLSTM(3)=statCal(yLSTM(t2,:,:),ySMAP(t2,:));
toc

%% show TS
if isempty(gridInd)
    gridInd=testInd;
end    
nGrid=length(gridInd)
figure('Position',[100,100,1000,nGrid*200])
for i=1:nGrid
    subplot(nGrid,1,i);
    k=find(testInd==gridInd(i));
    plot(tnum,yLSTM(:,k),'-b','LineWidth',2);hold on
    plot(tnum,yGLDAS(:,k),'-k','LineWidth',2);hold on
    plot(tnum,ySMAP(:,k),'ro','LineWidth',2);hold on    
    legend('LSTM','GLDAS','SMAP','Location','eastoutside');
    datetick('x');hold off
end
end

