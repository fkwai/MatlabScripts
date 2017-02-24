% this one works for several special cases.

folder='Y:\Kuai\rnnSMAP\output\trainNA4\';
trainNameList={'region1','region1','region1','region2','region2','region2'};
testName='train';
%iterList=[8000,11000,12000,8000,16000,18000];
iterList=[9,12,16,10,14,19]*1000;
nTrain=2209;


figfolder=[folder,'fig_comb\'];
if ~isdir(figfolder)
    mkdir(figfolder)
end
testFile=[folder,testName,'.csv'];
testInd=csvread(testFile);

%% read data and save a matfile
% for k=1:length(iterList)
%     k
%     tic
%     iter=iterList(k);
%     trainName=trainNameList{k};
%     outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
%     outfolderInfo=dir([outfolder,'*.csv']);
%     
%     data=[];
%     ind=0;
%     for i=1:length(outfolderInfo)
%         % verify file order
%         indtemp=str2num(outfolderInfo(i).name(1:6));
%         if indtemp<ind
%             error('file not in order');
%         end
%         ind=indtemp;
%         
%         M=csvread([outfolder,outfolderInfo(i).name]);
%         data=[data,M];
%     end
%     data=data(:,1:length(testInd));
%     save([outfolder,'data.mat'],'data');
%     toc
% end

%% start
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
load('Y:\GLDAS\maskGLDAS_025.mat');
tnum=grid.tnum;
mask1d=mask(:);
indMask=find(mask1d==1);
[xx,yy]=meshgrid(grid.lon,grid.lat);
testIndMask=indMask(testInd);
testX=xx(testIndMask);
testY=yy(testIndMask);
testLon=unique(testX);
testLat=flipud(unique(testY));
cellsize=min(min(testLon(2:end)-testLon(1:end-1)),min(testLat(1:end-1)-testLat(2:end)));
lon=min(testLon):cellsize:max(testLon);
lat=max(testLat):-cellsize:min(testLat);

%% read obs and soilM
yfolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
ysfolder='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
nt=4160;
ySMAP=zeros(nt,length(testInd));
for i=1:length(testIndMask)
    yfile=[yfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
    ySMAP(:,i)=csvread(yfile);
end
ySMAP(ySMAP==-9999)=nan;
temp=csvread([yfolder,'stat.csv']);
lb=temp(1);ub=temp(2);

%GLDAS
yGLDAS=zeros(4160,length(testInd));
for i=1:length(testIndMask)
    yfile=[ysfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
    yGLDAS(:,i)=csvread(yfile);
end
yGLDAS(yGLDAS==-9999)=nan;
yGLDAS=yGLDAS/100;
nashGLDAS=1-nansum((yGLDAS-ySMAP).^2)./nansum((ySMAP-repmat(nanmean(ySMAP),[nt,1])).^2);
nashGLDAS=nashGLDAS';
rsqGLDAS=zeros(length(testInd),1);
for j=1:length(testInd)
    r2=RsqCalculate(ySMAP(:,j),yGLDAS(:,j));
    rsqGLDAS(j)=r2;
end
biasGLDAS=nanmean(yGLDAS-ySMAP)';
rmseGLDAS=sqrt(nanmean((yGLDAS-ySMAP).^2))';

%linear regression
load('Y:\Kuai\rnnSMAP\output\trainNA4\out_linear.mat')
nModel=size(yLR,3);
nashLR=zeros(length(testInd),nModel)*nan;
rsqLR=zeros(length(testInd),nModel)*nan;
biasLR=zeros(length(testInd),nModel)*nan;
for k=1:nModel
    nashLRtemp=1-nansum((yLR(:,:,k)-ySMAP).^2)./nansum((ySMAP-repmat(nanmean(ySMAP),[nt,1])).^2);
    nashLRtemp=nashLRtemp';
    rsqLRtemp=zeros(length(testInd),1);
    for j=1:length(testInd)
        r2=RsqCalculate(ySMAP(:,j),yLR(:,j,k));
        rsqLRtemp(j)=r2;
    end
    biasLRtemp=nanmean(yLR(:,:,k)-ySMAP)';
    rmseLRtemp=sqrt(nanmean((yLR(:,:,k)-ySMAP).^2))';
    nashLR(:,k)=nashLRtemp;
    rsqLR(:,k)=rsqLRtemp;
    biasLR(:,k)=biasLRtemp;
    rmseLR(:,k)=rmseLRtemp;
end

%% calculate nash for LSTM
yLSTM=zeros(4160,length(testInd),length(iterList))*nan;
nashLSTM=zeros(length(testInd),length(iterList))*nan;
rsqLSTM=zeros(length(testInd),length(iterList))*nan;
biasLSTM=zeros(length(testInd),length(iterList))*nan;

for i=1:length(iterList);
    i
    iter=iterList(i);
    trainName=trainNameList{i};
    outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
    load([outfolder,'data.mat']);
    yp=data;
    yp=(yp+1).*(ub-lb)./2+lb;
    nash=1-nansum((yp-ySMAP).^2)./nansum((ySMAP-repmat(nanmean(ySMAP),[nt,1])).^2);
    bias=nanmean(yp-ySMAP);
    rmse=sqrt(nanmean((yp-ySMAP).^2))';
    tempRsq=zeros(length(testInd),1);
    for j=1:length(testInd)
        r2=RsqCalculate(ySMAP(:,j),yp(:,j));
        tempRsq(j)=r2;
    end    
    yLSTM(:,:,i)=yp;
    nashLSTM(:,i)=nash;
    rsqLSTM(:,i)=tempRsq;
    biasLSTM(:,i)=bias;
    rmseLSTM(:,i)=rmse;
end

saveFile=[folder,'Stat_comb.mat'];
save(saveFile,'nashGLDAS','rsqGLDAS','biasGLDAS','rmseGLDAS',...
    'nashLR','rsqLR','biasLR','rmseLR',...
    'nashLSTM','rsqLSTM','biasLSTM','rmseLSTM')

%% plot map
saveFile=[folder,'Stat_comb.mat'];
load(saveFile)

nashMap=zeros(length(lat),length(lon),length(iterList))*nan;
rsqMap=zeros(length(lat),length(lon),length(iterList))*nan;
nashMap_ys=zeros(length(lat),length(lon))*nan;
rsqMap_ys=zeros(length(lat),length(lon))*nan;

for k=1:length(iterList)
    for i=1:length(testInd)
        indX=find(lon==testX(i));
        indY=find(lat==testY(i));
        nashMap(indY,indX,k)=nashLSTM(i,k);
        rsqMap(indY,indX,k)=rsqLSTM(i,k);
        biasMap(indY,indX,k)=biasLSTM(i,k);
    end
end
for i=1:length(testInd)
    indX=find(lon==testX(i));
    indY=find(lat==testY(i));
    nashMapGLDAS(indY,indX)=nashGLDAS(i);
    rsqMapGLDAS(indY,indX)=rsqGLDAS(i);
    biasMapGLDAS(indY,indX)=biasGLDAS(i);
end

shapefile='Y:\Maps\USA.shp';
lonLim=[-140,-60];
nashrange=[-2,0.6];
rsqrange=[-2,0.6];

for k=1:length(iterList)
    titlestr=['Nash iter ',num2str(iterList(k))];
    f=showGlobalMap(nashMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',nashrange,'lonLim',lonLim,'newFig',0,'title',titlestr);
    saveas(f,[figfolder,'\nashMap',num2str(k),'.fig'])
    titlestr=['Rsq iter ',num2str(iterList(k))];
    f=showGlobalMap(rsqMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',rsqrange,'lonLim',lonLim,'newFig',0,'title',titlestr);
    saveas(f,[figfolder,'\rsqMap',num2str(k),'.fig'])
    close all
end

%% plot a best nash map
% nashMapSel=zeros(length(lat),length(lon),3)*nan;
% nashMapSel(:,:,1)=nashMap(:,:,2);
% nashMapSel(:,:,2)=nashMap(:,:,4);
% nashMapSel(:,:,3)=nashMap(:,:,6);
[nashMapBest,nashBestModel]=max(nashMap,[],3);
[rsqMapBest,rsqBestModel]=max(rsqMap,[],3);

f=showGlobalMap(nashMapBest,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','Best Nash');
saveas(f,[figfolder,'\nashMap_comb.fig'])
f=showGlobalMap(rsqMapBest,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Nash - GLDAS Nash');
saveas(f,[figfolder,'\rsqMap_comb.fig'])
f=showGlobalMap(nashMapBest-nashMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','Best Rsq');
saveas(f,[figfolder,'\nashMap_comb_comp.fig'])
f=showGlobalMap(rsqMapBest-rsqMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Rsq - GLDAS Rsq');
saveas(f,[figfolder,'\rsqMap_comb_comp.fig'])
close all

tempMap=rsqMapBest-rsqMap_ys;
tempMap(tempMap<0)=-1;
tempMap(tempMap>0)=1;
f=showGlobalMap(tempMap,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Rsq - GLDAS Rsq');

%% plot LSTM vs GLDAS
% nashSel=zeros(length(testInd),3)*nan;
% nashSel(:,1)=nashAll(:,2);
% nashSel(:,2)=nashAll(:,4);
% nashSel(:,3)=nashAll(:,6);
f=figure('Position',[100,100,800,600])
[nashBest,bestModel]=max(nashLSTM,[],2);
[nashBestLR,bestModel]=max(nashLR,[],2);
plot(nashGLDAS,nashBest,'*');hold on
plot(nashGLDAS,nashBestLR,'r.');hold on
plotRange=[-10,1];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM Nash vs GLDAS Nash')
xlabel('GLDAS')
ylabel('Prediction')
legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\nashComp.fig'])
hold off

f=figure('Position',[100,100,800,600])
[nashBest,bestModel]=max(nashLSTM,[],2);
[nashBestLR,bestModel]=max(nashLR,[],2);
plot(nashBest,nashBestLR,'*');hold on
plotRange=[-10,1];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM Nash vs Linear Reg Nash')
xlabel('LSTM')
ylabel('Linear Reg')
%legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\nashComp2.fig'])
hold off

f=figure('Position',[100,100,800,600])
[rsqBest,bestModel]=max(rsqLSTM,[],2);
[rsqBestLR,bestModel]=max(rsqLR,[],2);
plot(rsqGLDAS,rsqBest,'*');hold on
plot(rsqGLDAS,rsqBestLR,'r.');hold on
plotRange=[0,1];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM R^2 vs GLDAS R^2')
xlabel('GLDAS')
ylabel('Prediction')
legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\rsqComp.fig'])
hold off

f=figure('Position',[100,100,800,600])
[biasBestAbs,bestModel]=min(abs(biasLSTM),[],2);
biasBest=biasBestAbs.*nan;
for i=1:length(biasBestAbs)
    biasBest(i)=biasLSTM(i,bestModel(i));
end
[biasBestAbsLR,bestModelLR]=min(abs(biasLR),[],2);
biasBestLR=biasBestAbsLR.*nan;
for i=1:length(biasBestAbsLR)
    biasBestLR(i)=biasLR(i,bestModelLR(i));
end
plot(biasGLDAS,biasBest,'*');hold on
plot(biasGLDAS,biasBestLR,'r.');hold on
plotRange=[-0.3,0.3];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM bias vs GLDAS bias')
xlabel('GLDAS')
ylabel('Prediction')
legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\biasComp.fig'])
hold off

f=figure('Position',[100,100,800,600])
[biasBestAbs,bestModel]=min(abs(biasLSTM),[],2);
[biasBestAbsLR,bestModelLR]=min(abs(biasLR),[],2);
plot(biasGLDAS,biasBestAbs,'*');hold on
plot(biasGLDAS,biasBestAbsLR,'r.');hold on
plotRange=[-0.3,0.3];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM bias vs GLDAS bias')
xlabel('GLDAS')
ylabel('Prediction')
legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\biasAbsComp.fig'])
hold off

f=figure('Position',[100,100,800,600])
[rmseBest,bestModel]=min(rmseLSTM,[],2);
[rmseBestLR,bestModel]=min(rmseLR,[],2);
plot(rmseGLDAS,rmseBest,'*');hold on
plot(rmseGLDAS,rmseBestLR,'r.');hold on
plotRange=[0,0.4];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM rmse vs GLDAS rmse')
xlabel('GLDAS')
ylabel('Prediction')
legend('LSTM','Linear Reg','Location','northeastoutside')
fixFigure()
savefig([figfolder,'\rmseComp.fig'])
hold off

f=figure('Position',[100,100,800,600])
[rmseBest,bestModel]=min(rmseLSTM,[],2);
[rmseBestLR,bestModel]=min(rmseLR,[],2);
plot(rmseBest,rmseBestLR,'*');hold on
plotRange=[0,0.3];
axis equal
xlim(plotRange)
ylim(plotRange)
plot121Line
title('LSTM rmse vs Linear Reg rmse')
xlabel('LSTM')
ylabel('Linear Reg')
fixFigure()
savefig([figfolder,'\rmseComp2.fig'])
hold off

%% plot map only on USA and north Mexico
shapefile='Y:\Maps\USA_Mexico\USA_Mexico.shp';
shape=shaperead(shapefile);

output1 = GridinShp(shape(1),lon,lat,0.75,1);
output2 = GridinShp(shape(2),lon,lat,0.75,1);
locMap=output1+output2;
indX=find(lon<-126);
indY=find(lat<21.875);
locMap(:,indX)=0;
locMap(indY,:)=0;
locMap(locMap==0)=nan;

loc=zeros(length(testInd),1);
for i=1:length(testInd)
    indX=find(lon==testX(i));    
    indY=find(lat==testY(i));
    if locMap(indY,indX)==1
        loc(i)=1;
    end
end
save loc.mat loc locMap

[nashMapBest,nashBestModel]=max(nashMap,[],3);

shapefile='Y:\Maps\USA.shp';
lonLim=[-125,-65];
latLim=[21,50];
nashrange=[-1,0.75];
% showGlobalMap(nashMapBest.*locMap,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',nashrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,...
%     'title','Best Nash','figSize',[100,100,800,600],'savename',[figfolder,'\nashMap_comb']);
showGlobalMap(nashMapBest.*locMap,lon,lat,cellsize,'shapefile',shapefile,...
    'color',nashrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,...
    'title','Best Nash');

%% find points on bad-performance areas
hold(gca,'on')
indLst=[2957,2596,636];
plot(testX(indLst),testY(indLst),'*r')
gridInd=testInd(indLst);

for k=1:3
    subplot(3,1,k)
    [nashBest,bestModel]=max(nashLSTM(indLst(k),:),[],2);
    plot(tnum,yLSTM(:,indLst(k),bestModel),'-b');hold on
    plot(tnum,ySMAP(:,indLst(k)),'ro');hold on
    plot(tnum,yGLDAS(:,indLst(k)),'-k');hold on
    legend('LSTM','SMAP','GLDAS')
    title(['grid:',num2str(gridInd(k))])
    datetick('x','mm');
end
hold off 

