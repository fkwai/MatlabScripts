% do post process
folder='Y:\Kuai\rnnSMAP\output\trainNA2\';
trainName='train';
testName='train';
iterList=1000:1000:20000;
figfolder=[folder,'fig_',trainName,'_',testName,'\'];
testFile=[folder,testName,'.csv'];
testInd=csvread(testFile);

%% read data and save a matfile
% for k=1:length(iterList)
%     k
%     tic
%     iter=iterList(k);
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
% yfolder='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\';
% ysfolder='Y:\Kuai\rnnSMAP\Database\tDB_soilM\';
% nt=4160;
% y=zeros(nt,length(testInd));
% for i=1:length(testIndMask)
%     yfile=[yfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
%     y(:,i)=csvread(yfile);
% end
% y(y==-9999)=nan;
% temp=csvread([yfolder,'stat.csv']);
% lb=temp(1);ub=temp(2);
% 
% ys=zeros(4160,length(testInd));
% for i=1:length(testIndMask)
%     yfile=[ysfolder,'data\',sprintf('%06d',testInd(i)),'.csv'];
%     ys(:,i)=csvread(yfile);
% end
% ys(ys==-9999)=nan;
% ys=ys/100;
% nash_ys=1-nansum((ys-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);
% 
% % calculate nash
% ypAll=zeros(4160,length(testInd),length(iterList))*nan;
% nashAll=zeros(length(testInd),length(iterList))*nan;
% 
% for i=1:length(iterList);
%     iter=iterList(i);
%     outfolder=[folder,'\out_',trainName,'_',testName,'_',num2str(iter),'\'];
%     load([outfolder,'data.mat']);
%     yp=data;
%     yp=(yp+1).*(ub-lb)./2+lb;
%     nash=1-nansum((yp-y).^2)./nansum((y-repmat(nanmean(y),[nt,1])).^2);
%     
%     ypAll(:,:,i)=yp;
%     nashAll(:,i)=nash;
% end
% 
% saveFile=[folder,'Nash_',trainName,'_',testName,'.mat'];
% save(saveFile,'y','ys','ypAll','nash_ys','nashAll')

%% plot map
saveFile=[folder,'Nash_',trainName,'_',testName,'.mat'];
load(saveFile)

nashMap=zeros(length(lat),length(lon),length(iterList))*nan;
nashMap_ys=zeros(length(lat),length(lon))*nan;

for k=1:length(iterList)
    for i=1:length(testInd)
        indX=find(lon==testX(i));
        indY=find(lat==testY(i));
        nashMap(indY,indX,k)=nashAll(i,k);
    end
end
for i=1:length(testInd)
    indX=find(lon==testX(i));
    indY=find(lat==testY(i));
    nashMap_ys(indY,indX)=nash_ys(i);
end

shapefile='Y:\Maps\USA.shp';
lonLim=[-140,-60];
showrange=[-2,0.6];

mkdir(figfolder);
for k=1:length(iterList)
    titlestr=['Nash iter ',num2str(iterList(k))];
    f=showGlobalMap(nashMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',showrange,'lonLim',lonLim,'newFig',0,'title',titlestr);
    saveas(f,[figfolder,'\nashMap_iter',num2str(iterList(k)),'.fig'])
    close all
end

f = showGlobalMap( nashMap(:,:,10),lon,lat,cellsize,'shapefile',shapefile,...
    'color',showrange,'lonLim',lonLim,'title',['Nash iter 10000']);

f = showGlobalMap( nashMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
    'color',showrange,'lonLim',lonLim,'title',['Nash soilM']);
saveas(f,[figfolder,'\nashMap_GLDAS_soilM.fig'])

f = showGlobalMap(  nashMap(:,:,11)-nashMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
    'color',[-1,1],'lonLim',lonLim,'title',['LSTM - GLDAS SoilM']);
saveas(f,[figfolder,'\nashMap_comp.fig'])

for k=1:length(iterList)
    titlestr=['LSTM - GLDAS: iter ',num2str(iterList(k))];
    f=showGlobalMap(nashMap(:,:,k)-nashMap_ys,lon,lat,cellsize,'shapefile',shapefile,...
        'color',[-1,1],'lonLim',lonLim,'newFig',0,'title',titlestr);
    saveas(f,[figfolder,'\nashMapComp_iter',num2str(iterList(k)),'.fig'])
end


%% show TS while click into points
f = showGlobalMap( nashMap(:,:,10),lon,lat,cellsize,'shapefile',shapefile,...
    'color',showrange,'lonLim',lonLim,'title',['Nash iter 10000']);
c=flipud(autumn(length(iterList)));
g=[];
while(1)
    figure(f)
    [px,py]=ginput(1);   
    cx=round((px-lon(1))/cellsize)*cellsize+lon(1);
    cy=round((py-lat(end))/cellsize)*cellsize+lat(end);
    ind=find(testX==cx&testY==cy);
    if ishandle(g);close(g);end
    g=figure('Position',[100,100,1500,600]);
    hold on
    legendstr={};
    for k=11
        iter=iterList(k);
        v=ypAll(:,ind,k);
        plot(tnum(4:8:end-4),v(4:8:end-4),'-','color',c(k,:));hold on
        na=nashAll(ind,k);
        legendstr=[legendstr,['iter',num2str(iter),' ',num2str(na,'%.2f')]];
    end    
    plot(tnum,y(:,ind),'b*');hold on
    plot(tnum,ys(:,ind),'k');hold on
    legendstr_GLDAS=['GLDAS',' ',num2str(nash_ys(ind),'%.2f')];
    legendstr=[legendstr,'SMAP',legendstr_GLDAS];
    hold off
    legend(legendstr,'Location','bestoutside')
    
    datetick('x')
    title(['Lat=',num2str(cy,'%.3f'),'; ','Lon=',num2str(cx,'%.3f')]);
    hold off    
end

%% re-devide training set into two
% k=12;
% diff=nashMap(:,:,k)-nashMap_ys;
% bRegion=zeros(length(testInd),1);
% for i=1:length(testInd)
%     indX=find(lon==testX(i));
%     indY=find(lat==testY(i));
%     bRegion(i)=diff(indY,indX)>=0;
% end
% region1=testInd(bRegion==1);
% region2=testInd(bRegion==0);
% 
% dlmwrite([folder,'\region1'],region1,'precision',8);
% dlmwrite([folder,'\region2'],region2,'precision',8);

