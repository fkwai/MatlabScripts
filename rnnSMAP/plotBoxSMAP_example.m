
global kPath
outName='CONUSv4f1';
trainName='CONUSv4f1';
testNameT='CONUSv4f1';
modelName='Noah';
epoch=500;

[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,...
    'readData',0,'model',modelName);

statTtrain_LSTM=statCal(outTrainT.yLSTM,outTrainT.ySMAP);
statT_LSTM=statCal(outT.yLSTM,outT.ySMAP);
statTtrain_NLDAS=statCal(outTrainT.yGLDAS,outTrainT.ySMAP);
statT_NLDAS=statCal(outT.yGLDAS,outT.ySMAP);
statTtrain_LR=statCal(outTrainT.yLR,outTrainT.ySMAP);
statT_LR=statCal(outT.yLR,outT.ySMAP);
statTtrain_NN=statCal(outTrainT.yNN,outTrainT.ySMAP);
statT_NN=statCal(outT.yNN,outT.ySMAP);
statTtrain_LRpbp=statCal(outTrainT.yLRpbp,outTrainT.ySMAP);
statT_LRpbp=statCal(outT.yLRpbp,outT.ySMAP);
statTtrain_NNpbp=statCal(outTrainT.yNNpbp,outTrainT.ySMAP);
statT_NNpbp=statCal(outT.yNNpbp,outT.ySMAP);

% ARMA 
matARMA=load('H:\Kuai\rnnSMAP\ARMA\q0N\yARMApbp_CONUSv4f1.mat');
statTtrain_ARMA=statCal(matARMA.yARMA(1:366,:),outTrainT.ySMAP);
statT_ARMA=statCal(matARMA.yARMA(367:732,:),outT.ySMAP);

%% statMat
stat='rmse';
statMat={statTtrain_LSTM.(stat),statT_LSTM.(stat);...
    statTtrain_NLDAS.(stat),statT_NLDAS.(stat);...
    statTtrain_LR.(stat),statT_LR.(stat);...
    statTtrain_NN.(stat),statT_NN.(stat);...
    statTtrain_LRpbp.(stat),statT_LRpbp.(stat);...
    statTtrain_NNpbp.(stat),statT_NNpbp.(stat);...
    statTtrain_ARMA.(stat),statT_ARMA.(stat)};
labelX={'Train','Test'};
labelY={'LSTM','NLDAS','LR','NN','LRpbp','NNpbp','ARMA'};

 f=plotBoxSMAP( statMat,labelX,labelY)




