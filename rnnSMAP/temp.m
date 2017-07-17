global kPath
outFolder='regionCase1_noModel';
trainName='regionACDs2';
testName='regionBs2';
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch,'timeOpt',2)


global kPath
outName='CONUSs4f1_new';
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;
testRnnSMAP_plot(outName,trainName,testName,epoch,'timeOpt',1)

global kPath
outName='CONUSs2f1';
trainName='CONUSs2f1';
testName='CONUSs2f1';
epoch=300;
testRnnSMAP_plot(outName,trainName,testName,epoch,'timeOpt',1,'readCov',0)


outName='CONUSs4f1_new';
trainName='CONUSs4f1';
testName='CONUSs4f1';
stat='rmse';% or rmse, rsq, bias
epoch=500;
testRnnSMAP_map(outName,trainName,testName,epoch,'timeOpt',1,'opt',2)


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
sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};

splitSubset('regionACDs2','shape',2,1,sLstACD)
splitSubset('regionBCDs2','shape',2,1,sLstBCD)
splitSubset('regionAs2','shape',2,1,sLstA)
splitSubset('regionBs2','shape',2,1,sLstB)