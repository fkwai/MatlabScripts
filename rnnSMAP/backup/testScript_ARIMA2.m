
outFolder='Y:\Kuai\rnnSMAP\output\test\';
trainName='indTest';
[xData,ySMAP,xStat,yStat]=readDatabaseSMAP(outFolder,trainName);

yARIMA=regSMAP_ARIMA_solo(xData,ySMAP);
yLR=regSMAP_LR_solo(xData,ySMAP);


nt=4160;
nTrain=2209;
plot(1:nt,ySMAP,'or');hold on
plot(1:nt,yARIMA,'-g');hold on
plot(1:nt,yLR,'-b');hold off

statARIMA=statCal(yARIMA(1:nTrain),ySMAP(1:nTrain))
statLR=statCal(yLR(1:nTrain),ySMAP(1:nTrain))


% yARIMA=regSMAP_ARIMA_solo(xData(:,:,2:end),xData(:,:,1));
% yLR=regSMAP_LR_solo(xData(:,:,2:end),xData(:,:,1));
plot(1:nt,xData(:,:,1),'or');hold on
plot(1:nt,yARIMA,'-g');hold on
plot(1:nt,yLR,'-b');hold off

% statARIMA=statCal(yARIMA(1:nTrain),xData(1:nTrain,:,1))
% statLR=statCal(yLR(1:nTrain),xData(1:nTrain,:,1))
