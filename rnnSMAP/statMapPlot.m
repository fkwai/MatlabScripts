function statMapPlot(stat,testXY,nameLst,shapefile,saveFolder )
% plot Maps for given stat mat (by statCal.m) file
% example:

% postRnnSMAP_region_script



%% construct grid
testLon=unique(testXY(:,1));
testLat=flipud(unique(testXY(:,2)));
cellsize=min(min(testLon(2:end)-testLon(1:end-1)),min(testLat(1:end-1)-testLat(2:end)));
lon=min(testLon):cellsize:max(testLon);
lat=max(testLat):-cellsize:min(testLat);

%% draw Maps
nLayers=length(nameLst);
nashMap=zeros(length(lat),length(lon),nLayers)*nan;
rsqMap=zeros(length(lat),length(lon),nLayers)*nan;
rmseMap=zeros(length(lat),length(lon),nLayers)*nan;
biasMap=zeros(length(lat),length(lon),nLayers)*nan;

for k=1:length(nameLst)
    for i=1:size(testXY,1)
        indX=find(lon==testXY(i,1));
        indY=find(lat==testXY(i,2));
        nashMap(indY,indX,k)=stat.nash(i,k);
        rsqMap(indY,indX,k)=stat.rsq(i,k);
        rmseMap(indY,indX,k)=stat.rmse(i,k);
        biasMap(indY,indX,k)=stat.bias(i,k);
    end
end

%% plot Maps
lonLim=[-125,-60];
latLim=[25,50];
nashrange=[-2,0.6];
rsqrange=[-2,0.6];
rmserange=[0,1];
biasrange=[-1,1];

for k=1:length(nameLst)
    nameStr=strrep(nameLst{k},'_','\_');
    
    titlestr=['Nash ',nameStr];
    f=showGlobalMap(nashMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',nashrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,'title',titlestr);
    hold on;
    %plot(highlightShape.X,highlightShape.Y,'y');hold off;
    saveas(f,[saveFolder,'\nashMap_',nameLst{k},'.fig'])
    close all
    
    titlestr=['rsq ',nameStr];
    f=showGlobalMap(rsqMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',rsqrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,'title',titlestr);
    hold on;
    %plot(highlightShape.X,highlightShape.Y,'y');hold off;
    saveas(f,[saveFolder,'\rsqMap_',nameLst{k},'.fig'])
    close all
    
    titlestr=['rmse ',nameStr];
    f=showGlobalMap(rmseMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',rmserange,'lonLim',lonLim,'latLim',latLim,'newFig',0,'title',titlestr);
    hold on;
    %plot(highlightShape.X,highlightShape.Y,'y');hold off;
    saveas(f,[saveFolder,'\rmseMap_',nameLst{k},'.fig'])
    close all
    
    titlestr=['bias ',nameStr];
    f=showGlobalMap(biasMap(:,:,k),lon,lat,cellsize,'shapefile',shapefile,...
        'color',biasrange,'lonLim',lonLim,'latLim',latLim,'newFig',0,'title',titlestr);
    hold on;
    %plot(highlightShape.X,highlightShape.Y,'y');hold off;
    saveas(f,[saveFolder,'\biasMap_',nameLst{k},'.fig'])
    close all
end
end

