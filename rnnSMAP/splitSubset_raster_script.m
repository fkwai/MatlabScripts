% split gridInd by NLCD and NDVI

%% preDefine
LULCFile='Y:\NLCD\nlcd_2011_landcover_2011_edition_2014_10_10\nlcd_2011_landcover_proj_resample.tif';
NDVIFile='Y:\GIMMS\avg.tif';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat')
dSub=4;

%% construct US grid
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
maskInd = mask2Ind_SMAP();
maskIndUS=maskInd(latIndUS,lonIndUS);
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);

%% gridIndUS
% gridIndUS=maskIndUS(:);
% gridIndUS(gridIndUS==0)=[];
% gridIndUS=sort(gridIndUS);
% dlmwrite('Y:\Kuai\rnnSMAP\output\NA_landcover\indUS.csv',gridIndUS,'precision',8);  
% 
% dSub=16;
% maskIndUS_sub=maskIndUS(dSub:dSub:end,dSub:dSub:end);
% gridIndUS_sub=maskIndUS_sub(:);
% gridIndUS_sub(gridIndUS_sub==0)=[];
% gridIndUS_sub=sort(gridIndUS_sub);
% dlmwrite(['Y:\Kuai\rnnSMAP\output\indUSsub',num2str(dSub),'.csv'],gridIndUS_sub,'precision',8);  
% 
% crdFile='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv';
% crd=csvread(crdFile);
% plot(crd(gridIndUS_sub,2),crd(gridIndUS_sub,1),'*','color',rand(1,3));hold on
% plot(crd(gridIndUS,2),crd(gridIndUS,1),'o','color',rand(1,3));hold on

%% NDVI
saveName='Y:\Kuai\rnnSMAP\output\ndvi_sub4_';
[gridNDVI,refNDVI]=geotiffread(NDVIFile);
lonNDVI=refNDVI.LongitudeLimits(1)+refNDVI.CellExtentInLongitude/2:...
    refNDVI.CellExtentInLongitude:...
    refNDVI.LongitudeLimits(2)-refNDVI.CellExtentInLongitude/2;
latNDVI=[refNDVI.LatitudeLimits(2)-refNDVI.CellExtentInLatitude/2:...
    -refNDVI.CellExtentInLatitude:...
    refNDVI.LatitudeLimits(1)+refNDVI.CellExtentInLatitude/2]';

gridNDVIUS=interp2(lonNDVI,latNDVI,gridNDVI,lonUS,latUS);
gridNDVIUS(maskIndUS==0)=nan;

NDVI1D=gridNDVIUS(:);
maskInd1D=maskIndUS(:);
nanInd=find(isnan(NDVI1D));
NDVI1D(nanInd)=[];
maskInd1D(nanInd)=[];
[NDVISort,ordSort]=sort(NDVI1D);
indSort=maskInd1D(ordSort);

% pick up grid included in a given ind csv
indSub=csvread('Y:\Kuai\rnnSMAP\output\CONUS_sub4.csv');
[C,indPick,indSubPick]=intersect(indSort,indSub,'stable');
NDVISort=NDVISort(indPick);
indSort=indSort(indPick);

% validate
% crdFile='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv';
% crdAll=csvread(crdFile);
% crd=crdAll(indSort,:);
% scatter(crd(:,2),crd(:,1),[],NDVISort);
% figure;imagesc(gridNDVIUS,[0,0.75])

%divide into batches each has 2050 grids. 
batSize=208;
nbat=round(length(NDVISort)/batSize);
for k=1:nbat-1  
    ind=(k-1)*batSize+1:k*batSize;
    indTemp=indSort(ind);
    dlmwrite([saveName,num2str(k),'.csv'],indTemp,'precision',8);    
end
indTemp=indSort((nbat-1)*batSize+1:end);
dlmwrite([saveName,num2str(nbat),'.csv'],indTemp,'precision',8);    

%% land cover
% first resample in ArcGIS
% cellsize=0.25;
% [nr,nc]=size(maskIndUS);
% grid.col = nc;
% grid.row = nr;
% grid.xllcorner = lonUS(1)-cellsize/2;
% grid.yllcorner = latUS(end)-cellsize/2;
% grid.cellsize = cellsize;
% grid.z = flipud(maskIndUS);
% file='Y:\Kuai\rnnSMAP\output\NA_landcover\maskInd.txt';
% d=writeASCIIGrid(file,grid);

tic
[gridLULC,cmapLULC,refLULC]=geotiffread(LULCFile);
lonLULC=refLULC.LongitudeLimits(1)+refLULC.CellExtentInLongitude/2:...
    refLULC.CellExtentInLongitude:...
    refLULC.LongitudeLimits(2)-refLULC.CellExtentInLongitude/2;
latLULC=[refLULC.LatitudeLimits(2)-refLULC.CellExtentInLatitude/2:...
    -refLULC.CellExtentInLatitude:...
    refLULC.LatitudeLimits(1)+refLULC.CellExtentInLatitude/2]';
toc

tic
gridLULC=double(gridLULC);
gridLULC(gridLULC==0)=nan;
gridLULC(gridLULC==255)=nan;
vq=interpGridArea(lonLULC,latLULC,gridLULC,lonUS,latUS,'mode');
toc

%divide into batches 
vq(maskIndUS==0)=nan;
tab=tabulate(vq(:));
tab=tab(tab(:,3)~=0,:);
lulc=zeros(size(vq))*nan;
lulc(vq==11|vq==12)=1;
lulc(vq==21|vq==22|vq==23)=2;
lulc(vq==31)=3;
lulc(vq==41)=4;
lulc(vq==42|vq==43)=5;
lulc(vq==52)=6;
lulc(vq==71)=7;
lulc(vq==81|vq==82)=8;
lulc(vq==90|vq==95)=9;

lulcVec=lulc(:);
maskIndVec=maskIndUS(:);
nanInd=find(isnan(lulcVec));
lulcVec(nanInd)=[];
maskIndVec(nanInd)=[];
[lulcSort,ordSort]=sort(lulcVec);
indSort=maskIndVec(ordSort);

% pick up grid included in a given ind csv
indSub=csvread('Y:\Kuai\rnnSMAP\output\CONUS_sub4.csv');
[C,indPick,indSubPick]=intersect(indSort,indSub,'stable');
lulcSort=lulcSort(indPick);
indSort=indSort(indPick);

% validate
% crdFile='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv';
% crdAll=csvread(crdFile);
% crd=crdAll(indSort,:);
% scatter(crd(:,2),crd(:,1),[],lulcSort);
% figure;imagesc(vq)

saveName='Y:\Kuai\rnnSMAP\output\lulc_sub4_';
for k=1:9  
    ind=find(lulcSort==k);
    indTemp=indSort(ind);
    dlmwrite([saveName,num2str(k),'.csv'],indTemp,'precision',8);   
    plot(crdAll(indTemp,2),crdAll(indTemp,1),'*','color',rand(1,3));hold on
end

