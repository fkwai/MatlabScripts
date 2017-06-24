

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
matNan=double(~isnan(data));
matDecision=sum(matNan,3)./size(matNan,3);

mask=double(matDecision>0.3);
maskInd=zeros(size(mask));
maskInd(mask==1)=1:sum(mask(:));
lat1D=latMesh(mask==1);
lon1D=lonMesh(mask==1);

save([kPath.SMAP,'maskSMAP_CONUS.mat'],'mask','maskInd','lat','lon','latMesh','lonMesh','lat1D','lon1D')




