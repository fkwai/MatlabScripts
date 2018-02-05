global kPath

%% read SMAP and LSTM
outName='fullCONUS_Noah2yr';
targetName='SMAP';
trainName='CONUS';
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
testLst={'LongTerm8595','LongTerm9505','LongTerm0515'};
 modelName='SOILM_0-10';


% outName='CONUSv4f1_rootzone';
% targetName='SMGP_rootzone';
% trainName='CONUSv4f1';
% rootOut=kPath.OutSMAP_L4;
% rootDB=kPath.DBSMAP_L4;
% testLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1'};
% modelName='SOILM_0-100';
% SMAP
tic
SMAP.v=readDatabaseSMAP(trainName,targetName,rootDB);
SMAP.t=csvread([rootDB,filesep,trainName,filesep,'time.csv']);
crd=csvread([rootDB,trainName,filesep,'crd.csv']);
toc
% LSTM
tic
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',targetName);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    end
end
LSTM2.v=readRnnPred(outName,trainName,500,0,'rootOut',rootOut,'rootDB',rootDB,'target',targetName);
LSTM2.t=csvread([kPath.DBSMAP_L3,filesep,trainName,filesep,'time.csv']);
toc

% Model
tic
Noah.v=[];
Noah.t=[];
for k=1:length(testLst)
    vTemp=readDatabaseSMAP(testLst{k},modelName,rootDB)./100;
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        Noah.v=[Noah.v;vTemp(2:end,:)];
        Noah.t=[Noah.t;tTemp(2:end,:)];
    end
end
Noah2.v=readDatabaseSMAP(trainName,modelName)./100;
Noah2.t=csvread([rootDB,filesep,trainName,filesep,'time.csv']);
toc


%% convert to weekly and monthly
sd=20050401;
ed=20150401;
indT=find(LSTM.t>=datenumMulti(sd,1)&LSTM.t<datenumMulti(ed,1));
dataD=LSTM.v(indT,:);
tD=LSTM.t(indT);
nGrid=size(dataD,2);
yrLst=unique(year(tD));
ny=length(yrLst)-1;

% monthly 
%{
tM=datenumMulti(unique(datenumMulti(tD,3)),1);
tMb=[tM;datenumMulti(20150401)];
dataM=zeros(length(tM),nGrid);
for k=1:length(tM)
    indTemp=tD>=tMb(k)&tD<tMb(k+1);
    temp=dataD(indTemp,:);
    dataM(k,:)=nanmean(temp,1);
end
%}

tW=[tD(1)+3:tD(end)-3]';
dataW_All=zeros(length(tW),nGrid,7);
for k=1:7
    dataW_All(:,:,k)=dataD(k:end-7+k,:);
end
dataW=nanmean(dataW_All,3);

%% convert to weekly - Noah
dataD_Noah=Noah.v(indT,:);
dataW_All=zeros(length(tW),nGrid,7);
for k=1:7
    dataW_All(:,:,k)=dataD_Noah(k:end-7+k,:);
end
dataW_Noah=nanmean(dataW_All,3);

%% calculate percentile 
dataMat=dataW;
dataMat_Noah=dataW_Noah;
dataT=tW;

nt=size(dataMat,1);
nGrid=size(dataMat,2);
outMat=zeros(nt,nGrid)*nan;
prcLst=[50,30,20,10,5,2];
tWindow=15;  %[t-tWindow, t+tWindow]

for iT=1:365    
    iT
    tic
    indT=iT:365:nt;
    indSd=iT-tWindow:365:nt-tWindow;
    indEd=iT+tWindow:365:nt+tWindow;
    indAll=[];
    for k=1:length(indSd)
        indAll=[indAll,indSd(k):indEd(k)];
    end
    indAll(indAll<1)=[];
    indAll(indAll>nt)=[];
    dataTemp=dataMat(indAll,:);
    outVec=zeros(length(indT),nGrid)*nan;
    dataVec=dataMat(indT,:);    
    for k=1:length(prcLst)
        prcVec=repmat(prctile(dataTemp,prcLst(k),1),[length(indT),1]);        
        outVec(dataVec<prcVec)=k;
    end
    outMat(indT,:)=outVec;
    toc
end


%% show on map
shapefile='/mnt/sdb1/Kuai/map/USA.shp';
[outGrid,xx,yy] = data2grid3d(outMat',crd(:,2),crd(:,1));

ind=find(dataT==datenumMulti(20121023));
showMap(outGrid(:,:,ind),yy,xx,'nLevel',length(prcLst),'shapefile',shapefile)

tsStr(1).grid=outGrid;
tsStr(1).t=dataT;
tsStr(1).symb='-*k';
tsStr(1).legendStr='prc level';
showMap(outGrid(:,:,ind),yy,xx,'nLevel',length(prcLst)-1,'tsStr',tsStr)


[dataGrid,x1,y1] = data2grid3d(dataMat',crd(:,2),crd(:,1));
tsStr(1).grid=dataGrid;
tsStr(1).t=dataT;
tsStr(1).symb='-*r';
tsStr(1).legendStr='LSTM';
[dataGrid_Noah,x2,y2] = data2grid3d(dataMat_Noah',crd(:,2),crd(:,1));
tsStr(2).grid=dataGrid_Noah./10;
tsStr(2).t=dataT;
tsStr(2).symb='-*b';
tsStr(2).legendStr='Noah';
[dataGrid_SMAP,x3,y3] = data2grid3d(SMAP.v(:,1:7635)',crd(:,2),crd(:,1));
tsStr(3).grid=dataGrid_SMAP;
tsStr(3).t=SMAP.t;
tsStr(3).symb='ko';
tsStr(3).legendStr='SMAP';
showMap(outGrid(:,:,1),yy,xx,'nLevel',length(prcLst)-1,'tsStr',tsStr)


