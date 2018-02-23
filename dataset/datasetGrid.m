
global kPath

%% 36 KM EASE grid
[data2,lat2,lon2]= readSMAP_L3(20150501,'readCrd',1);
lon=nanmean(lon2,1);
lat=nanmean(lat2,2);
find(isnan(lon))
find(isnan(lat))
gridFile=[kPath.SMAP,filesep,'gridEASE_36'];
save(gridFile,'lon','lat');

%% GLDAS grid
folder=[kPath.GLDAS,'GLDAS_NOAH025_3H.2.1',filesep,'2015',filesep,'001',filesep];
fileLst=dir([folder,'*.nc4']);
fileName=[folder,fileLst(1).name];
lon=ncread(fileName,'lon');lon=lon';
lat=ncread(fileName,'lat');lat=flipud(lat);
gridFile=[kPath.SMAP,filesep,'gridGLDAS_025'];
save(gridFile,'lon','lat');

%% NLDAS grid
[data,lat,lon,tnum,fieldLst ] = readNLDAS_Hourly('FORA',20151025,10);
gridFile=[kPath.SMAP,filesep,'gridNLDAS'];
save(gridFile,'lon','lat');

