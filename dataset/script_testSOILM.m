
maskSMAP=load(kPath.maskSMAP_CONUS);
crd=csvread([kPath.DBSMAP_L3_CONUS,'\crd.csv']);
t=csvread([kPath.DBSMAP_L3_CONUS,'\time.csv']);
lat=maskSMAP.lat;
lon=maskSMAP.lon;

%% SMAP
dataSMAP=csvread([kPath.DBSMAP_L3_CONUS,'\SMAP.csv']);
dataSMAP(dataSMAP==-9999)=nan;
gridSMAP=zeros(length(lat),length(lon),length(t))*nan;

%% NLDAS
dataNLDAS=csvread([kPath.DBSMAP_L3_CONUS,'\SOILM.csv']);
dataNLDAS(dataNLDAS==-9999)=nan;
dataNLDAS=dataNLDAS/100;
gridNLDAS=zeros(length(lat),length(lon),length(t))*nan;

matNLDAS2=load('H:\Kuai\rnnSMAP\NLDAS_SOILM\SoilL_NLDAS.mat');
gridNLDAS2=matNLDAS2.data./100;
tNLDAS=matNLDAS2.tnum;

dataNLDASvec=reshape(gridNLDAS2,[length(lat)*length(lon),length(tNLDAS)]);
dataNLDAS2=dataNLDASvec(maskSMAP.mask==1,:);
[C,indNLDAS,indN]=intersect(tNLDAS,t);


%% fill data from SMAP and NLDAS to grid
for k=1:size(crd,1)
    ix=find(single(crd(k,2))==single(lon));
    iy=find(single(crd(k,1))==single(lat));
    gridSMAP(iy,ix,:)=dataSMAP(k,:);
    gridNLDAS(iy,ix,:)=dataNLDAS(k,:);
end

%% GLDAS
matGLDAS=load('H:\Kuai\rnnSMAP\NLDAS_SOILM\SoilM_GLDAS.mat');
gridGLDAS=matGLDAS.data./100;
tGLDAS=matGLDAS.tnum;

dataGLDASvec=reshape(gridGLDAS,[length(lat)*length(lon),length(tGLDAS)]);
dataGLDAS=dataGLDASvec(maskSMAP.mask==1,:);
[C,indGLDAS,indG]=intersect(tGLDAS,t);

%% box plot
stat1=statCal(dataNLDAS',dataSMAP');
stat2=statCal(dataNLDAS2(:,indNLDAS)',dataSMAP(:,indN)');
stat3=statCal(dataGLDAS(:,indGLDAS)',dataSMAP(:,indG)');

statName='rmse';
plotData=[stat1.(statName),stat2.(statName),stat3.(statName)];
boxplot(plotData,'Labels',{'NLDAS SoilM','NLDAS SoilL','GLDAS'});
ylim([0,0.15])

%%
rmseMap=nanmean(sqrt((gridSMAP-gridNLDAS).^2),3);
rmseMap2=nanmean(sqrt((gridSMAP(:,:,indG)-gridGLDAS(:,:,indGLDAS)).^2),3);

tsStr(1).grid=gridSMAP;
tsStr(1).t=t;
tsStr(1).symb='*k';
tsStr(1).legendStr='SMAP';

tsStr(2).grid=gridNLDAS;
tsStr(2).t=t;
tsStr(2).symb='-b';
tsStr(2).legendStr='NLDAS';

tsStr(3).grid=gridGLDAS;
tsStr(3).t=tGLDAS;
tsStr(3).symb='-r';
tsStr(3).legendStr='GLDAS';

tsStr(4).grid=gridNLDAS2;
tsStr(4).t=tNLDAS;
tsStr(4).symb='-g';
tsStr(4).legendStr='NLDAS SoilL';

showGrid( rmseMap-rmseMap2,[length(lat):-1:1]',[1:length(lon)],1,'tsStr',tsStr)
