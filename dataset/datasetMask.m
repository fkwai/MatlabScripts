
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
