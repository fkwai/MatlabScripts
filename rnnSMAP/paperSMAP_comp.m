
global kPath
outName='CONUSs4f1_new';
trainName='CONUSs4f1';
testNameT='CONUSs4f1';
testNameS='CONUSs4f2';
epoch=500;

figFolder='H:\Kuai\rnnSMAP\paper\';
opt=2;
stat='rmse';
unitStr='[-]';
suffix = '.jpg';

%% read Data
[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch);
[outTrainS,outS,covS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,'timeOpt',3);

statTrain_LSTM=statCal(outTrainT.yLSTM,outTrain.ySMAP);
statT_LSTM=statCal(outT.yLSTM,outT.ySMAP);
statS_LSTM=statCal(outS.yLSTM,outS.ySMAP);

statTrain_NLDAS=statCal(outTrainT.yGLDAS,outTrain.ySMAP);
statT_NLDAS=statCal(outT.yGLDAS,outT.ySMAP);
statS_NLDAS=statCal(outS.yGLDAS,outS.ySMAP);

statTrain_LR=statCal(outTrainT.yLR,outTrain.ySMAP);
statT_LR=statCal(outT.yLR,outT.ySMAP);
statS_LR=statCal(outS.yLR,outS.ySMAP);

statTrain_NN=statCal(outTrainT.yNN,outTrain.ySMAP);
statT_NN=statCal(outT.yNN,outT.ySMAP);
statS_NN=statCal(outS.yNN,outS.ySMAP);

statTrain_LRpbp=statCal(outTrainT.yLRpbp,outTrain.ySMAP);
statT_LRpbp=statCal(outT.yLRpbp,outT.ySMAP);

statTrain_NNpbp=statCal(outTrainT.yNNpbp,outTrain.ySMAP);
statT_NNpbp=statCal(outT.yNNpbp,outT.ySMAP);

nTrain=length(statTrain_LSTM.(stat));
nT=length(statT_LSTM.(stat));
nS=length(statS_LSTM.(stat));

lab1=[repmat(1,[nTrain,1]);repmat(1,[nT,1]);repmat(1,[nS,1])];
lab2=[repmat(1,[nTrain,1]);repmat(1,[nT,1]);repmat(1,[nS,1])];
plotData=[cat(1,statTrain_LSTM.(stat),statT_LSTM.(stat),statS_LSTM.(stat)),...
    cat(1,statTrain_NLDAS.(stat),statT_NLDAS.(stat),statS_NLDAS.(stat))];

boxplot(plotData, [lab,lab] ,'factorgap',10,'color','rk')




