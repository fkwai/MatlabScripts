global kPath
outFolder='regionCase1_noModel';
trainName='regionACDs2';
testName='regionBs2';
epoch=500;
testRnnSMAP_plot(outFolder,trainName,testName,epoch,'timeOpt',2)


global kPath
outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f3';
epoch=500;
testRnnSMAP_plot(outName,trainName,testName,epoch,'timeOpt',3)

global kPath
outName='CONUSs2f1';
trainName='CONUSs2f1';
testName='CONUSs2f1';
epoch=300;
testRnnSMAP_plot(outName,trainName,testName,epoch,'timeOpt',1,'readCov',0)

outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f1';
shapefile=[];
stat='rmse';% or rmse, rsq, bias
colorRange=[0,0.1];
opt=2; %0->all; 1->train; 2->test
epoch=500;
testRnnSMAP_map(outName,trainName,testName,epoch,...
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
sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};

splitSubset('regionACD','shape',sLstACD)
splitSubset('regionBCD','shape',sLstBCD)
splitSubset('regionA','shape',sLstA)
splitSubset('regionB','shape',sLstB)