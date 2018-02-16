


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
