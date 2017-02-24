% this one works for several special cases.

folder='Y:\Kuai\rnnSMAP\output\trainNA4\';
trainNameList={'region1','region1','region1','region2','region2','region2'};
testName='train';
%iterList=[8000,11000,12000,8000,16000,18000];
iterList=[9,12,16,10,14,19]*1000;

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


%% read obs and soilM
yfolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
ysfolder='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
nt=4160;
ySMAP=zeros(nt,length(testInd));
for i=1:length(testInd)
    yfile=[yfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
    ySMAP(:,i)=csvread(yfile);
end
ySMAP(ySMAP==-9999)=nan;
temp=csvread([yfolder,'stat.csv']);
lb=temp(1);ub=temp(2);

%GLDAS
yGLDAS=zeros(4160,length(testInd));
for i=1:length(testInd)
    yfile=[ysfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
    yGLDAS(:,i)=csvread(yfile);
end
yGLDAS(yGLDAS==-9999)=nan;
yGLDAS=yGLDAS/100;

% LSTM
yLSTM=zeros(4160,length(testInd),length(iterList))*nan;
for i=1:length(iterList);
    i
    iter=iterList(i);
    trainName=trainNameList{i};
    outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
    load([outfolder,'data.mat']);
    yp=data;
    yp=(yp+1).*(ub-lb)./2+lb;
    yLSTM(:,:,i)=yp;
end

% Linear Regression
load('Y:\Kuai\rnnSMAP\output\trainNA4\out_linear.mat')

%% calculate stat
t1=1:ntrain-1;
t2=ntrain:nt;
%GLDAS
statGLDAS=statCal(yGLDAS,ySMAP);
statGLDAS1=statCal(yGLDAS(t1,:),ySMAP(t1,:));
statGLDAS2=statCal(yGLDAS(t2,:),ySMAP(t2,:));
%linear regression
statLR=statCal(yLR,ySMAP);
statLR1=statCal(yLR(t1,:,:),ySMAP(t1,:));
statLR2=statCal(yLR(t2,:,:),ySMAP(t2,:));
%LSTM
statLSTM=statCal(yLSTM,ySMAP);
statLSTM1=statCal(yLSTM(t1,:,:),ySMAP(t1,:));
statLSTM2=statCal(yLSTM(t2,:,:),ySMAP(t2,:));

saveFile=[folder,'Stat_comb.mat'];
save(saveFile,'statGLDAS','statGLDAS1','statGLDAS2',...
    'statLR','statLR1','statLR2',...
    'statLSTM','statLSTM1','statLSTM2')

%% plot map
% saveFile=[folder,'Stat_comb.mat'];
% load(saveFile)
% grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
% load('Y:\GLDAS\maskGLDAS_025.mat');
% tnum=grid.tnum;
% mask1d=mask(:);
% indMask=find(mask1d==1);
% [xx,yy]=meshgrid(grid.lon,grid.lat);
% testIndMask=indMask(testInd);
% testX=xx(testIndMask);
% testY=yy(testIndMask);
% testLon=unique(testX);
% testLat=flipud(unique(testY));
% cellsize=min(min(testLon(2:end)-testLon(1:end-1)),min(testLat(1:end-1)-testLat(2:end)));
% lon=min(testLon):cellsize:max(testLon);
% lat=max(testLat):-cellsize:min(testLat);
% 
% nashMap=zeros(length(lat),length(lon),length(iterList))*nan;
% rsqMap=zeros(length(lat),length(lon),length(iterList))*nan;
% nashMap_ys=zeros(length(lat),length(lon))*nan;
% rsqMap_ys=zeros(length(lat),length(lon))*nan;
% 
% for k=1:length(iterList)
%     for i=1:length(testInd)
%         indX=find(lon==testX(i));
%         indY=find(lat==testY(i));
%         nashMap(indY,indX,k)=nashLSTM(i,k);
%         rsqMap(indY,indX,k)=rsqLSTM(i,k);
%         biasMap(indY,indX,k)=biasLSTM(i,k);
%     end
% end
% for i=1:length(testInd)
%     indX=find(lon==testX(i));
%     indY=find(lat==testY(i));
%     nashMapGLDAS(indY,indX)=nashGLDAS(i);
%     rsqMapGLDAS(indY,indX)=rsqGLDAS(i);
%     biasMapGLDAS(indY,indX)=biasGLDAS(i);
% end
% 
% shapefile='Y:\Maps\USA.shp';
% lonLim=[-140,-60];
% nashrange=[-2,0.6];
% rsqrange=[-2,0.6];
% 
% for k=1:length(iterList)
%     titlestr=['Nash iter ',num2str(iterList(k))];
%     f=showGlobalMap(nashMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
%         'color',nashrange,'lonLim',lonLim,'newFig',0,'title',titlestr);
%     saveas(f,[figfolder,'\nashMap',num2str(k),'.fig'])
%     titlestr=['Rsq iter ',num2str(iterList(k))];
%     f=showGlobalMap(rsqMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
%         'color',rsqrange,'lonLim',lonLim,'newFig',0,'title',titlestr);
%     saveas(f,[figfolder,'\rsqMap',num2str(k),'.fig'])
%     close all
% end

%% plot a best nash map
% % nashMapSel=zeros(length(lat),length(lon),3)*nan;
% % nashMapSel(:,:,1)=nashMap(:,:,2);
% % nashMapSel(:,:,2)=nashMap(:,:,4);
% % nashMapSel(:,:,3)=nashMap(:,:,6);
% [nashMapBest,nashBestModel]=max(nashMap,[],3);
% [rsqMapBest,rsqBestModel]=max(rsqMap,[],3);
% 
% f=showGlobalMap(nashMapBest,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','Best Nash');
% saveas(f,[figfolder,'\nashMap_comb.fig'])
% f=showGlobalMap(rsqMapBest,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Nash - GLDAS Nash');
% saveas(f,[figfolder,'\rsqMap_comb.fig'])
% f=showGlobalMap(nashMapBest-nashMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','Best Rsq');
% saveas(f,[figfolder,'\nashMap_comb_comp.fig'])
% f=showGlobalMap(rsqMapBest-rsqMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Rsq - GLDAS Rsq');
% saveas(f,[figfolder,'\rsqMap_comb_comp.fig'])
% close all
% 
% tempMap=rsqMapBest-rsqMap_ys;
% tempMap(tempMap<0)=-1;
% tempMap(tempMap>0)=1;
% f=showGlobalMap(tempMap,lon,lat,cellsize,'shapefile',shapefile,...
%     'color',[-1,1],'lonLim',lonLim,'newFig',0,'title','LSTM Rsq - GLDAS Rsq');

%% plot LSTM vs GLDAS
figfolder=[folder,'fig_comb\'];
if ~isdir(figfolder)
    mkdir(figfolder)
end
statPlot(statGLDAS,statLR,statLSTM,figfolder)
statPlot(statGLDAS1,statLR1,statLSTM1,figfolder,'_test')
statPlot(statGLDAS2,statLR2,statLSTM2,figfolder,'_train')

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

