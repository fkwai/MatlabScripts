
% matName='SMAP_L3'
% maskName='maskSMAP_CONUS';

matName='SPL4SMGPv3_profile';
maskName='maskSMAP_CONUS_L4';


%% load matfile
global kPath
tic
SMAP=load([kPath.SMAP,matName,'.mat']);
toc

%% CONUS Bounding Box
boundingbox=[-125,-66;25,50];
indY=find(SMAP.lat>boundingbox(2,1)&SMAP.lat<boundingbox(2,2));
indX=find(SMAP.lon>boundingbox(1,1)&SMAP.lon<boundingbox(1,2));
data=SMAP.data(indY,indX,:);
tnum=SMAP.tnum;
lat=SMAP.lat(indY);
lon=SMAP.lon(indX);
[lonMesh,latMesh]=meshgrid(lon,lat);
tic
save([kPath.SMAP,matName,'_CONUS.mat'],'data','lat','lon','tnum');
toc

%% find valid cells and assign index
%{
matNan=double(~isnan(data));
matDecision=sum(matNan,3)./size(matNan,3);

mask=double(matDecision>0.3);
maskInd=zeros(size(mask));
maskInd(mask==1)=1:sum(mask(:));
lat1D=latMesh(mask==1);
lon1D=lonMesh(mask==1);

tic
save([kPath.SMAP,maskName,'.mat'],'mask','maskInd','lat','lon','latMesh','lonMesh','lat1D','lon1D')
toc
%}


