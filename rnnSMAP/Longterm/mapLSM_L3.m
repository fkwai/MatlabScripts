
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

%% calculate stat
stat1=statCal(LSTM1.v,Noah1.v);
stat2=statCal(LSTM2.v,Noah2.v);
stat3=statCal(SMAP.v,Noah2.v);
stat4=statCal(LSTM2.v,SMAP.v);
statAll=[stat1;stat2;stat3;stat4];

%% plot maps
statLst={'rmse','rsq'};
statStrLst={'RMSE','Correlation'};
statRangeLst=[0,0.15;0,1];
strLst1={'(LSTM, Noah)','(LSTM, Noah)','(SMAP, Noah)','(LSTM, SMAP)'};
strLst2={'Hindcast','Training','Training','Training'};
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/hindcastMap/L3/';
shapefile=[];

figure('Position',[1,1,2000,1000])
kk=0;
for k=1:length(statLst)
    stat=statLst{k};
    for j=[1,3]
        kk=kk+1;
        subplot(2,2,kk)
        plotData=statAll(j).(stat);
        [gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
        %gridStat(1,:)=nan;
        titleStr=[strLst2{j},' ',statStrLst{k},strLst1{j}];
        colorRange=statRangeLst(k,:);
        imagesc(gridStat,colorRange);
        colorbar;
        title(titleStr)
        %     [h,cmap]=showMap(gridStat,yy,xx,'newFig',0,'colorRange',colorRange,...
        %         'nLevel',8,'shapefile',shapefile,'title',titleStr);
        %     colormap(cmap)
        %     fname=[figFolder,'fig_biasMap_LSTM'];
        %     fixFigure([],[fname,suffix]);
        %     saveas(gcf, fname);
    end
    fname=[figFolder,'mapNoah'];
    saveas(gcf, fname);
end













