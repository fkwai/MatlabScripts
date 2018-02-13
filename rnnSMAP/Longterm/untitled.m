
global kPath

%% read SMAP and LSTM
outName='fullCONUS_Noah2yr';
targetName='SMAP';
modelName='LSOIL_0-10';
trainName='CONUS';
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
% SMAP
tic
SMAP.v=readDatabaseSMAP(trainName,targetName);
SMAP.t=csvread([rootDB,filesep,trainName,filesep,'time.csv']);
crd=csvread([rootDB,filesep,trainName,filesep,'crd.csv']);
toc
% LSTM
tic
testLst={'LongTerm8595','LongTerm9505','LongTerm0515'};
LSTM1.v=[];
LSTM1.t=[];
for k=1:length(testLst)
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',targetName);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM1.v=[LSTM1.v;vTemp(2:end,:)];
        LSTM1.t=[LSTM1.t;tTemp(2:end,:)];
    end
end
LSTM2.v=readRnnPred(outName,trainName,500,0,'rootOut',rootOut,'rootDB',rootDB,'target',targetName);
LSTM2.t=csvread([kPath.DBSMAP_L3,filesep,trainName,filesep,'time.csv']);
toc
% Model
tic
testLst={'LongTerm8595','LongTerm9505','LongTerm0515'};
Noah1.v=[];
Noah1.t=[];
for k=1:length(testLst)
    vTemp=readDatabaseSMAP(testLst{k},modelName)./100;
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        Noah1.v=[Noah1.v;vTemp(2:end,:)];
        Noah1.t=[Noah1.t;tTemp(2:end,:)];
    end
end
Noah2.v=readDatabaseSMAP(trainName,modelName)./100;
Noah2.t=csvread([rootDB,filesep,trainName,filesep,'time.csv']);
toc

%% plot figures
plotData=nanmean(SMAP.v);
[gridData,xx,yy] = data2grid(plotData',crd(:,2),crd(:,1));
titleStr='Average SMAP Soil Moisture';
[f,cmap]=showMap(gridData,yy,xx,'nLevel',10,'colorRange',[0,0.5],'openEnds',[0,1],'title',titleStr);

%% plot figures
stat=statCal(LSTM2.v,SMAP.v);
%plotData=stat.rmse;
plotData=nanmean(LSTM2.v);
[gridData,xx,yy] = data2grid(plotData',crd(:,2),crd(:,1));
titleStr='Average SMAP Soil Moisture';
[f,cmap]=showMap(gridData,yy,xx,'nLevel',10,'colorRange',[0,0.5],'openEnds',[0,1],'title',titleStr);
indLst=[1560 3793 5665]
figure(f)
geoshow(crd(indLst,1),crd(indLst,2),'DisplayType','point','MarkerEdgeColor','k',...
    'Marker','*','MarkerSize',12,'LineWidth',3)

tsStr=[];
[gridTemp,xx,yy] = data2grid3d(SMAP.v',crd(:,2),crd(:,1));
tsStr(1).grid=gridTemp;
tsStr(1).t=SMAP.t;
tsStr(1).symb='ko';
tsStr(1).legendStr='SMAP';
[gridTemp,xx,yy] = data2grid3d(LSTM2.v',crd(:,2),crd(:,1));
tsStr(2).grid=gridTemp;
tsStr(2).t=LSTM2.t;
tsStr(2).symb='r-';
tsStr(2).legendStr='LSTM';
[gridIndex,xx,yy] = data2grid([1:size(SMAP.v,2)]',crd(:,2),crd(:,1));
gridTitle=cell(size(gridIndex));
for j=1:size(gridTitle,1)
    for i=1:size(gridTitle,2)
        gridTitle{j,i}=['index ',num2str(gridIndex(j,i))];
    end
end
[f,cmap]=showMap(gridData,yy,xx,'nLevel',10,'colorRange',[0,0.5],'openEnds',[0,1],'title',titleStr,'tsStr',tsStr,'tsTitleGrid',gridTitle);

indLst=[1560 3793 5665]
figure('Position',[100,100,1200,900]);
indT=find(LSTM1.t==datenumMulti(20100401));
for k=1:length(indLst)
    ind=indLst(k)
    subplot(3,1,k)
    plot(SMAP.t,SMAP.v(:,ind),'ok','LineWidth',2);hold on
    plot(LSTM2.t,LSTM2.v(:,ind),'-r','LineWidth',2);hold on
    plot(LSTM1.t(indT:end),LSTM1.v(indT:end,ind),'-b','LineWidth',2);hold on
    title(['pixel at [',num2str(crd(ind,2),'%.2f'),',',num2str(crd(ind,1),'%.2f'),']'])
    if k==1
        legend('SMAP','LSTM','Hindcast','Orientation','horizontal')
    end
    %ylim([0,0.5])
    hold off
    fixFigure()
    datetick('x','yyyy');
    %xlim([SMAP.t(1),SMAP.t(end)])
    xlim([LSTM1.t(indT),SMAP.t(end)])
end






