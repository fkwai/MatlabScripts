
maskSMAP=load(kPath.maskSMAP_CONUS);
crd=csvread([kPath.DBSMAP_L3_CONUS,'\crd.csv']);
t=csvread([kPath.DBSMAP_L3_CONUS,'\time.csv']);
lat=maskSMAP.lat;
lon=maskSMAP.lon;

%% SMAP
dataSMAP=csvread([kPath.DBSMAP_L3_CONUS,'\SMAP.csv']);
dataSMAP(dataSMAP==-9999)=nan;
gridSMAP=zeros(length(lat),length(lon),length(t))*nan;
% fill data 
for k=1:size(crd,1)
    ix=find(single(crd(k,2))==single(lon));
    iy=find(single(crd(k,1))==single(lat));
    gridSMAP(iy,ix,:)=dataSMAP(k,:);
end

%% NLDAS
matNLDAS=load('H:\Kuai\rnnSMAP\NLDAS_SOILM\SoilL_NLDAS.mat');
gridNLDAS=matNLDAS.data./100;
tNLDAS=matNLDAS.tnum;
dataNLDASvec=reshape(gridNLDAS,[length(lat)*length(lon),length(tNLDAS)]);
dataNLDAS=dataNLDASvec(maskSMAP.mask==1,:);
[C,indNLDAS,indN]=intersect(tNLDAS,t);

%% NLDAS_new
matNLDASnew=load('H:\Kuai\rnnSMAP\NLDAS_SOILM\LSOIL.mat');
gridNLDASnew=matNLDASnew.data./100;
tNLDASnew=matNLDASnew.tnum;
dataNLDASnewvec=reshape(gridNLDASnew,[length(lat)*length(lon),length(tNLDASnew)]);
dataNLDASnew=dataNLDASnewvec(maskSMAP.mask==1,:);
[C,indNLDASnew,indNnew]=intersect(tNLDASnew,t);

%% box plot
stat=statCal(dataNLDAS(:,indNLDAS)',dataSMAP(:,indN)');
statnew=statCal(dataNLDASnew(:,indNLDASnew)',dataSMAP(:,indNnew)');

statName='rmse';
plotData=[stat.(statName),statnew.(statName)];
boxplot(plotData,'Labels',{'old','new'});
ylim([0,0.15])

%%
rmseMap=nanmean(sqrt((gridSMAP(:,:,indN)-gridNLDAS(:,:,indNLDAS)).^2),3);

tsStr(1).grid=gridSMAP;
tsStr(1).t=t;
tsStr(1).symb='*k';
tsStr(1).legendStr='SMAP';

tsStr(2).grid=gridNLDAS;
tsStr(2).t=tNLDAS;
tsStr(2).symb='-r';
tsStr(2).legendStr='old';

tsStr(3).grid=gridNLDASnew;
tsStr(3).t=tNLDASnew;
tsStr(3).symb='-b';
tsStr(3).legendStr='new';

showGrid( rmseMap,[length(lat):-1:1]',[1:length(lon)],1,'tsStr',tsStr)
