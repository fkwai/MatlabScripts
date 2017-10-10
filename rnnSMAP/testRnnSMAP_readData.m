function [outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,iter,varargin)
% optSMAP: 1 -> real; 2 -> anomaly
% optGLDAS: 1 -> real; 2 -> anomaly; 0 -> no soilM

pnames={'readCov','readData','timeOpt','varLstName','varConstLstName','model'};
dflts={1,1,1,'varLst','varConstLst',[]};
[readCov,readData,timeOpt,varLstName,varConstLstName,model]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

global kPath
outFolder=[kPath.OutSMAP_L3,outName,kPath.s];

if strcmp(testName,trainName)
    sameRegion=1;
else
    sameRegion=0;
end
covMethod={};

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

if isempty(model)
    modelField='LSOIL_0-10';
else
    switch model
        case 'Noah'
            modelField='LSOIL_0-10';
        case 'MOS'
            modelField='SOILM_0-10_MOS';
    end
end

if readData==1
    disp('read Database')
    tic
    if sameRegion
        [xOut,yOut,xStat,yStat]=readDatabaseSMAP_All(testName,...
            'var',varLstName,'varC',varConstLstName);
        xTrain=xOut(tTrain,:,:);
        yTrain=yOut(tTrain,:);
        xTest=xOut(tTest,:,:);
        yTest=yOut(tTest,:);
    else
        [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP_All(trainName,...
            'var',varLstName,'varC',varConstLstName);
        xTrain=xTrain(tTrain,:,:);
        yTrain=yTrain(tTrain,:);
        [xTest,yTest,xStatTest,yStatTest]=readDatabaseSMAP_All(testName,...
            'var',varLstName,'varC',varConstLstName);
        xTest=xTest(tTest,:,:);
        yTest=yTest(tTest,:);
    end
    toc
end

%% read SMAP
disp('read SMAP and GLDAS')
tic
% SMAP
SMAPmatFile=[outFolder,'outSMAP_',trainName,'_',testName,'.mat'];
if exist(SMAPmatFile,'file')
    SMAPmat=load(SMAPmatFile);
    outTrain.ySMAP=SMAPmat.ySMAP_train;
    outTest.ySMAP=SMAPmat.ySMAP_test;
    lbSMAP=SMAPmat.lbSMAP;
    ubSMAP=SMAPmat.ubSMAP;
    meanSMAP=SMAPmat.meanSMAP;
    stdSMAP=SMAPmat.stdSMAP;
else
    [yTrainSMAP,yTrainSMAPStat] = readDatabaseSMAP(trainName,'SMAP');
    [yTestSMAP,yTestSMAPStat] = readDatabaseSMAP(testName,'SMAP');
    
    ySMAP_train=yTrainSMAP(tTrain,:);
    ySMAP_test=yTestSMAP(tTest,:);
    outTrain.ySMAP=ySMAP_train;
    outTest.ySMAP=ySMAP_test;
    lbSMAP=yTrainSMAPStat(1);
    ubSMAP=yTrainSMAPStat(2);
    meanSMAP=yTrainSMAPStat(3);
    stdSMAP=yTrainSMAPStat(4);
    save(SMAPmatFile,'ySMAP_train','ySMAP_test','lbSMAP','ubSMAP','meanSMAP','stdSMAP')
end

%% read GLDAS soilM
GLDASmatFile=[outFolder,'outGLDAS_',trainName,'_',testName,'.mat'];
if exist(GLDASmatFile,'file')
    GLDASmat=load(GLDASmatFile);
    outTrain.yGLDAS=GLDASmat.yGLDAS_train;
    outTest.yGLDAS=GLDASmat.yGLDAS_test;
else
    [xSoilmTrain,xSoilmStatTrain] = readDatabaseSMAP(trainName,modelField);
    [xSoilmTest,xSoilmStatTest] = readDatabaseSMAP(testName,modelField);
    stdSoilm=xSoilmStatTrain(3);
    meanSoilm=xSoilmStatTrain(4);
    yGLDAS_train=xSoilmTrain(tTrain,:)/100;
    yGLDAS_test=xSoilmTest(tTest,:)/100;
    outTrain.yGLDAS=yGLDAS_train;
    outTest.yGLDAS=yGLDAS_test;
    save(GLDASmatFile,'yGLDAS_train','yGLDAS_test')
end
toc

%% read LSTM data
disp('read Prediction')
tic
LSTMmatFile=[outFolder,'outLSTM_',trainName,'_',testName,'_',num2str(iter),'.mat'];
if exist(LSTMmatFile,'file')
    LSTMmat=load(LSTMmatFile);
    outTrain.yLSTM=LSTMmat.yLSTM_train;
    outTest.yLSTM=LSTMmat.yLSTM_test;
else
    [dataTrain,dataTest]=readRnnPred(outName,trainName,testName,iter,timeOpt);
    %yLSTM_train=(dataTrain+1)./2*(ubSMAP-lbSMAP)+lbSMAP;
    %yLSTM_test=(dataTest+1)./2*(ubSMAP-lbSMAP)+lbSMAP;
    yLSTM_train=(dataTrain).*stdSMAP+meanSMAP;
    yLSTM_test=(dataTest).*stdSMAP+meanSMAP;
    outTrain.yLSTM=yLSTM_train;
    outTest.yLSTM=yLSTM_test;
    save(LSTMmatFile,'yLSTM_train','yLSTM_test')
end
toc

if readCov==1
    %% LR
    disp('calculate/load LR')
    tic
    LRFile=[outFolder,'outLR_',trainName,'_',testName,'.mat'];
    if exist(LRFile,'file')
        LRmat=load(LRFile);
        outTrain.yLR=LRmat.yLR_train;
        outTest.yLR=LRmat.yLR_test;
    else
        [yLR_train,b,inte] = regSMAP_LR(xTrain,yTrain);
        [yLR_test,b2,inte2] = regSMAP_LR(xTest,yTest,b,inte);
        outTrain.yLR=yLR_train;
        outTest.yLR=yLR_test;
        save(LRFile,'yLR_train','yLR_test');
    end
    covMethod=[covMethod,'LR'];
    toc
    
    %% LR pbp
    if sameRegion
        disp('calculate/load LR solo')
        tic
        LRpbpFile=[outFolder,'outLRpbp_',trainName,'_',testName,'.mat'];
        if exist(LRpbpFile,'file')
            LRpbpmat=load(LRpbpFile);
            outTrain.yLRpbp=LRpbpmat.yLRpbp_train;
            outTest.yLRpbp=LRpbpmat.yLRpbp_test;
        else
            [yLRpbp_train,bLst,cLst] = regSMAP_LR_solo(xTrain,yTrain);
            [yLRpbp_test,bLst2,cLst2] = regSMAP_LR_solo(xTest,yTest,bLst,cLst);
            outTrain.yLRpbp=yLRpbp_train;
            outTest.yLRpbp=yLRpbp_test;
            save(LRpbpFile,'yLRpbp_train','yLRpbp_test');
        end
        covMethod=[covMethod,'LRpbp'];
        toc
    end
    
    %% NN
    disp('calculate/load NN')
    tic
    NNFile=[outFolder,'outNN_',trainName,'_',testName,'.mat'];
    netFile=[outFolder,'net_',trainName,'.mat'];
    if exist(NNFile,'file')
        NNmat=load(NNFile);
        outTrain.yNN=NNmat.yNN_train;
        outTest.yNN=NNmat.yNN_test;
    else
        if exist(netFile,'file')
            load(netFile);
            disp('loading existing NN')
            [yNN_train,net] = regSMAP_NN(xTrain,yTrain,net);
        else
            [yNN_train,net] = regSMAP_NN(xTrain,yTrain);
        end
        [yNN_test,net2] = regSMAP_NN(xTest,yTest,net);
        outTrain.yNN=yNN_train;
        outTest.yNN=yNN_test;
        save(NNFile,'yNN_train','yNN_test');
        save(netFile,'net');
    end
    covMethod=[covMethod,'NN'];
    toc
    
    %% NN solo
    if sameRegion
        disp('calculate/load NN solo')
        tic
        NNpbpFile=[outFolder,'outNNpbp_',trainName,'_',testName,'.mat'];
        if exist(NNpbpFile,'file')
            NNpbpmat=load(NNpbpFile);
            outTrain.yNNpbp=NNpbpmat.yNNpbp_train;
            outTest.yNNpbp=NNpbpmat.yNNpbp_test;
        else
            [yNNpbp_train,netLst] = regSMAP_NN_solo(xTrain,yTrain);
            [yNNpbp_test,netLst2] = regSMAP_NN_solo(xTest,yTest,netLst);
            outTrain.yNNpbp=yNNpbp_train;
            outTest.yNNpbp=yNNpbp_test;
            save(NNpbpFile,'yNNpbp_train','yNNpbp_test');
        end
        covMethod=[covMethod,'NNpbp'];
        toc
    end
end



