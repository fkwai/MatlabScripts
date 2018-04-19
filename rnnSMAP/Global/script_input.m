
global kPath
t=20151025;

%% time series data
bb=[-125,-66;25,50];
fieldName='GPM';
[xData1,xStat1,crd1,time1] = readDB_Global('Globalv4f4',fieldName,'yrLst',[2015]);
indC=find(crd1(:,1)>bb(2,1)&crd1(:,1)<bb(2,2)&crd1(:,2)>bb(1,1)&crd1(:,2)<bb(1,2));
[grid1,xx1,yy1] = data2grid3d(xData1(:,indC)',crd1(indC,2),crd1(indC,1));
[grid1,xx1,yy1] = data2grid3d(xData1',crd1(:,2),crd1(:,1));

fieldName='APCP';
[xData2,xStat2,xDataNorm2] = readDB_SMAP('CONUSv4f1',fieldName);
crd2=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'crd.csv']);
time2=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv']);
[grid2,xx2,yy2] = data2grid3d(xData2',crd2(:,2),crd2(:,1));

ind2=randi([1,size(crd2,1)]);
[ind1,~]=intersectCrd(crd1,crd2(ind2,:));
plot(time1,xData1(:,ind1),'ro-');hold on
plot(time2,xData2(:,ind2)*24,'b*-');hold off
datetick('x')

ind1=find(time1==datenumMulti(t));
showMap(grid1(:,:,ind1),yy1,xx1,'colorRange',[0,30])
ind2=find(time2==datenumMulti(t));
showMap(grid2(:,:,ind2)*24,yy2,xx2,'colorRange',[0,30])

%% const
bb=[-125,-66;25,50];
fieldName='Bulk';
[xData1,xStat1,crd1,~] = readDB_Global('Global',fieldName,'const',1);
indC=find(crd1(:,1)>bb(2,1)&crd1(:,1)<bb(2,2)&crd1(:,2)>bb(1,1)&crd1(:,2)<bb(1,2));
[grid1,xx1,yy1] = data2grid(xData1(indC)',crd1(indC,2),crd1(indC,1));

fieldName='Bulk';
[xData2,xStat2,xDataNorm2] = readDB_SMAP('CONUS',['const_',fieldName]);
crd2=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'crd.csv']);
time2=csvread([kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv']);
[grid2,xx2,yy2] = data2grid3d(xData2',crd2(:,2),crd2(:,1));

showMap(grid1,yy1,xx1)
showMap(grid2,yy2,xx2)

%% raw data
maskGrid0=load([kPath.SMAP,filesep,'gridEASE_36.mat']);
maskGrid1=load([kPath.SMAP,filesep,'gridGLDAS_025.mat']);
maskGrid2=load([kPath.SMAP,filesep,'gridNLDAS.mat']);

[d1temp,t1]=readGLDAS_Noah(t,'Tair_f_inst');
indX= maskGrid1.lon>=maskGrid2.lon(1)&maskGrid1.lon<=maskGrid2.lon(end);
indY= maskGrid1.lat<=maskGrid2.lat(1)&maskGrid1.lat>=maskGrid2.lat(end);
d1=d1temp(indY,indX);
showMap(d1,maskGrid1.lat(indY),maskGrid1.lon(indX),'colorRange',[273,300])

% [d1temp,latTRMM,lonTRMM]=readTRMM(t);
% indX= lonTRMM>=maskGrid2.lon(1)&lonTRMM<=maskGrid2.lon(end);
% indY= latTRMM<=maskGrid2.lat(1)&latTRMM>=maskGrid2.lat(end);
% d1=d1temp(indY,indX);
% showMap(d1,latTRMM(indY),lonTRMM(indX),'colorRange',[0,30])

[ d2temp,latNLDAS,lonNLDAS,t2,fieldLst ] = readNLDAS_Hourly('FORA',t,-1);
kk=find(strcmp(fieldLst,'TMP_2'));
d2=mean(d2temp(:,:,:,kk),3);
showMap(d2,latNLDAS,lonNLDAS,'colorRange',[273,300])


