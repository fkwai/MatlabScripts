
global kPath
dataNameCONUS='CONUSv4f1';
epoch=300;
timeOpt=1;
rootDB=kPath.DBSMAP_L3;
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/Autoencoder/';

% dataNameHUC='huc2_02030406';
% outName='huc2_02030406';
% outName_Self='huc2_02030406';
% saveName='02030406';
% hucLst=[2,3,4,6];

dataNameHUC='huc2_04051118';
outName='huc2_04051118';
outName_Self='huc2_04051118';
saveName='04051118';
hucLst=[4,5,11,18];

%% load data
yLSTM= readRnnPred(outName,dataNameCONUS,epoch,timeOpt);
[ySMAP,~,~] = readDB_SMAP(dataNameCONUS,'SMAP');
tnum=csvread([rootDB,dataNameCONUS,filesep,'time.csv']);

if timeOpt==1
    ySMAP=ySMAP(1:366,:);
    tnum=tnum(1:366,:);
elseif timeOpt==2
    ySMAP=ySMAP(367:732,:);
    tnum=tnum(367:732,:);
elseif timeOpt==3
    ySMAP=ySMAP(1:732,:);
    tnum=tnum(1:732,:);
end

crdHUC=csvread([rootDB,dataNameHUC,filesep,'crd.csv']);
crdCONUS=csvread([rootDB,dataNameCONUS,filesep,'crd.csv']);
[ind1,ind2]=intersectCrd(crdHUC,crdCONUS);
indCONUS=[1:length(crdCONUS)]';
indCONUS(ind2)=[];

%% load autoencoder
[~,output]=readSelfPred(outName_Self,dataNameCONUS,'epoch',300);
[input,outputBatch]=readSelfPred(outName_Self,dataNameCONUS,'epoch',300,'drMode',100);
statSelf=statAutoEncoder(input,output);
statSelfBatch=statAutoEncoder(input,outputBatch);

%% plot 121
f=figure('Position',[1,1,1000,800]);
statMat=statCal(yLSTM,ySMAP);
statLst_SMAP={'rmse','ubrmse'};
statLst_Self={'rmse','std'};

for j=1:length(statLst_SMAP)
    for i=1:length(statLst_Self)        
        a=statSelfBatch.(statLst_Self{j})(indCONUS);
        b=statMat.(statLst_SMAP{i})(indCONUS);
        
        subplot(2,2,(j-1)*2+i)
        plot(a,b,'b*')
        h=lsline;
        set(h(1),'color','r','LineWidth',2)
        xlabel(['Autoencoder ',statLst_Self{i}])
        ylabel(['LSTM ',statLst_SMAP{j}])
        ind=~isnan(a)&~isnan(b);
        rho=corr(a(ind),b(ind));
        title([saveName,' R=',num2str(rho,'%.2f')],'interpreter','none')
    end
end
fixFigure(f)
saveas(f,[figFolder,saveName,'_stat','.fig'])
saveas(f,[figFolder,saveName,'_stat','.jpg'])

%% plot map
[gridStat,xx,yy] = data2grid(statMat.rmse,crdCONUS(:,2),crdCONUS(:,1));
[gridLSTM,~,~] = data2grid3d(yLSTM',crdCONUS(:,2),crdCONUS(:,1));
[gridSMAP,~,~] = data2grid3d(ySMAP',crdCONUS(:,2),crdCONUS(:,1));
[gridSelf,~,~] = data2grid3d(ySelf',crdCONUS(:,2),crdCONUS(:,1));

shapeAll=shaperead('/mnt/sdb1/Kuai/map/HUC/HUC2_CONUS.shp');
shape=shapeAll(hucLst);
clear tsStr
tsStr(1)=struct('grid',gridLSTM,'t',tnum,'symb','-b','legendStr','LSTM','yRight',0);
tsStr(2)=struct('grid',gridSMAP,'t',tnum,'symb','ko','legendStr','SMAP','yRight',0);
tsStr(3)=struct('grid',gridSelf,'t',tnum,'symb','-r','legendStr','Self','yRight',1);
[f,cmap]=showMap(gridStat,yy,xx,'tsStr',tsStr,'latLim',[25,50],'lonLim',[-125,-65],'shape',shape);