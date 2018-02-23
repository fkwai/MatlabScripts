
global kPath

%% TRMM
t=20160229;
dirTRMM=kPath.TRMM_daily;

tnum=datenumMulti(t);
yStr=datestr(tnum,'yyyy');
mStr=datestr(tnum,'mm');
dStr=datestr(tnum,'yyyymmdd');

fileName=[dirTRMM,filesep,yStr,filesep,mStr,filesep,'3B42_Daily.',dStr,'.7.nc4'];
data = ncread(fileName,'precipitation');

lat=-49.875:0.25:49.875;
lon=-179.875:0.25:179.875;
data(data<0)=nan;
[f,cmap]=showMap(data,lat,lon,'colorRange',[0,100]);

%% GPM
t=20150101;
dirGPM=kPath.GPM;

tnum=datenumMulti(t);
yStr=datestr(tnum,'yyyy');
mStr=datestr(tnum,'mm');
dStr=datestr(tnum,'yyyymmdd');

lat=[89.95:-0.1:-89.95]';
lon=-179.95:0.1:179.95;

fileName=[dirGPM,yStr,filesep,mStr,filesep,'3B-DAY.MS.MRG.3IMERG.',dStr,'-S000000-E235959.V05.nc4'];

dataTemp=ncread(fileName,'precipitationCal');
data=flipud(dataTemp);
imagesc(data,[0,120])
showMap(data,lat,lon,'colorRange',[0,50])