%% preDefine
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';

%% Elevation
load('Y:\SRTM\SRTM025.mat')
load('Y:\SoilGlobal\wise5by5min_v1b\soilMap025.mat')
load('Y:\GLDAS\maskCONUS.mat')
field={'DEM','Slope','Aspect','Sand','Silt','Clay','Capa','Bulk'};
for i=1:length(field)
    eval(['data=',field{i},';']);
    grid2csv_CONUS_const(data,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\',field{i})
end


%% NDVI & LULC
NDVIFile='Y:\GIMMS\avg.tif';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat')
%load('Y:\GLDAS\maskGLDAS_025.mat')
load('Y:\GLDAS\maskCONUS.mat')
mask=maskCONUS;

[gridNDVI,refNDVI]=geotiffread(NDVIFile);
lonNDVI=refNDVI.LongitudeLimits(1)+refNDVI.CellExtentInLongitude/2:...
    refNDVI.CellExtentInLongitude:...
    refNDVI.LongitudeLimits(2)-refNDVI.CellExtentInLongitude/2;
latNDVI=[refNDVI.LatitudeLimits(2)-refNDVI.CellExtentInLatitude/2:...
    -refNDVI.CellExtentInLatitude:...
    refNDVI.LatitudeLimits(1)+refNDVI.CellExtentInLatitude/2]';
gridNDVI_int=interp2(lonNDVI,latNDVI,gridNDVI,lon,lat);
grid2csv_CONUS_const(gridNDVI_int,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\','NDVI')

%% LULC (only CONUS)
LULCFile='Y:\NLCD\nlcd_2011_landcover_2011_edition_2014_10_10\nlcd_2011_landcover_proj_resample.tif';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat')
%load('Y:\GLDAS\maskGLDAS_025.mat')
load('Y:\GLDAS\maskCONUS.mat')
mask=maskCONUS;

[gridLULC,cmapLULC,refLULC]=geotiffread(LULCFile);
lonLULC=refLULC.LongitudeLimits(1)+refLULC.CellExtentInLongitude/2:...
    refLULC.CellExtentInLongitude:...
    refLULC.LongitudeLimits(2)-refLULC.CellExtentInLongitude/2;
latLULC=[refLULC.LatitudeLimits(2)-refLULC.CellExtentInLatitude/2:...
    -refLULC.CellExtentInLatitude:...
    refLULC.LatitudeLimits(1)+refLULC.CellExtentInLatitude/2]';
gridLULC=double(gridLULC);
%gridLULC(gridLULC==0)=nan;
gridLULC(gridLULC==255)=0;
% construct US grid
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
maskInd = mask2Ind_SMAP();
maskIndUS=maskInd(latIndUS,lonIndUS);
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);
vq=interpGridArea(lonLULC,latLULC,gridLULC,lonUS,latUS,'mode');

lulc=vq;
lulc(vq==11|vq==12)=1;
lulc(vq==21|vq==22|vq==23)=2;
lulc(vq==31)=3;
lulc(vq==41)=4;
lulc(vq==42|vq==43)=5;
lulc(vq==52)=6;
lulc(vq==71)=7;
lulc(vq==81|vq==82)=8;
lulc(vq==90|vq==95)=9;

gridLULC_int=zeros(size(mask));
gridLULC_int(latIndUS,lonIndUS)=vq;
grid2csv_CONUS_const(gridLULC_int,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\','LULC')

%% crop irrigation
global kPath
irriFile='H:\Kuai\Data\UScrop\cropIrrigation.tif';
maskMat=load(kPath.maskSMAP_CONUS);
[gridIrri,refIrri]=geotiffread(irriFile);

lonIrri=refIrri.LongitudeLimits(1)+refIrri.CellExtentInLongitude/2:...
    refIrri.CellExtentInLongitude:...
    refIrri.LongitudeLimits(2)-refIrri.CellExtentInLongitude/2;
latIrri=[refIrri.LatitudeLimits(2)-refIrri.CellExtentInLatitude/2:...
    -refIrri.CellExtentInLatitude:...
    refIrri.LatitudeLimits(1)+refIrri.CellExtentInLatitude/2]';
gridIrri=double(gridIrri);
gridIrri(gridIrri<0)=0;

% construct US grid
vq=interpGridArea(lonIrri,latIrri,gridIrri,maskMat.lon,maskMat.lat,'mean');
gridConst2csv_SMAP(vq,'Irri')
gridConst2csv_SMAP(vq.^0.5,'IrriSq')

% splitSubset
sLst=[4,4,16,16];
fLst=[1,3,1,9];
for k=1:length(sLst)
    ss=sLst(k);
    ff=fLst(k);
    splitSubset_interval('const_Irri',['CONUSs',num2str(ss),'f',num2str(ff)],ss,ff)
    splitSubset_interval('const_IrriSq',['CONUSs',num2str(ss),'f',num2str(ff)],ss,ff)
end




