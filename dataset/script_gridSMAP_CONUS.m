

global kPath
tic
SMAP_L3=load([kPath.SMAP,'SMAP_L3.mat']);
toc

%% CONUS Bounding Box
boundingbox=[-125,-66;25,50];
indY=find(SMAP_L3.lat>boundingbox(2,1)&SMAP_L3.lat<boundingbox(2,2));
indX=find(SMAP_L3.lon>boundingbox(1,1)&SMAP_L3.lon<boundingbox(1,2));
data=SMAP_L3.data(indY,indX,:);
tnum=SMAP_L3.tnum;
lat=SMAP_L3.lat(indY);
lon=SMAP_L3.lon(indX);
[lonMesh,latMesh]=meshgrid(lon,lat);

%% find valid cells and assign index
gridVal=double(~isnan(nanmean(data,3)));
gridInd=zeros(size(gridVal));
gridInd(gridVal==1)=1:sum(gridVal(:));

save([kPath.SMAP,'gridSMAP_CONUS.mat'],'gridVal','gridInd','lat','lon','latMesh','lonMesh')
save([kPath.SMAP,'SMAP_L3_CONUS.mat'],'data','gridInd','lat','lon','latMesh','lonMesh','tnum')




