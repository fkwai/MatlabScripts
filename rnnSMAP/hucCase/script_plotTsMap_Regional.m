
% load LSTM prediction from local model with/without model, CONUS model
% with/without model, and plot ts map.

nHuc=4;
hucIdStr='05071015';

%% load local model
rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHuc),filesep];
rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHuc),filesep];
if nHuc==4
    outName1=['huc2_',hucIdStr,'_hS256_VFvarLst_Noah'];
    outName2=['huc2_',hucIdStr,'_hS256_VFvarLst_NoModel'];
end
opt=readRnnOpt(outName1,rootOut);
timeOpt=2;
testName=opt.train;
out1=postRnnSMAP_load(outName1,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);
out2=postRnnSMAP_load(outName2,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);

%% load CONUS model
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
outName1='CONUSv2f1_Noah';
outName2='CONUSv2f1_NoModel';
testName='CONUSv2f1';
timeOpt=2;
outCONUS1=postRnnSMAP_load(outName1,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);
outCONUS2=postRnnSMAP_load(outName2,testName,timeOpt,'rootOut',rootOut,'rootDB',rootDB);

%% find index in CONUS model
crd=out1.crd;
crdCONUS=outCONUS1.crd;
[indHuc,indCONUS]=intersectCrd(crd,crdCONUS);

%% plot
%shapefile='/mnt/sdb1/Kuai/map/HUC/HUC2_CONUS.shp';
shapefile=[];
tnum=out1.tnum;
stat=statCal(out1.yLSTM,out1.ySMAP);
[statGrid,xx,yy]=data2grid(stat.rmse,crd(:,2),crd(:,1));
legLst={'SMAP','C-W','H-W'};
dataLst={out1.ySMAP,outCONUS1.yLSTM(:,indCONUS),out1.yLSTM};
symLst={'ok','-r','-b'};
tsStr=[];
for k=1:length(legLst)
    tsData=dataLst{k};
    [gridTemp,xx,yy] = data2grid3d(tsData',crd(:,2),crd(:,1));
    tsStr(k).grid=gridTemp;
    tsStr(k).t=tnum;
    tsStr(k).symb=symLst{k};
    tsStr(k).legendStr=legLst{k};
end
[f,cmap]=showMap(statGrid,yy,xx,'colorRange',[0,0.05],'tsStr',tsStr,'shapefile',shapefile);