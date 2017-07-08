global kPath
outFolder=[kPath.OutSMAP_L3,'CONUSs4f1_CONUSs4f3',kPath.s];
trainName='CONUSs4f1';
testName='CONUSs4f3';
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch,'timeOpt',3)

global kPath
outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;
testRnnSMAP_plot(outName,trainName,testName,epoch,'timeOpt',1)

outFolder=[kPath.OutSMAP_L3,'CONUSs4f1',kPath.s];
trainName='CONUSs4f1';
testName='CONUSs4f1';
shapefile=[];
stat='rmse';% or rmse, rsq, bias
colorRange=[0,0.1];
opt=1; %0->all; 1->train; 2->test
epoch=500;
testRnnSMAP_map(outFolder,trainName,testName,epoch,...
    'shapefile',shapefile,'stat',stat,'opt',opt,'colorRange',colorRange);


%% rescan dataset
scanDatabase('CONUS');
sLst=[2,2,4,4,16,16];
fLst=[1,2,1,3,1,9];
for k=1:length(sLst)
    ss=sLst(k);
    ff=fLst(k);
    dbName=['CONUSs',num2str(ss),'f',num2str(ff)];
    scanDatabase(dbName);
end

%%
k=1;
plot(outTrain.yLSTM(:,k),'-b');hold on
plot(outTrain.ySMAP(:,k),'-r');hold on
