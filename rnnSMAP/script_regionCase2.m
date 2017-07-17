
%% plot
global kPath
Alphabet=char('A'+(1:26)-1)';
trainName='hucABHKs4';
outName1=trainName;
outName2=[trainName,'_oneModel'];
outName3=[trainName,'_noModel'];
epoch=500;
doPlot=0;

stat='bias';
switch stat
    case 'rmse'
        yRange=[0,0.1];
        yRangeModel=[0,0.2];
        yLabelStr='RMSE';
    case 'bias'
        yRange=[-0.05,0.05];
        yRangeModel=[-0.2,0.2];
        yLabelStr='Bias';
end

%%
nHUC=12;
for k=1:nHUC+1
        testName=['huc',Alphabet(k),'s2'];
        
        [outTrain1,out1,covMethod]=testRnnSMAP_readData(outName1,trainName,testName,epoch);
        [outTrain2,out2,covMethod]=testRnnSMAP_readData(outName1,trainName,testName,epoch);
        [outTrain3,out3,covMethod]=testRnnSMAP_readData(outName1,trainName,testName,epoch);
          
end
%% Sample Scripts - splitsubset shapefile
% sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
% sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};
% splitSubset('regionACDs2','shape',2,1,sLstACD)
% splitSubset('regionBCDs2','shape',2,1,sLstBCD)
% splitSubset('regionAs2','shape',2,1,sLstA)
% splitSubset('regionBs2','shape',2,1,sLstB)
%