function [ ySMAP,yLSTM,yGLDAS,yCov,covMethod] = testRnnSMAP_readData( outFolder,trainName,testName,iter,varargin )
%TESTRNNSMAP_READDATA Summary of this function goes here
%   Detailed explanation goes here

pnames={'doAnorm'};
dflts={0};
[doAnorm]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if strcmp(testName,trainName)
    sameRegion=1;
else
    sameRegion=0;
end
dataLoaded=0;
covMethod={};
yCov={};
nt=4160;
ntrain=2209;

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
if doAnorm~=0
    %yTemp=(ySMAP(1:ntrain,:)-lbSMAP)./(ubSMAP-lbSMAP)*2-1;
    ySMAPraw=ySMAP;
    yMean=nanmean(ySMAP);
    ySMAP=ySMAP-repmat(yMean,[nt,1]);
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
if doAnorm~=0
    yMeanGLDAS=nanmean(yGLDAS);
    yGLDAS=yGLDAS-repmat(yMeanGLDAS,[nt,1]);
end
toc

%% read LSTM data
disp('read Prediction')
tic
dataLSTM=readRnnPred(outFolder,trainName,testName,iter);
if doAnorm~=0
    yTempLSTM=(ySMAPraw(1:ntrain,:)-lbSMAP)./(ubSMAP-lbSMAP)*2-1;
    yMeanLSTM=nanmean(yTempLSTM);
    yLSTM=(dataLSTM+repmat(yMeanLSTM,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    yLSTM=yLSTM-repmat(yMean,[nt,1]);
else
    yLSTM=(dataLSTM+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
end
toc


%% LR
disp('calculate/load LR')
tic
LRFile=[outFolder,'outLR_',trainName,'_',testName,'.mat'];
if exist(LRFile,'file')
    LRmat=load(LRFile);
    yLR=LRmat.yLR;
else
    if dataLoaded==0
        [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
        if doAnorm
            yTrainMean=nanmean(yTrain);
            yTestMean=yTrainMean;
        else
            yTrainMean=0;
            yTestMean=0;
        end
        if ~sameRegion
            [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName);
            if doAnorm
                yTestMean=nanmean(yTest);
            else
                yTestMean=0;
            end
        end
        dataLoaded=1;
    end
    [yLRNorm,b] = regSMAP_LR(xTrain,yTrain-repmat(yTrainMean,[nt,1]));
    if ~sameRegion
        [yLRNorm,bTemp] = regSMAP_LR(xTest,yTest-repmat(yTestMean,[nt,1]),b);
    end
    yLR=(yLRNorm+repmat(yTestMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    save(LRFile,'yLR');
end
if doAnorm
    yLR=yLR-repmat(yMean,[nt,1]);
end
covMethod=[covMethod,'LR'];
yCov=[yCov,yLR];
toc

%% LR solo
if sameRegion
    disp('calculate/load LR solo')
    tic
    LRsoloFile=[outFolder,'outLRsolo_',trainName,'_',testName,'.mat'];
    if exist(LRsoloFile,'file')
        LRsolomat=load(LRsoloFile);
        yLRsolo=LRsolomat.yLRsolo;
    else
        if dataLoaded==0
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
            if doAnorm
                yTrainMean=nanmean(yTrain);
            else
                yTrainMean=0;
            end
            dataLoaded=1;
        end
        yLRsoloNorm=regSMAP_LR_solo(xTrain,yTrain-repmat(yTrainMean,[nt,1]));
        yLRsolo=(yLRsoloNorm+repmat(yTrainMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
        save(LRsoloFile,'yLRsolo');
    end
    if doAnorm
        yLRsolo=yLRsolo-repmat(yMean,[nt,1]);
    end
    covMethod=[covMethod,'LRsolo'];
    yCov=[yCov,yLRsolo];
    toc
    
end

%% NN
disp('calculate/load NN')
tic
NNFile=[outFolder,'outNN_',trainName,'_',testName,'.mat'];
if exist(NNFile,'file')
    LRmat=load(NNFile);
    yNN=LRmat.yNN;
else
    if dataLoaded==0
        [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
        if doAnorm
            yTrainMean=nanmean(yTrain);
            yTestMean=yTrainMean;
        else
            yTrainMean=0;
            yTestMean=0;
        end
        if ~sameRegion
            [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName);
            if doAnorm
                yTestMean=nanmean(yTest);
            else
                yTestMean=0;
            end
        end
        dataLoaded=1;
    end
    [yNNNorm,net] = regSMAP_nn(xTrain,yTrain-repmat(yTrainMean,[nt,1]));
    if ~sameRegion
        [yNNNorm,netTemp] = regSMAP_nn(xTest,yTest-repmat(yTestMean,[nt,1]),net);
    end
    yNN=(yNNNorm+repmat(yTestMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
    save(NNFile,'yNN');
end
if doAnorm~=0
    yNN=yNN-repmat(yMean,[nt,1]);
end
covMethod=[covMethod,'NN'];
yCov=[yCov,yNN];
toc

%% NN solo
if sameRegion
    disp('calculate/load NN solo')
    tic
    NNsoloFile=[outFolder,'outNNsolo_',trainName,'_',testName,'.mat'];
    if exist(NNsoloFile,'file')
        LRmat=load(NNsoloFile);
        yNNsolo=LRmat.yNNsolo;
    else
        if dataLoaded==0
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);
            if doAnorm
                yTrainMean=nanmean(yTrain);
            else
                yTrainMean=0;
            end
            dataLoaded=1;
        end
        yNNsoloNorm = regSMAP_nn_solo(xTrain,yTrain-repmat(yTrainMean,[nt,1]));
        yNNsolo=(yNNsoloNorm+repmat(yTrainMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
        save(NNsoloFile,'yNNsolo');
    end    
    if doAnorm
        yNNsolo=yNNsolo-repmat(yMean,[nt,1]);
    end
    covMethod=[covMethod,'NNsolo'];
    yCov=[yCov,yNNsolo];
    toc
end



