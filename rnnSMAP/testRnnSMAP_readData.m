function [ySMAP,yLSTM,yGLDAS,yCov,covMethod]=testRnnSMAP_readData(outFolder,trainName,testName,iter,varargin)
% optSMAP: 1 -> real; 2 -> anomaly
% optGLDAS: 1 -> real; 2 -> anomaly; 0 -> no soilM

pnames={'optSMAP','optGLDAS','readCov'};
dflts={1,1,1};
[optSMAP,optGLDAS,readCov]=internal.stats.parseArgs(pnames, dflts, varargin{:});

if strcmp(testName,trainName)
    sameRegion=1;
else
    sameRegion=0;
end
dataLoaded=0;
covMethod={};
yCov={};
nt=520;
ntrain=276;

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
    if optSMAP==1
        yField='SMPq_Daily';
    elseif optSMAP==2
        yField='SMPq_Anomaly_Daily';
    end
    [xOut,yOut,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
        'yField',yField,'xField',[],'xField_const',[],'mode',0);
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
    if optSMAP==1
        yField='soilM_Daily';
    elseif optSMAP==2
        yField='soilM_Anomaly_Daily';
    end
    [xOut,yOut,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
        'yField',yField,'xField',[],'xField_const',[],'mode',0);
    yGLDAS=yOut;
    save(GLDASmatFile,'yGLDAS')
end
yGLDAS=yGLDAS/100;
toc

%% read LSTM data
disp('read Prediction')
tic
dataLSTM=readRnnPred(outFolder,trainName,testName,iter);
yLSTM=(dataLSTM+1)./2*(ubSMAP-lbSMAP)+lbSMAP;
toc

if readCov==1
    %% LR
    disp('calculate/load LR')
    tic
    LRFile=[outFolder,'outLR_',trainName,'_',testName,'.mat'];
    if exist(LRFile,'file')
        LRmat=load(LRFile);
        yLR=LRmat.yLR;
    else
        if dataLoaded==0
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,...
                'yField',optSMAP,'xField',optGLDAS,'mode',0);
            if ~sameRegion
                [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
                    'yField',optSMAP,'xField',optGLDAS,'mode',0);
            end
            dataLoaded=1;
        end
        [yLRNorm,b] = regSMAP_LR(xTrain,yTrain,ntrain);
        if ~sameRegion
            [yLRNorm,bTemp] = regSMAP_LR(xTest,yTest,ntrain,b);
        end
        yLR=yLRNorm;
        %yLR=(yLRNorm+1)./2*(ubSMAP-lbSMAP)+lbSMAP;
        save(LRFile,'yLR');
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
                [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,...
                    'yField',optSMAP,'xField',optGLDAS,'mode',0);
                dataLoaded=1;
            end
            yLRsoloNorm=regSMAP_LR_solo(xTrain,yTrain,ntrain);
            %yLRsolo=(yLRsoloNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
            yLRsolo=yLRsoloNorm;
            save(LRsoloFile,'yLRsolo');
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
            [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,...
                'yField',optSMAP,'xField',optGLDAS,'mode',0);
            if ~sameRegion
                [xTest,yTest,xStat,yStat]=readDatabaseSMAP(outFolder,testName,...
                    'yField',optSMAP,'xField',optGLDAS,'mode',0);
            end
            dataLoaded=1;
        end
        [yNNNorm,net] = regSMAP_nn(xTrain,yTrain,ntrain);
        if ~sameRegion
            [yNNNorm,netTemp] = regSMAP_nn(xTest,yTest,ntrain,net);
        end
        %yNN=(yNNNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
        yNN=yNNNorm;
        save(NNFile,'yNN');
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
                [xTrain,yTrain,xStat,yStat]=readDatabaseSMAP(outFolder,trainName,...
                    'yField',optSMAP,'xField',optGLDAS,'mode',0);
                dataLoaded=1;
            end
            yNNsoloNorm = regSMAP_nn_solo(xTrain,yTrain,ntrain);
            %yNNsolo=(yNNsoloNorm+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
            yNNsolo=yNNsoloNorm;
            save(NNsoloFile,'yNNsolo');
        end
        covMethod=[covMethod,'NNsolo'];
        yCov=[yCov,yNNsolo];
        toc
    end
end



