function [outTrain,outTest]=testRnnSMAP_NNlag(outName,trainName,testName)
% optSMAP: 1 -> real; 2 -> anomaly
% optGLDAS: 1 -> real; 2 -> anomaly; 0 -> no soilM

global kPath
outFolder=[kPath.OutSMAP_L3,outName,kPath.s];
mkdir(outFolder)


tTrain=1:366;
tTest=367:732;

[xOut,yOut,xStat,yStat] = readDatabaseSMAP_All( testName );

%% x to xLag
lag=5;
[nt,ngrid,nVar]=size(xOut);
ntTrain=length(tTrain);
ntTest=length(tTest);

xTrainLag=zeros([ntTrain-lag,ngrid,nVar*lag])*nan;
xTestLag=zeros([ntTest,ngrid,nVar*lag])*nan;
yTrainLag=yOut(tTrain+lag-1,:);
yTestLag=yOut(tTest,:);

for k=1:lag
    xTrainLag(:,:,(k-1)*nVar+1:k*nVar)=xOut(k:tTrain(end)-lag-1+k,:,:);
    xTestLag(:,:,(k-1)*nVar+1:k*nVar)=xOut(tTest(1)-k+1:tTest(end)-k+1,:,:);     
end


%% NN
disp('calculate/load NN')
tic
NNlagFile=[outFolder,'outNNlag_',trainName,'_',testName,'.mat'];
netlagFile=[outFolder,'netlag_',trainName,'_',testName,'.mat'];
if exist(NNlagFile,'file')
    NNlagmat=load(NNlagFile);
    outTrain.yNNlag=NNlagmat.yNNlag_train;
    outTest.yNNlag=NNlagmat.yNNlag_test;
else
    [yNN_train,net] = regSMAP_NN(xTrainLag,yTrainLag);
    [yNN_test,net2] = regSMAP_NN(xTestLag,yTestLag,net);
    outTrain.yNN=yNN_train;
    outTest.yNN=yNN_test;
    save(NNlagFile,'yNNlag_train','yNNlag_test');
    save(netlagFile,'net');
end
toc

end




