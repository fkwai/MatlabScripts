
fileName=['/mnt/sdb1/Database/GLDAS/data/GLDAS/GLDAS_NOAH025_3H.2.1/2015/001/',...
    'GLDAS_NOAH025_3H.A20150101.0000.021.nc4'];



info=ncinfo(fileName);
temp=[];
for k=1:length(info.Variables)
    var=info.Variables(k).Name;
    temp.(var)=ncread(fileName,var);
end

gridFile=[kPath.SMAP,filesep,'gridEASE_36'];
gridEASE=load(gridFile);

[x1,y1]=meshgrid(gridEASE.lon,gridEASE.lat);
[x2,y2]=meshgrid(temp.lon,temp.lat);
plot(x1,y1,'b*');hold on
plot(x2,y2,'ro');hold off

[dH,lat1,lon1,tnum1] = readSMAP_L2(20150501);
[d2,lat2,lon2]= readSMAP_L3(20150501);
[d3,lat3,lon3]= readSMAP_L3(20150501,'field','Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm');



d1=nanmean(dH,3);

dd2=sum(~isnan(data1),3);

aa=zeros(size(d1));
aa(isnan(d1)&isnan(d2))=1;
aa(isnan(d1)&~isnan(d2))=2;
aa(~isnan(d1)&isnan(d2))=3;
aa(d1==d2)=4;
imagesc(aa)

imagesc(d2-d1,[0,0.05])

showMap(d3-d2,gridEASE.lat,gridEASE.lon,'colorRange',[-0.1,0.1])

global kPath
m1=load([kPath.SMAP,'SMAP_L3_AM']);
m2=load([kPath.SMAP,'SMAP_L3_PM']);

d1=sum(~isnan(m1.data),3);
d2=sum(~isnan(m2.data),3);

d3=sum(~isnan(m1.data)|~isnan(m2.data),3);













