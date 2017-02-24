function [statLSTM,statGLDAS]=testRnnSMAP_plot(outFolder,trainName,testName,iter,varargin)
% First test for trained rnn model. 
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction. 

% example:
% outFolder='Y:\Kuai\rnnSMAP\output\PA\';
% trainName='PA';
% testName='PA';
% iter=2000;
% doAnorm -> if the result is anormaly then doAnorm=1

pnames={'doAnorm'};
dflts={0};
[doAnorm]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});
dataLoaded=0;

%% predefine
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat','tnum');
nt=4160;
ntrain=2209;
if strcmp(testName,trainName)
    sameRegion=1;
else
    sameRegion=0;
end

%{
covMethod={};
symMethod={};
%% read SMAP and GLDAS soilM
disp('read SMAP and GLDAS')
tic
% SMAP
SMAPmatFile=[outFolder,'outSMAP_',testName,'.mat'];
if exist(SMAPmatFile,'file')
    SMAPmat=load(SMAPmatFile);
    ySMAP=SMAPmat.ySMAP;
    lbSMAP=SMAPmat.lbSMAP;
    ubSMAP=SMAPmat.ubSMAP;
else
    [xOut,yOut,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
        'yField','SMPq','xField',[],'xField_const',[],'mode',0);
    ySMAP=yOut;
    lbSMAP=yStat(1);ubSMAP=yStat(2);
    save(SMAPmatFile,'ySMAP','lbSMAP','ubSMAP')
end

% GLDAS
GLDASmatFile=[outFolder,'outGLDAS_',testName,'.mat'];
if exist(GLDASmatFile,'file')
    GLDASmat=load(GLDASmatFile);
    yGLDAS=GLDASmat.yGLDAS;
else
    [xOut,yOut,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
        'yField','soilM','xField',[],'xField_const',[],'mode',0);
    yGLDAS=yOut;
    lbGLDAS=yStat(1);ubGLDAS=yStat(2);
    save(GLDASmatFile,'yGLDAS','lbSMAP','ubGLDAS')
end
yGLDAS=yGLDAS/100;
toc

%% read LSTM data
disp('read Prediction')
tic
dataLSTM=readRnnPred(outFolder,trainName,testName,iter);
if doAnorm~=0    
    if ~sameRegion
        yTemp=(ySMAP-lbSMAP)./(ubSMAP-lbSMAP)*2-1;
    else
        yTemp=(ySMAP(1:ntrain,:)-lbSMAP)./(ubSMAP-lbSMAP)*2-1;
    end
    yMean=nanmean(yTemp);
    yLSTM=(dataLSTM+repmat(yMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    %yLSTM=(dataLSTM+repmat(yMean,[nt,1])+1).*(ubSMAP)./2+lbSMAP;
else
    yLSTM=(dataLSTM+1).*(ubSMAP-lbSMAP)./2+lbSMAP; 
    %yLSTM=(dataLSTM+1).*(ubSMAP)./2+lbSMAP; 
end

toc


%% LR
disp('calculate/load LR')
covMethod=[covMethod,'LR'];
symMethod=[symMethod,'bo'];
tic
LRFile=[outFolder,'outLR_',trainName,'_',testName,'.mat'];
if exist(LRFile,'file')
    LRmat=load(LRFile);
    yLR=LRmat.yLR;
else
    if dataLoaded==0
        [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
        if ~sameRegion
            [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName);
        end
        dataLoaded=1;
    end
    [yLRNorm,b] = regSMAP_LR(xTrain,yTrain);
    if ~sameRegion
        [yLRNorm,bTemp] = regSMAP_LR(xTest,yTest,b);
    end        
    yLR=(yLRNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    save(LRFile,'yLR');
end
toc

%% LR solo
if sameRegion
    covMethod=[covMethod,'LRsolo'];
    symMethod=[symMethod,'b.'];
    disp('calculate/load LR solo')
    tic
    LRsoloFile=[outFolder,'outLRsolo_',trainName,'_',testName,'.mat'];
    if exist(LRsoloFile,'file')
        LRsolomat=load(LRsoloFile);
        yLRsolo=LRsolomat.yLRsolo;
    else
        if dataLoaded==0
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
            dataLoaded=1;
        end
        yLRsoloNorm=regSMAP_LR_solo(xTrain,yTrain);
        yLRsolo=(yLRsoloNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
        save(LRsoloFile,'yLRsolo');
    end
    toc
end

%% NN
disp('calculate/load NN')
covMethod=[covMethod,'NN'];
symMethod=[symMethod,'go'];
tic
NNFile=[outFolder,'outNN_',trainName,'_',testName,'.mat'];
if exist(NNFile,'file')
    LRmat=load(NNFile);
    yNN=LRmat.yNN;
else
    if dataLoaded==0
        [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
        if ~sameRegion
            [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName);
        end
        dataLoaded=1;
    end
    [yNNNorm,net] = regSMAP_nn(xTrain,yTrain);
    if ~sameRegion
        [yNNNorm,netTemp] = regSMAP_nn(xTest,yTest,net);
    end    
    yNN=(yNNNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    save(NNFile,'yNN');
end
toc

%% NN solo
if sameRegion
    covMethod=[covMethod,'NNsolo'];
    symMethod=[symMethod,'g.'];
    disp('calculate/load NN solo')
    tic
    NNsoloFile=[outFolder,'outNNsolo_',trainName,'_',testName,'.mat'];
    if exist(NNsoloFile,'file')
        LRmat=load(NNsoloFile);
        yNNsolo=LRmat.yNNsolo;
    else
        if dataLoaded==0
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
            dataLoaded=1;
        end
        yNNsoloNorm = regSMAP_nn_solo(xTrain,yTrain);
        yNNsolo=(yNNsoloNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
        save(NNsoloFile,'yNNsolo');
    end
    toc
end
%}

%% read data
[ySMAP,yLSTM,yGLDAS,yCov,covMethod]...
    = testRnnSMAP_readData( outFolder,trainName,testName,iter,'doAnorm',doAnorm);

%% calculate stat
disp('calculate Stat')
tic
t1=1:ntrain-1;
t2=ntrain:nt;
statLSTM(1)=statCal(yLSTM,ySMAP);
statLSTM(2)=statCal(yLSTM(t1,:,:),ySMAP(t1,:));
statLSTM(3)=statCal(yLSTM(t2,:,:),ySMAP(t2,:));

% statARIMAsolo(1)=statCal(yARIMAsolo,ySMAP);
% statARIMAsolo(2)=statCal(yARIMAsolo(t1,:,:),ySMAP(t1,:));
% statARIMAsolo(3)=statCal(yARIMAsolo(t2,:,:),ySMAP(t2,:));

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
statCompPlot(statLSTM(1),statGLDAS(1),statAll,covMethod,symMethod,figfolder,'_All')
statCompPlot(statLSTM(2),statGLDAS(2),statTrain,covMethod,symMethod,figfolder,'_Train')
statCompPlot(statLSTM(3),statGLDAS(3),statTest,covMethod,symMethod,figfolder,'_Test')



end

