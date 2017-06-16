% %% Elevation
load('Y:\SRTM\SRTM025.mat')
load('Y:\SoilGlobal\wise5by5min_v1b\soilMap025.mat')
load('Y:\GLDAS\maskCONUS.mat')
field={'DEM','Slope','Aspect','Sand','Silt','Clay','Capa','Bulk'};
for i=1:length(field)
    eval(['data=',field{i},';']);
    grid2csv_CONUS_const(data,lat,lon,mask,'E:\Kuai\rnnSMAP\Database\',field{i})
end


%% NDVI
NDVIFile='Y:\GIMMS\avg.tif';
load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat')
%load('Y:\GLDAS\maskGLDAS_025.mat')
load('Y:\GLDAS\maskCONUS.mat')

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
irriFile='H:\Kuai\Data\UScrop\cropIrrigation.tif';
load('H:\Kuai\Data\GLDAS\crdGLDAS025.mat')
load('H:\Kuai\Data\GLDAS\maskCONUS.mat')

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
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
maskUS=mask(latIndUS,lonIndUS);
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);
vq=interpGridArea(lonIrri,latIrri,gridIrri,lonUS,latUS,'mean');

grid2csv_CONUS_const(vq,lat,lon,maskUS,'H:\Kuai\rnnSMAP\Database\','Irrigation')

grid2csv_CONUS_const(vq.^0.5,lat,lon,maskUS,'H:\Kuai\rnnSMAP\Database\','Irri_sq')

%% rock depth
RockdepFile='H:\Kuai\Data\RockDep\average_soil_and_sedimentary-deposit_thickness.tif';
load('H:\Kuai\Data\GLDAS\crdGLDAS025.mat')
load('H:\Kuai\Data\GLDAS\maskCONUS.mat')

[gridRockdep,refRockdep]=geotiffread(RockdepFile);
lonRockdep=refRockdep.LongitudeLimits(1)+refRockdep.CellExtentInLongitude/2:...
    refRockdep.CellExtentInLongitude:...
    refRockdep.LongitudeLimits(2)-refRockdep.CellExtentInLongitude/2;
latRockdep=[refRockdep.LatitudeLimits(2)-refRockdep.CellExtentInLatitude/2:...
    -refRockdep.CellExtentInLatitude:...
    refRockdep.LatitudeLimits(1)+refRockdep.CellExtentInLatitude/2]';
gridRockdep=double(gridRockdep);
gridRockdep(gridRockdep<0)=nan;
% construct US grid
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);
maskUS=mask(latIndUS,lonIndUS);
vq=interpGridArea(lonRockdep,latRockdep,gridRockdep,lonUS,latUS,'mean');

grid2csv_CONUS_const(vq,lat,lon,maskUS,'H:\Kuai\rnnSMAP\Database\','Rockdep')

%% Water tabel from Fan Ying
WatertableFile='H:\Kuai\Data\WaterTable\NA_wtd.tif';
load('H:\Kuai\Data\GLDAS\crdGLDAS025.mat')
load('H:\Kuai\Data\GLDAS\maskCONUS.mat')

[gridWatertable,refWatertable]=geotiffread(WatertableFile);
lonWatertable=refWatertable.XWorldLimits(1)+refWatertable.CellExtentInWorldX/2:...
    refWatertable.CellExtentInWorldX:...
    refWatertable.XWorldLimits(2)-refWatertable.CellExtentInWorldX/2;
latWatertable=[refWatertable.YWorldLimits(2)-refWatertable.CellExtentInWorldY/2:...
    -refWatertable.CellExtentInWorldY:...
    refWatertable.YWorldLimits(1)+refWatertable.CellExtentInWorldY/2]';
gridWatertable=double(gridWatertable);
gridWatertable(abs(gridWatertable)>9000)=nan;
% construct US grid
latBoundUS=[25,50];
lonBoundUS=[-125,-66.5];
latIndUS=find(lat>=latBoundUS(1)&lat<=latBoundUS(2));
lonIndUS=find(lon>=lonBoundUS(1)&lon<=lonBoundUS(2));
latUS=lat(latIndUS);
lonUS=lon(lonIndUS);
maskUS=mask(latIndUS,lonIndUS);
vq=interpGridArea(lonWatertable,latWatertable,gridWatertable,lonUS,latUS,'mean');

grid2csv_CONUS_const(vq,lat,lon,maskUS,'H:\Kuai\rnnSMAP\Database\Daily\CONUS\','Watertable')





