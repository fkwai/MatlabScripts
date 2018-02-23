
%% SMAP mask global
global kPath
gridFile=[kPath.SMAP,filesep,'gridEASE_36'];
gridEASE=load(gridFile,'lon','lat');
smapAM=load([kPath.SMAP,'SMAP_L3_AM','.mat']);
smapPM=load([kPath.SMAP,'SMAP_L3_PM','.mat']);

rateAM=nanmean(~isnan(smapAM.data),3);
ratePM=nanmean(~isnan(smapPM.data),3);

latLim=59.5;
r=0.25;
rateAM(abs(smapAM.lat)>latLim,:)=nan;
ratePM(abs(smapAM.lat)>latLim,:)=nan;
temp=double(rateAM>r)*2+double(ratePM>r);
%imagesc(temp)
mask=temp==3;
maskInd=zeros(size(mask));
maskInd(mask==1)=1:sum(mask(:));
lon=gridEASE.lon;
lat=gridEASE.lat;
[lonMesh,latMesh]=meshgrid(lon,lat);
lat1D=latMesh(mask==1);
lon1D=lonMesh(mask==1);
save([kPath.SMAP,'maskSMAP_L3.mat'],'mask','maskInd','lat','lon','latMesh','lonMesh','lat1D','lon1D')


%%

matName='SPL4SMGPv3_profile';
maskName='maskSMAP_CONUS_L4';
SMAP=load([kPath.SMAP,matName,'.mat']);
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